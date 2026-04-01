import 'dart:math';

import 'models.dart';

class LiveMatchEngine {
  LiveMatchEngine({
    required this.format,
    required List<Player> userXI,
    required List<Player> aiXI,
    required this.userTeamName,
    required this.aiTeamName,
    required Random random,
  }) : _random = random,
       _userXI = userXI,
       _aiXI = aiXI {
    final userBatFirst = _random.nextBool();
    _firstInnings = LiveInningsState(
      battingTeam: userBatFirst ? userTeamName : aiTeamName,
      bowlingTeam: userBatFirst ? aiTeamName : userTeamName,
      battingOrder: userBatFirst ? _userXI : _aiXI,
      maxBalls: format.oversPerInnings * 6,
    );
    _secondInnings = LiveInningsState(
      battingTeam: userBatFirst ? aiTeamName : userTeamName,
      bowlingTeam: userBatFirst ? userTeamName : aiTeamName,
      battingOrder: userBatFirst ? _aiXI : _userXI,
      maxBalls: format.oversPerInnings * 6,
    );

    statusText = '${_firstInnings.battingTeam} won toss and bats first.';
  }

  final MatchFormat format;
  final String userTeamName;
  final String aiTeamName;
  final Random _random;
  final List<Player> _userXI;
  final List<Player> _aiXI;

  late final LiveInningsState _firstInnings;
  late final LiveInningsState _secondInnings;

  bool completed = false;
  bool userWon = false;
  String statusText = '';
  final List<MatchBallEvent> timeline = <MatchBallEvent>[];
  double aggression = 0.56;

  int? _target;

  LiveInningsState get activeInnings {
    if (_firstInnings.complete && !_secondInnings.complete) {
      return _secondInnings;
    }
    return _firstInnings;
  }

  LiveInningsState get firstInnings => _firstInnings;
  LiveInningsState get secondInnings => _secondInnings;

  bool get firstInningsDone => _firstInnings.complete;

  List<Player> _bowlingOrderFor(String teamName) {
    final squad = teamName == userTeamName ? _userXI : _aiXI;
    final sorted = List<Player>.of(squad)
      ..sort((a, b) => b.bowlingRating.compareTo(a.bowlingRating));
    return sorted.take(6).toList();
  }

  String _phaseText(int balls) {
    final over = balls ~/ 6 + 1;
    if (over <= format.powerplayOvers) return 'powerplay';
    if (over >= format.deathStartOvers) return 'death';
    return 'middle';
  }

  double _traitBoundaryBoost(Player batter) {
    return batter.traits.fold<double>(0, (prev, t) => prev + t.boundaryBoost);
  }

  double _traitWicketShift(Player batter) {
    return batter.traits.fold<double>(0, (prev, t) => prev + t.wicketRiskDelta);
  }

  double _traitBowlingBoost(Player bowler) {
    return bowler.traits.fold<double>(0, (prev, t) => prev + t.bowlingBoost);
  }

  (double, List<double>) _probabilities({
    required LiveInningsState innings,
    required Player batter,
    required Player bowler,
  }) {
    final phase = _phaseText(innings.balls);
    final phaseBoundary = phase == 'powerplay'
        ? 0.03
        : (phase == 'death' ? 0.07 : 0.0);
    final phaseWicket = phase == 'death'
        ? 0.024
        : (phase == 'powerplay' ? 0.01 : 0.0);

    final batterQuality =
        (batter.hitting * 0.46) +
        (batter.anchoring * 0.2) +
        (batter.form * 0.2) +
        (batter.pressure * 0.14);
    final bowlerQuality =
        (bowler.bowling * 0.5) +
        (bowler.economySkill * 0.3) +
        (bowler.pressure * 0.2) +
        (_traitBowlingBoost(bowler) * 100);

    final chasePressure = (_target != null && innings == _secondInnings)
        ? ((_target! - innings.runs) /
                  (max(1, innings.maxBalls - innings.balls)))
              .clamp(0.6, 3.5)
        : 1.0;

    var wicketProb =
        0.017 +
        aggression * 0.045 +
        phaseWicket +
        _traitWicketShift(batter) +
        (bowlerQuality - batterQuality) / 1400;
    wicketProb += (chasePressure - 1) * 0.008;
    wicketProb = wicketProb.clamp(0.008, 0.33);

    var w0 =
        0.28 -
        aggression * 0.12 +
        bowlerQuality * 0.0012 -
        batterQuality * 0.0006;
    var w1 = 0.34 - aggression * 0.05 + batter.anchoring * 0.0006;
    var w2 = 0.14 - aggression * 0.01;
    var w3 = 0.02;
    var w4 =
        0.14 + aggression * 0.12 + phaseBoundary + _traitBoundaryBoost(batter);
    var w6 =
        0.08 +
        aggression * 0.09 +
        phaseBoundary * 0.5 +
        _traitBoundaryBoost(batter) * 0.7;

    final raw = <double>[
      w0,
      w1,
      w2,
      w3,
      w4,
      w6,
    ].map((v) => v < 0.01 ? 0.01 : v).toList();
    final total = raw.fold<double>(0, (a, b) => a + b);
    final normalized = raw.map((e) => e / total).toList();
    return (wicketProb, normalized);
  }

  int _sampleRuns(List<double> weights) {
    const outcomes = <int>[0, 1, 2, 3, 4, 6];
    final r = _random.nextDouble();
    var acc = 0.0;
    for (var i = 0; i < weights.length; i++) {
      acc += weights[i];
      if (r <= acc) return outcomes[i];
    }
    return 1;
  }

  MatchBallEvent stepBall() {
    if (completed) {
      return MatchBallEvent(
        overText: activeInnings.overText,
        description: statusText,
        runs: 0,
        isWicket: false,
        batter: activeInnings.striker.name,
        bowler: '',
      );
    }

    final innings = activeInnings;
    if (innings.complete) {
      _transitionIfNeeded();
      return stepBall();
    }

    final bowlers = _bowlingOrderFor(innings.bowlingTeam);
    final over = innings.balls ~/ 6;
    final bowler = bowlers[over % bowlers.length];
    final batter = innings.striker;

    final monteSamples = 120;
    var wickets = 0;
    final runCounts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 6: 0};

    for (var i = 0; i < monteSamples; i++) {
      final (wicketProb, weights) = _probabilities(
        innings: innings,
        batter: batter,
        bowler: bowler,
      );
      if (_random.nextDouble() < wicketProb) {
        wickets++;
      } else {
        final run = _sampleRuns(weights);
        runCounts[run] = (runCounts[run] ?? 0) + 1;
      }
    }

    final wicketChance = wickets / monteSamples;
    final didWicket = _random.nextDouble() < wicketChance;

    var run = 0;
    if (!didWicket) {
      run = runCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final overTextBeforeBall = innings.overText;

    if (didWicket) {
      innings.wickets += 1;
      innings.balls += 1;
      innings.batterBalls[batter.id] =
          (innings.batterBalls[batter.id] ?? 0) + 1;
      innings.outBatters.add(batter.id);
      innings.runProgression.add(innings.runs);

      if (innings.nextBatterIndex <= innings.battingOrder.length - 1) {
        innings.strikerIndex = innings.nextBatterIndex;
        innings.nextBatterIndex += 1;
      }
    } else {
      innings.runs += run;
      innings.balls += 1;
      innings.batterRuns[batter.id] =
          (innings.batterRuns[batter.id] ?? 0) + run;
      innings.batterBalls[batter.id] =
          (innings.batterBalls[batter.id] ?? 0) + 1;
      innings.runProgression.add(innings.runs);

      final zone = _pickShotZone(run);
      innings.shotZones[zone] = (innings.shotZones[zone] ?? 0) + 1;

      if (run.isOdd) {
        final tmp = innings.strikerIndex;
        innings.strikerIndex = innings.nonStrikerIndex;
        innings.nonStrikerIndex = tmp;
      }
    }

    if (innings.balls % 6 == 0 && !innings.complete) {
      final tmp = innings.strikerIndex;
      innings.strikerIndex = innings.nonStrikerIndex;
      innings.nonStrikerIndex = tmp;
    }

    if (_target != null &&
        innings == _secondInnings &&
        innings.runs >= _target!) {
      innings.balls = innings.balls; // keep explicit end-of-chase state.
      innings.wickets = innings.wickets;
      _finishMatch(userWon: innings.battingTeam == userTeamName);
    }

    if (innings.complete && !completed) {
      _transitionIfNeeded();
    }

    final event = MatchBallEvent(
      overText: overTextBeforeBall,
      description: didWicket
          ? '$overTextBeforeBall WICKET - ${batter.name} b ${bowler.name}'
          : '$overTextBeforeBall $run run${run == 1 ? '' : 's'} by ${batter.name}',
      runs: run,
      isWicket: didWicket,
      batter: batter.name,
      bowler: bowler.name,
    );

    timeline.insert(0, event);
    if (timeline.length > 30) {
      timeline.removeLast();
    }

    statusText = completed
        ? statusText
        : '${innings.battingTeam} ${innings.runs}/${innings.wickets} in ${innings.overText} overs';

    return event;
  }

  void _transitionIfNeeded() {
    if (_firstInnings.complete && _target == null) {
      _target = _firstInnings.runs + 1;
      statusText =
          'Innings break. Target for ${_secondInnings.battingTeam}: $_target';
      return;
    }

    if (_firstInnings.complete && _secondInnings.complete && !completed) {
      final userRuns = _inningsFor(userTeamName).runs;
      final aiRuns = _inningsFor(aiTeamName).runs;
      if (userRuns == aiRuns) {
        _finishMatch(userWon: false, tie: true);
      } else {
        _finishMatch(userWon: userRuns > aiRuns);
      }
    }
  }

  LiveInningsState _inningsFor(String teamName) {
    if (_firstInnings.battingTeam == teamName) return _firstInnings;
    return _secondInnings;
  }

  void _finishMatch({required bool userWon, bool tie = false}) {
    completed = true;
    this.userWon = userWon;
    final userInnings = _inningsFor(userTeamName);
    final aiInnings = _inningsFor(aiTeamName);

    if (tie) {
      statusText = 'Match tied at ${userInnings.runs}-${aiInnings.runs}';
      return;
    }

    if (userWon) {
      if (userInnings.runs >= (_target ?? 0)) {
        statusText =
            '$userTeamName won by ${10 - userInnings.wickets} wickets.';
      } else {
        statusText =
            '$userTeamName won by ${userInnings.runs - aiInnings.runs} runs.';
      }
    } else {
      if (aiInnings.runs >= (_target ?? 0)) {
        statusText = '$aiTeamName won by ${10 - aiInnings.wickets} wickets.';
      } else {
        statusText =
            '$aiTeamName won by ${aiInnings.runs - userInnings.runs} runs.';
      }
    }
  }

  MatchResult buildResult() {
    final userInningsLive = _inningsFor(userTeamName);
    final aiInningsLive = _inningsFor(aiTeamName);

    List<BattingEntry> cardFrom(LiveInningsState innings) {
      return innings.battingOrder
          .map((Player player) {
            final runs = innings.batterRuns[player.id] ?? 0;
            final balls = innings.batterBalls[player.id] ?? 0;
            final out = innings.outBatters.contains(player.id);
            return BattingEntry(
              name: player.name,
              runs: runs,
              balls: balls,
              out: out,
            );
          })
          .where((entry) => entry.balls > 0 || entry.runs > 0)
          .toList();
    }

    return MatchResult(
      userInnings: InningsSummary(
        teamName: userTeamName,
        runs: userInningsLive.runs,
        wickets: userInningsLive.wickets,
        balls: userInningsLive.balls,
        battingCard: cardFrom(userInningsLive),
      ),
      aiInnings: InningsSummary(
        teamName: aiTeamName,
        runs: aiInningsLive.runs,
        wickets: aiInningsLive.wickets,
        balls: aiInningsLive.balls,
        battingCard: cardFrom(aiInningsLive),
      ),
      userWon: userWon,
      summary: statusText,
    );
  }

  String _pickShotZone(int run) {
    if (run == 0) return 'straight';
    final zonesByRun = <int, List<String>>{
      1: <String>['square', 'cover', 'midwicket', 'thirdman'],
      2: <String>['square', 'cover', 'straight'],
      3: <String>['thirdman', 'midwicket'],
      4: <String>['square', 'cover', 'thirdman'],
      6: <String>['straight', 'midwicket', 'cover', 'fine'],
    };
    final choices = zonesByRun[run] ?? <String>['straight'];
    return choices[_random.nextInt(choices.length)];
  }
}
