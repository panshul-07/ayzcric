import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'match_engine.dart';
import 'models.dart';
import 'seed_factory.dart';

class GameController extends ChangeNotifier {
  GameController() {
    _initialize();
  }

  final Random _random = Random();
  late final SeedFactory _seed = SeedFactory(_random);

  late TeamProfile userTeam;
  late List<TeamStanding> standings;
  late List<Fixture> fixtures;
  late List<AuctionLot> auctionLots;
  late List<Player> youthAcademy;

  final List<FinanceEntry> financeLedger = <FinanceEntry>[];
  final List<String> careerLog = <String>[];

  MatchFormat matchFormat = MatchFormat.t20;
  int seasonYear = 2026;
  int youthSignings = 0;
  bool fired = false;

  late List<BoardObjective> objectives;

  LiveMatchEngine? liveMatch;
  MatchResult? latestResult;
  bool autoPlay = false;
  Timer? _autoTimer;
  bool _resultCommitted = false;

  String statusBanner = 'Welcome, Chairman. Build your dynasty.';
  String? impactCandidateId;
  String? clubCaptainId;
  bool adsRemoved = false;
  int stadiumLevel = 1;
  int trainingLevel = 1;
  int medicalLevel = 1;
  int scoutingLevel = 1;
  int academyLevel = 1;

  final Map<String, int> fanMovementSeason = <String, int>{
    'Rivalry Swings': 0,
    'Match Results': 0,
    'Star Signings': 0,
    'Playoff Matches': 0,
    'Playoff Reputation': 0,
    'Season Finish': 0,
    'League Position': 0,
    'Championship': 0,
  };
  final List<int> fanTrendCareer = <int>[];
  final List<int> fanTrendSeason = <int>[];
  double fanRevenueSeasonCr = 0;
  double fanRevenueCareerCr = 0;

  String teamFranchise = 'Mumbai';
  String teamSuffix = 'Monsoons';
  String teamAbbreviation = 'MM';

  final Map<String, UnlockedAchievement> _unlockedAchievements =
      <String, UnlockedAchievement>{};
  final List<UnlockedAchievement> _achievementQueue = <UnlockedAchievement>[];

  static const Map<String, TeamBranding> defaultTeamBrandings = {
    'Mumbai Monsoons': TeamBranding(
      shape: TeamBadgeShape.shield,
      pattern: TeamBadgePattern.band,
      emblem: TeamBadgeEmblem.anchor,
      primaryColor: 0xFF145CB5,
      secondaryColor: 0xFF62B4FF,
      accentColor: 0xFFFFFFFF,
    ),
    'Chennai Cobras': TeamBranding(
      shape: TeamBadgeShape.shield,
      pattern: TeamBadgePattern.band,
      emblem: TeamBadgeEmblem.crown,
      primaryColor: 0xFFE3B111,
      secondaryColor: 0xFF2E6FC2,
      accentColor: 0xFFFFFFFF,
    ),
    'Delhi Phantoms': TeamBranding(
      shape: TeamBadgeShape.hexagon,
      pattern: TeamBadgePattern.diagonal,
      emblem: TeamBadgeEmblem.bolt,
      primaryColor: 0xFFD53E45,
      secondaryColor: 0xFF3291F0,
      accentColor: 0xFFFFFFFF,
    ),
    'Bangalore Bolts': TeamBranding(
      shape: TeamBadgeShape.hexagon,
      pattern: TeamBadgePattern.diagonal,
      emblem: TeamBadgeEmblem.bolt,
      primaryColor: 0xFFDF3B3E,
      secondaryColor: 0xFF171A25,
      accentColor: 0xFFFFE567,
    ),
    'Kolkata Cyclones': TeamBranding(
      shape: TeamBadgeShape.diamond,
      pattern: TeamBadgePattern.chevron,
      emblem: TeamBadgeEmblem.star,
      primaryColor: 0xFF7A33D4,
      secondaryColor: 0xFFFCC32C,
      accentColor: 0xFFFFFFFF,
    ),
    'Hyderabad Falcons': TeamBranding(
      shape: TeamBadgeShape.circle,
      pattern: TeamBadgePattern.band,
      emblem: TeamBadgeEmblem.star,
      primaryColor: 0xFFFE7A1E,
      secondaryColor: 0xFF23262F,
      accentColor: 0xFFFFFFFF,
    ),
    'Rajasthan Scorpions': TeamBranding(
      shape: TeamBadgeShape.pentagon,
      pattern: TeamBadgePattern.diagonal,
      emblem: TeamBadgeEmblem.sword,
      primaryColor: 0xFF2A58C8,
      secondaryColor: 0xFFF53885,
      accentColor: 0xFFFFFFFF,
    ),
    'Punjab Stallions': TeamBranding(
      shape: TeamBadgeShape.shield,
      pattern: TeamBadgePattern.diagonal,
      emblem: TeamBadgeEmblem.star,
      primaryColor: 0xFFD93D45,
      secondaryColor: 0xFFF2C02C,
      accentColor: 0xFF121212,
    ),
    'Gujarat Vipers': TeamBranding(
      shape: TeamBadgeShape.shield,
      pattern: TeamBadgePattern.band,
      emblem: TeamBadgeEmblem.sword,
      primaryColor: 0xFF1F5FCA,
      secondaryColor: 0xFFB09D67,
      accentColor: 0xFFFFFFFF,
    ),
    'Lucknow Tridents': TeamBranding(
      shape: TeamBadgeShape.shield,
      pattern: TeamBadgePattern.band,
      emblem: TeamBadgeEmblem.anchor,
      primaryColor: 0xFF1A82D8,
      secondaryColor: 0xFFF08F31,
      accentColor: 0xFFFFFFFF,
    ),
  };

  final Map<String, _RecordEntry> _recordBook = {
    'Highest Team Total': _RecordEntry(),
    'Best Successful Chase': _RecordEntry(),
    'Biggest Win (Runs)': _RecordEntry(),
    'Biggest Win (Wkts)': _RecordEntry(),
    'Best NRR Swing': _RecordEntry(),
  };

  void _initialize() {
    userTeam = _seed.createUserTeam();
    teamAbbreviation = userTeam.shortName;
    final split = _splitFranchise(userTeam.name);
    teamFranchise = split.$1;
    teamSuffix = split.$2;
    standings = _seed.createStandings(userTeam.name);
    fixtures = _seed.createFixtures(userTeam.name);
    auctionLots = _seed.createAuctionLots();
    youthAcademy = _createYouthAcademy();
    if (userTeam.squad.isNotEmpty) {
      clubCaptainId = userTeam.squad.first.id;
    }
    objectives = _defaultObjectives();
    if (fanTrendCareer.isEmpty) {
      fanTrendCareer.add(userTeam.fans);
    }
    fanTrendSeason
      ..clear()
      ..add(userTeam.fans);

    _log('Franchise initialized for season $seasonYear.');
    _addFinance('Founding capital', 100.0, 'capital');
    notifyListeners();
  }

  void disposeController() {
    _autoTimer?.cancel();
  }

  List<Player> _createYouthAcademy() {
    final academyBoost = academyLevel * 2;
    return List<Player>.generate(6, (int i) {
      final raw = _seed.createPlayer(id: 'youth-$seasonYear-$i', inXI: false);
      return raw.copyWith(
        age: 15 + _random.nextInt(4),
        overall: (raw.overall - 10 + academyBoost).clamp(38, 93),
        hitting: (raw.hitting + academyBoost).clamp(34, 96),
        bowling: (raw.bowling + academyBoost).clamp(34, 96),
        salaryCr: 0.12 + _random.nextDouble() * 0.25,
        marketValueCr: 0.22 + _random.nextDouble() * 0.7,
      );
    });
  }

  List<BoardObjective> _defaultObjectives() {
    return <BoardObjective>[
      _seed.objective(
        id: 'wins',
        title: 'Win 9 League Matches',
        description: 'Maintain consistency across the season.',
        target: 9,
      ),
      _seed.objective(
        id: 'fans',
        title: 'Reach 95k Fanbase',
        description: 'Grow your audience with performances and marketing.',
        target: 95,
      ),
      _seed.objective(
        id: 'youth',
        title: 'Sign 2 U-23 Talents',
        description: 'Invest in long-term squad value.',
        target: 2,
      ),
      _seed.objective(
        id: 'top4',
        title: 'Finish in Top 4',
        description: 'Qualify for playoffs this year.',
        target: 1,
      ),
    ];
  }

  Fixture? get nextFixture {
    for (final fixture in fixtures) {
      if (!fixture.played) return fixture;
    }
    return null;
  }

  bool get seasonComplete => fixtures.every((f) => f.played);

  int get matchesPlayed => fixtures.where((f) => f.played).length;

  int get matchesRemaining => fixtures.length - matchesPlayed;

  List<Player> get playingXI {
    final xi = userTeam.squad
        .where((p) => p.inPlayingXI && !p.injured)
        .toList();
    if (xi.length >= 11) return xi.take(11).toList();

    final extras = userTeam.squad
        .where((p) => !p.inPlayingXI && !p.injured)
        .take(11 - xi.length);
    return <Player>[...xi, ...extras];
  }

  List<Player> get impactBenchCandidates =>
      userTeam.squad.where((p) => !p.inPlayingXI && !p.injured).toList()
        ..sort((a, b) => b.overall.compareTo(a.overall));

  Player? get selectedImpactPlayer {
    if (impactCandidateId == null) return null;
    for (final p in userTeam.squad) {
      if (p.id == impactCandidateId) return p;
    }
    return null;
  }

  Player? get clubCaptain {
    if (clubCaptainId == null) return null;
    for (final player in userTeam.squad) {
      if (player.id == clubCaptainId) return player;
    }
    return null;
  }

  int get facilitiesCompositeLevel =>
      stadiumLevel + trainingLevel + medicalLevel + scoutingLevel;

  int get fanMovementNet =>
      fanMovementSeason.values.fold<int>(0, (a, b) => a + b);

  int get unlockedAchievementCount => _unlockedAchievements.length;

  List<UnlockedAchievement> get unlockedAchievements =>
      _unlockedAchievements.values.toList()
        ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

  bool get hasQueuedAchievements => _achievementQueue.isNotEmpty;

  UnlockedAchievement? takeNextAchievement() {
    if (_achievementQueue.isEmpty) return null;
    return _achievementQueue.removeAt(0);
  }

  String get academyTierLabel {
    switch (academyLevel) {
      case 1:
        return 'Local Nets';
      case 2:
        return 'District Program';
      case 3:
        return 'Elite U-19 Pathway';
      case 4:
        return 'National Talent Lab';
      default:
        return 'Dynasty Academy';
    }
  }

  int get academyMaxLevel => 5;

  double get academyUpgradeCost => 1.2 + academyLevel * 1.05;

  double get academyPromotionCost =>
      (0.55 - ((academyLevel - 1) * 0.05)).clamp(0.25, 0.55);

  List<Map<String, Object>> get leagueTopCards {
    final all = <Player>[
      ...userTeam.squad,
      ...auctionLots.map((e) => e.player),
    ];
    if (all.isEmpty) return <Map<String, Object>>[];
    final runStar = List<Player>.of(all)
      ..sort((a, b) => b.hitting.compareTo(a.hitting));
    final wicketStar = List<Player>.of(all)
      ..sort((a, b) => b.bowling.compareTo(a.bowling));
    final strikeStar = List<Player>.of(all)
      ..sort((a, b) => b.battingRating.compareTo(a.battingRating));
    final economyStar = List<Player>.of(all)
      ..sort((a, b) => b.economySkill.compareTo(a.economySkill));
    final sixStar = List<Player>.of(all)
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final potmStar = List<Player>.of(all)
      ..sort((a, b) => b.currentImpact.compareTo(a.currentImpact));

    return <Map<String, Object>>[
      {
        'title': 'Most Runs',
        'badge': 'Orange Cap',
        'value': '${920 + (matchesPlayed * 38) + runStar.first.hitting}',
        'player': runStar.first.name,
        'color': 0xFFF57C3B,
      },
      {
        'title': 'Most Wickets',
        'badge': 'Purple Cap',
        'value':
            '${14 + (matchesPlayed ~/ 2) + (wicketStar.first.bowling ~/ 7)}',
        'player': wicketStar.first.name,
        'color': 0xFF8A63FF,
      },
      {
        'title': 'Best Strike Rate',
        'badge': 'Super Striker',
        'value': (128 + (strikeStar.first.battingRating * 0.75))
            .toStringAsFixed(1),
        'player': strikeStar.first.name,
        'color': 0xFF3F8CFF,
      },
      {
        'title': 'Best Economy',
        'badge': 'Economy Ace',
        'value': (10.6 - (economyStar.first.economySkill / 28)).toStringAsFixed(
          2,
        ),
        'player': economyStar.first.name,
        'color': 0xFF1EAE78,
      },
      {
        'title': 'Most POTM',
        'badge': 'Match MVP',
        'value': '${2 + (potmStar.first.currentImpact ~/ 14)}',
        'player': potmStar.first.name,
        'color': 0xFFB2BEC8,
      },
      {
        'title': 'Most Sixes',
        'badge': 'Sky Hitter',
        'value': '${22 + (sixStar.first.hitting ~/ 2)}',
        'player': sixStar.first.name,
        'color': 0xFFFF6F61,
      },
    ];
  }

  List<Map<String, Object>> get fanLeaderboard {
    final sorted = List<TeamStanding>.of(standings)
      ..sort((a, b) {
        final byPts = b.points.compareTo(a.points);
        if (byPts != 0) return byPts;
        return b.netRunRate.compareTo(a.netRunRate);
      });

    return List<Map<String, Object>>.generate(sorted.length, (int i) {
      final team = sorted[i];
      final isUser = team.name == userTeam.name;
      final base = isUser
          ? userTeam.fans
          : (46000 + (sorted.length - i) * 4200);
      final swing = ((team.netRunRate * 4200) + (team.wins * 540)).round();
      return <String, Object>{
        'team': team.name,
        'fans': base + swing,
        'delta': swing,
        'branding': teamBrandingFor(team.name),
      };
    });
  }

  List<TeamRecord> get franchiseRecords => _recordBook.entries.map((entry) {
    return TeamRecord(
      title: entry.key,
      value: entry.value.metric <= 0 ? '-' : entry.value.displayValue,
      holder: entry.value.holder,
      season: entry.value.season,
    );
  }).toList();

  TeamBranding teamBrandingFor(String teamName) {
    if (teamName == userTeam.name) {
      return userTeam.branding;
    }
    return defaultTeamBrandings[teamName] ??
        const TeamBranding(
          shape: TeamBadgeShape.circle,
          pattern: TeamBadgePattern.band,
          emblem: TeamBadgeEmblem.star,
          primaryColor: 0xFF546E7A,
          secondaryColor: 0xFFCFD8DC,
          accentColor: 0xFFFFFFFF,
        );
  }

  void setFormat(MatchFormat format) {
    if (liveMatch != null && !liveMatch!.completed) {
      statusBanner = 'Finish current match before changing format.';
      notifyListeners();
      return;
    }
    matchFormat = format;
    statusBanner = 'Match format switched to ${format.label}.';
    notifyListeners();
  }

  void setImpactCandidate(String? playerId) {
    impactCandidateId = playerId;
    if (playerId == null) {
      statusBanner = 'Impact player cleared.';
    } else {
      final player = userTeam.squad.firstWhere((p) => p.id == playerId);
      statusBanner = 'Impact player set: ${player.name}.';
    }
    notifyListeners();
  }

  void saveFranchiseIdentity({
    required String franchise,
    required String suffix,
    required String abbreviation,
    required TeamBranding branding,
  }) {
    if (liveMatch != null && !liveMatch!.completed) {
      statusBanner = 'Finish active match before editing franchise identity.';
      notifyListeners();
      return;
    }

    final oldName = userTeam.name;
    final cleanFranchise = franchise.trim().isEmpty
        ? teamFranchise
        : franchise.trim();
    final cleanSuffix = suffix.trim().isEmpty ? teamSuffix : suffix.trim();
    final cleanAbbr = abbreviation.trim().isEmpty
        ? teamAbbreviation
        : abbreviation.trim().toUpperCase();
    final newName = '$cleanFranchise $cleanSuffix';

    teamFranchise = cleanFranchise;
    teamSuffix = cleanSuffix;
    teamAbbreviation = cleanAbbr;

    userTeam = userTeam.copyWith(
      name: newName,
      shortName: cleanAbbr,
      branding: branding,
    );

    standings = standings
        .map((s) => s.name == oldName ? s.copyWith(name: newName) : s)
        .toList();

    statusBanner = 'Franchise identity updated to $newName.';
    _log('Updated franchise branding and identity.');
    notifyListeners();
  }

  void chooseFranchiseFromTemplate(String teamName) {
    final branding = defaultTeamBrandings[teamName];
    if (branding == null) {
      statusBanner = 'Unknown franchise template: $teamName';
      notifyListeners();
      return;
    }

    final split = _splitFranchise(teamName);
    teamFranchise = split.$1;
    teamSuffix = split.$2;
    teamAbbreviation = teamName
        .split(RegExp(r'\\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(3)
        .join()
        .toUpperCase();

    userTeam = userTeam.copyWith(
      name: teamName,
      shortName: teamAbbreviation,
      branding: branding,
      morale: (userTeam.morale + 2).clamp(30, 99),
    );

    standings = _seed.createStandings(teamName);
    fixtures = _seed.createFixtures(teamName);
    statusBanner = '$teamName selected. The franchise awaits, Chairman.';
    notifyListeners();
  }

  void setClubCaptain(String playerId) {
    final exists = userTeam.squad.any((p) => p.id == playerId);
    if (!exists) return;
    clubCaptainId = playerId;
    final captain = clubCaptain;
    if (captain != null) {
      statusBanner = '${captain.name} confirmed as club captain.';
      _unlockAchievement(
        id: 'captain_selected',
        title: 'Armband Ready',
        description: '${captain.name} was appointed club captain.',
      );
    }
    notifyListeners();
  }

  List<Player> _buildOpponentXI(String opponent) {
    final players = <Player>[];
    for (var i = 0; i < 11; i++) {
      PlayerRole? forceRole;
      if (i < 2) forceRole = PlayerRole.opener;
      if (i == 2 || i == 3) forceRole = PlayerRole.anchor;
      if (i == 4) forceRole = PlayerRole.wicketKeeper;
      if (i >= 5 && i <= 7) forceRole = PlayerRole.allRounder;
      if (i >= 8 && i <= 9) forceRole = PlayerRole.pacer;
      if (i == 10) forceRole = PlayerRole.spinner;
      players.add(
        _seed.createPlayer(
          id: '$opponent-$i',
          forceRole: forceRole,
          inXI: true,
        ),
      );
    }
    return players;
  }

  void startNextMatch() {
    if (fired) {
      statusBanner = 'You were fired by the board. Restart your career.';
      notifyListeners();
      return;
    }

    final fixture = nextFixture;
    if (fixture == null) {
      statusBanner = 'No fixtures left in this season.';
      notifyListeners();
      return;
    }

    final xi = playingXI;
    if (xi.length < 11) {
      statusBanner = 'You need at least 11 fit players.';
      notifyListeners();
      return;
    }

    latestResult = null;
    _resultCommitted = false;
    autoPlay = false;

    final benchCandidates = impactBenchCandidates;
    final selectedImpact =
        (selectedImpactPlayer != null &&
            !selectedImpactPlayer!.inPlayingXI &&
            !selectedImpactPlayer!.injured)
        ? selectedImpactPlayer
        : (benchCandidates.isNotEmpty ? benchCandidates.first : null);
    impactCandidateId ??= selectedImpact?.id;
    final aiImpact = _seed.createPlayer(
      id: 'ai-impact-${fixture.round}',
      inXI: false,
    );

    liveMatch = LiveMatchEngine(
      format: matchFormat,
      userXI: xi,
      aiXI: _buildOpponentXI(fixture.opponent),
      userTeamName: userTeam.name,
      aiTeamName: fixture.opponent,
      userImpactPlayer: selectedImpact,
      aiImpactPlayer: aiImpact,
      random: _random,
    );

    statusBanner =
        'Round ${fixture.round}: ${fixture.home ? 'Home' : 'Away'} vs ${fixture.opponent}. '
        'Impact: ${selectedImpact?.name ?? 'None selected'}';
    notifyListeners();
  }

  void stepBall() {
    final match = liveMatch;
    if (match == null) {
      statusBanner = 'Start a match first.';
      notifyListeners();
      return;
    }

    match.stepBall();
    if (match.completed && !_resultCommitted) {
      _commitMatchResult();
    }

    notifyListeners();
  }

  void toggleAutoPlay() {
    final match = liveMatch;
    if (match == null || match.completed) {
      return;
    }

    autoPlay = !autoPlay;
    _autoTimer?.cancel();

    if (autoPlay) {
      _autoTimer = Timer.periodic(const Duration(milliseconds: 240), (_) {
        if (liveMatch == null || liveMatch!.completed) {
          autoPlay = false;
          _autoTimer?.cancel();
          notifyListeners();
          return;
        }
        stepBall();
      });
    }

    notifyListeners();
  }

  void setAggression(double aggression) {
    if (liveMatch == null || liveMatch!.completed) return;
    liveMatch!.aggression = aggression.clamp(0.15, 0.92);
    notifyListeners();
  }

  void activateImpactPlayer() {
    final match = liveMatch;
    if (match == null || match.completed) {
      statusBanner = 'No active match for impact substitution.';
      notifyListeners();
      return;
    }

    final event = match.activateUserImpactPlayer();
    if (event == null) {
      statusBanner =
          'Impact sub unavailable now. Use it earlier in the innings.';
      notifyListeners();
      return;
    }

    match.timeline.insert(0, event);
    if (match.timeline.length > 30) {
      match.timeline.removeLast();
    }
    statusBanner = event.description;
    _log(event.description);
    notifyListeners();
  }

  void _commitMatchResult() {
    final match = liveMatch;
    if (match == null || _resultCommitted == true) return;

    final result = match.buildResult();
    latestResult = result;
    _resultCommitted = true;
    autoPlay = false;
    _autoTimer?.cancel();

    final fixture = nextFixture;
    if (fixture != null) {
      final updatedFixture = fixture.copyWith(
        played: true,
        resultSummary: result.summary,
        won: result.userWon,
      );
      final idx = fixtures.indexOf(fixture);
      fixtures[idx] = updatedFixture;
    }

    _applyMatchImpact(result);
    _evaluateMatchAchievements(result);
    _updateObjectives();
    _log('Round $matchesPlayed: ${result.summary}');
    statusBanner = result.summary;

    if (seasonComplete) {
      _finishSeasonObjectives();
    }
  }

  void _evaluateMatchAchievements(MatchResult result) {
    if (result.userWon && userTeam.wins == 1) {
      _unlockAchievement(
        id: 'first_win',
        title: 'First Blood',
        description: 'Won your first league match as chairman.',
      );
    }

    if (result.userInnings.runs >= 200) {
      _unlockAchievement(
        id: 'score_200',
        title: 'Double Tonne',
        description: 'Posted 200+ in a league innings.',
      );
    }

    final userTop = result.userInnings.battingCard.isEmpty
        ? null
        : (List<BattingEntry>.of(
            result.userInnings.battingCard,
          )..sort((a, b) => b.runs.compareTo(a.runs))).first;
    if (userTop != null && userTop.runs >= 100) {
      _unlockAchievement(
        id: 'centurion',
        title: 'Centurion',
        description: '${userTop.name} scored a century.',
      );
    } else if (userTop != null && userTop.runs >= 50) {
      _unlockAchievement(
        id: 'half_century',
        title: 'Anchor Point',
        description: '${userTop.name} completed a fifty.',
      );
    }

    final goldenDuck = result.userInnings.battingCard.any(
      (entry) => entry.out && entry.runs == 0 && entry.balls == 1,
    );
    if (goldenDuck) {
      _unlockAchievement(
        id: 'golden_duck',
        title: 'Golden Duck',
        description: 'A user-team batter fell first ball.',
      );
    }
  }

  void _applyMatchImpact(MatchResult result) {
    final userRuns = result.userInnings.runs;
    final aiRuns = result.aiInnings.runs;

    final margin = (userRuns - aiRuns).abs();
    final nrrDelta =
        ((userRuns - aiRuns) / max(120, matchFormat.oversPerInnings * 6)).clamp(
          -0.4,
          0.4,
        );

    userTeam = userTeam.copyWith(
      wins: userTeam.wins + (result.userWon ? 1 : 0),
      losses: userTeam.losses + (result.userWon ? 0 : 1),
      points: userTeam.points + (result.userWon ? 2 : 0),
      netRunRate: userTeam.netRunRate + nrrDelta,
      morale: (userTeam.morale + (result.userWon ? 4 : -3)).clamp(30, 99),
    );
    _addFanMovement('Match Results', result.userWon ? 4200 : 1300);
    if (margin >= 20) {
      _addFanMovement('Rivalry Swings', 1400 + margin * 3);
    }

    final ticketRevenue =
        (2.2 + (result.userWon ? 0.7 : 0.2) + (userTeam.sponsorLevel * 0.25));
    final sponsorRevenue = userTeam.sponsorLevel * 0.55;
    final wageCost = 1.8;
    final infraCost = 0.5 * userTeam.infraLevel;
    final matchBonus = result.userWon ? 1.0 : 0.0;
    final net =
        ticketRevenue + sponsorRevenue + matchBonus - wageCost - infraCost;
    fanRevenueSeasonCr += ticketRevenue;
    fanRevenueCareerCr += ticketRevenue;

    userTeam = userTeam.copyWith(cashCr: (userTeam.cashCr + net));

    _addFinance('Matchday revenue', ticketRevenue + sponsorRevenue, 'income');
    _addFinance('Player and operation wages', -wageCost - infraCost, 'expense');
    if (matchBonus > 0) {
      _addFinance('Win bonus', matchBonus, 'income');
    }

    _updateStandings(result.userWon, nrrDelta, margin);
    _updateRecordBook(result, nrrDelta);
  }

  void _updateStandings(bool userWon, double nrrDelta, int margin) {
    final userIdx = standings.indexWhere((s) => s.name == userTeam.name);
    if (userIdx != -1) {
      final userStanding = standings[userIdx];
      standings[userIdx] = userStanding.copyWith(
        played: userStanding.played + 1,
        wins: userStanding.wins + (userWon ? 1 : 0),
        losses: userStanding.losses + (userWon ? 0 : 1),
        points: userStanding.points + (userWon ? 2 : 0),
        netRunRate: userStanding.netRunRate + nrrDelta,
      );
    }

    final fixture = fixtures[matchesPlayed - 1];
    final oppIdx = standings.indexWhere((s) => s.name == fixture.opponent);
    if (oppIdx != -1) {
      final oppStanding = standings[oppIdx];
      standings[oppIdx] = oppStanding.copyWith(
        played: oppStanding.played + 1,
        wins: oppStanding.wins + (userWon ? 0 : 1),
        losses: oppStanding.losses + (userWon ? 1 : 0),
        points: oppStanding.points + (userWon ? 0 : 2),
        netRunRate: oppStanding.netRunRate - nrrDelta,
      );
    }

    // Simulate other league games for realism.
    for (var i = 0; i < standings.length; i++) {
      if (i == userIdx || i == oppIdx) continue;
      if (_random.nextDouble() < 0.22) {
        final team = standings[i];
        final won = _random.nextBool();
        standings[i] = team.copyWith(
          played: team.played + 1,
          wins: team.wins + (won ? 1 : 0),
          losses: team.losses + (won ? 0 : 1),
          points: team.points + (won ? 2 : 0),
          netRunRate: team.netRunRate + (_random.nextDouble() * 0.14 - 0.07),
        );
      }
    }
  }

  void _finishSeasonObjectives() {
    final sorted = List<TeamStanding>.of(standings)
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        return b.netRunRate.compareTo(a.netRunRate);
      });

    final rank = sorted.indexWhere((s) => s.name == userTeam.name) + 1;
    final top4Achieved = rank > 0 && rank <= 4;

    objectives = objectives.map((o) {
      if (o.id == 'top4') {
        return o.copyWith(current: top4Achieved ? 1 : 0);
      }
      return o;
    }).toList();

    final completedObjectives = objectives.where((o) => o.completed).length;

    if (rank == 1) {
      userTeam = userTeam.copyWith(
        trophies: userTeam.trophies + 1,
        cashCr: userTeam.cashCr + 8.5,
        morale: (userTeam.morale + 8).clamp(30, 99),
      );
      _addFanMovement('Championship', 8200);
      _addFinance('League champion prize', 8.5, 'income');
      _unlockAchievement(
        id: 'league_title',
        title: 'Silverware',
        description: 'Finished first and won the league title.',
      );
      _log('Season $seasonYear ended: Champions.');
      statusBanner = 'Season complete. You finished #1 and won the title.';
    } else {
      _addFanMovement(
        'Season Finish',
        rank <= 4 ? 4600 : (rank <= 6 ? 1400 : -2200),
      );
      _log('Season $seasonYear ended: finished #$rank.');
      statusBanner = 'Season complete. Final rank: #$rank.';
    }

    if (completedObjectives <= 1) {
      fired = true;
      _log('Board decision: Contract terminated due to missed objectives.');
      statusBanner =
          'Board terminated your contract after season review. Restart career.';
    } else if (completedObjectives == 2) {
      _log('Board decision: Final warning issued.');
      statusBanner = '$statusBanner Board issued a final warning.';
    } else if (completedObjectives >= 4) {
      _unlockAchievement(
        id: 'perfect_board',
        title: 'Board Favorite',
        description: 'Completed every board objective in a season.',
      );
    }

    notifyListeners();
  }

  void refreshAuctionRoom() {
    if (liveMatch != null && !liveMatch!.completed) {
      statusBanner = 'Cannot open auction while a match is active.';
      notifyListeners();
      return;
    }
    auctionLots = _seed.createAuctionLots();
    statusBanner = 'Mini-auction room refreshed.';
    notifyListeners();
  }

  void placeBid(String lotId) {
    final idx = auctionLots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return;
    final lot = auctionLots[idx];
    if (lot.closed) return;

    final userBid = lot.currentBidCr + 0.2;
    if (userTeam.cashCr < userBid) {
      statusBanner = 'Insufficient purse to place bid.';
      notifyListeners();
      return;
    }

    var updatedLot = lot.copyWith(currentBidCr: userBid, highestBidder: 'You');

    final aiTeams = standings
        .map((s) => s.name)
        .where((name) => name != userTeam.name)
        .toList();

    var active = _random.nextDouble() < 0.55;
    var loops = 0;
    while (active && loops < 3) {
      loops++;
      final aiBid = updatedLot.currentBidCr + 0.2;
      if (aiBid > updatedLot.player.marketValueCr + 1.4) break;
      final ai = aiTeams[_random.nextInt(aiTeams.length)];
      updatedLot = updatedLot.copyWith(currentBidCr: aiBid, highestBidder: ai);
      active = _random.nextDouble() < 0.45;
    }

    auctionLots[idx] = updatedLot;
    statusBanner =
        '${updatedLot.player.name} now at ₹${updatedLot.currentBidCr.toStringAsFixed(1)} Cr (${updatedLot.highestBidder}).';
    notifyListeners();
  }

  void finalizeLot(String lotId) {
    final idx = auctionLots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return;

    final lot = auctionLots[idx];
    if (lot.closed) return;

    if (lot.highestBidder != 'You') {
      auctionLots[idx] = lot.copyWith(closed: true, soldToUser: false);
      statusBanner = '${lot.player.name} sold to ${lot.highestBidder}.';
      notifyListeners();
      return;
    }

    if (userTeam.cashCr < lot.currentBidCr) {
      statusBanner = 'Purse too low to complete signing.';
      notifyListeners();
      return;
    }

    var squad = List<Player>.of(userTeam.squad);
    final signedPlayer = lot.player.copyWith(inPlayingXI: false);

    if (squad.length >= 22) {
      squad.sort((a, b) => a.overall.compareTo(b.overall));
      final removed = squad.removeAt(0);
      _log('Released ${removed.name} to register ${signedPlayer.name}.');
    }

    squad.add(signedPlayer);
    userTeam = userTeam.copyWith(
      cashCr: userTeam.cashCr - lot.currentBidCr,
      squad: squad,
    );

    if (signedPlayer.age <= 23) {
      youthSignings += 1;
    }

    auctionLots[idx] = lot.copyWith(closed: true, soldToUser: true);
    _addFinance(
      'Auction signing: ${signedPlayer.name}',
      -lot.currentBidCr,
      'transfer',
    );
    _log(
      'Signed ${signedPlayer.name} for ₹${lot.currentBidCr.toStringAsFixed(1)} Cr.',
    );
    _addFanMovement('Star Signings', 2200 + signedPlayer.overall * 12);
    _updateObjectives();
    statusBanner = 'Signed ${signedPlayer.name}.';
    notifyListeners();
  }

  void trainPlayer(String playerId, String focus) {
    if (userTeam.cashCr < 0.35) {
      statusBanner = 'Need at least ₹0.35 Cr for one training block.';
      notifyListeners();
      return;
    }

    final idx = userTeam.squad.indexWhere((p) => p.id == playerId);
    if (idx == -1) return;

    final player = userTeam.squad[idx];
    int hitting = player.hitting;
    int anchoring = player.anchoring;
    int bowling = player.bowling;
    int pressure = player.pressure;
    int form = player.form;
    int fitness = player.fitness;

    switch (focus) {
      case 'Batting':
        hitting = (hitting + 2).clamp(30, 99);
        anchoring = (anchoring + 1).clamp(30, 99);
        break;
      case 'Bowling':
        bowling = (bowling + 2).clamp(30, 99);
        break;
      case 'Mental':
        pressure = (pressure + 2).clamp(30, 99);
        break;
      case 'Fitness':
        fitness = (fitness + 2).clamp(30, 99);
        break;
    }

    form = (form + 1).clamp(30, 99);
    final overall =
        ((hitting +
                    anchoring +
                    bowling +
                    player.economySkill +
                    pressure +
                    fitness +
                    form) /
                7)
            .round();

    final updated = player.copyWith(
      hitting: hitting,
      anchoring: anchoring,
      bowling: bowling,
      pressure: pressure,
      form: form,
      fitness: fitness,
      overall: overall,
    );

    final updatedSquad = List<Player>.of(userTeam.squad);
    updatedSquad[idx] = updated;

    userTeam = userTeam.copyWith(
      squad: updatedSquad,
      cashCr: userTeam.cashCr - 0.35,
    );

    _addFinance(
      'Training block ($focus): ${player.name}',
      -0.35,
      'development',
    );
    statusBanner = '${player.name} completed $focus training.';
    notifyListeners();
  }

  void togglePlayingXI(String playerId) {
    final idx = userTeam.squad.indexWhere((p) => p.id == playerId);
    if (idx == -1) return;

    final player = userTeam.squad[idx];
    final currentXI = userTeam.squad.where((p) => p.inPlayingXI).length;

    if (player.inPlayingXI && currentXI <= 11) {
      statusBanner = 'Playing XI must have at least 11 players.';
      notifyListeners();
      return;
    }

    if (!player.inPlayingXI && currentXI >= 11) {
      statusBanner = 'Playing XI already has 11 players. Bench someone first.';
      notifyListeners();
      return;
    }

    final updatedSquad = List<Player>.of(userTeam.squad);
    updatedSquad[idx] = player.copyWith(inPlayingXI: !player.inPlayingXI);
    userTeam = userTeam.copyWith(squad: updatedSquad);

    statusBanner = player.inPlayingXI
        ? '${player.name} moved to bench.'
        : '${player.name} moved to playing XI.';
    notifyListeners();
  }

  void runMarketingCampaign() {
    const cost = 2.8;
    if (userTeam.cashCr < cost) {
      statusBanner = 'Not enough cash for campaign.';
      notifyListeners();
      return;
    }

    final fanBoost = 4500 + _random.nextInt(2500);
    userTeam = userTeam.copyWith(cashCr: userTeam.cashCr - cost);
    _addFanMovement('Star Signings', fanBoost ~/ 2);
    _addFanMovement('Match Results', fanBoost ~/ 2);
    _addFinance('Marketing campaign', -cost, 'marketing');
    statusBanner = 'Campaign finished: +$fanBoost fans.';
    _updateObjectives();
    notifyListeners();
  }

  void upgradeAcademy() {
    if (academyLevel >= academyMaxLevel) {
      statusBanner = 'Academy is already at maximum level.';
      notifyListeners();
      return;
    }
    final cost = academyUpgradeCost;
    if (userTeam.cashCr < cost) {
      statusBanner =
          'Need ₹${cost.toStringAsFixed(1)} Cr to upgrade academy tier.';
      notifyListeners();
      return;
    }

    academyLevel += 1;
    userTeam = userTeam.copyWith(
      cashCr: userTeam.cashCr - cost,
      morale: (userTeam.morale + 1).clamp(30, 99),
    );
    youthAcademy = _createYouthAcademy();
    _addFinance(
      'Academy infrastructure upgrade (Tier $academyLevel)',
      -cost,
      'academy',
    );
    if (academyLevel >= 4) {
      _unlockAchievement(
        id: 'academy_architect',
        title: 'Academy Architect',
        description: 'Built a high-performance youth pathway.',
      );
    }
    statusBanner = 'Academy upgraded to $academyTierLabel.';
    notifyListeners();
  }

  void promoteYouthPlayer(String playerId) {
    final idx = youthAcademy.indexWhere((p) => p.id == playerId);
    if (idx == -1) return;
    final promotionCost = academyPromotionCost;
    if (userTeam.cashCr < promotionCost) {
      statusBanner =
          'Need ₹${promotionCost.toStringAsFixed(2)} Cr to promote an academy player.';
      notifyListeners();
      return;
    }

    final player = youthAcademy[idx];
    final promoted = player.copyWith(
      id: 'academy-${DateTime.now().millisecondsSinceEpoch}',
      age: player.age + 1,
      overall: (player.overall + 3 + academyLevel).clamp(40, 96),
      form: (player.form + 6).clamp(35, 99),
    );

    final squad = List<Player>.of(userTeam.squad);
    if (squad.length >= 22) {
      squad.sort((a, b) => a.overall.compareTo(b.overall));
      squad.removeAt(0);
    }
    squad.add(promoted);

    final updatedAcademy = List<Player>.of(youthAcademy)..removeAt(idx);
    updatedAcademy.addAll(_createYouthAcademy().take(1));

    youthAcademy = updatedAcademy;
    youthSignings += 1;
    userTeam = userTeam.copyWith(
      cashCr: userTeam.cashCr - promotionCost,
      squad: squad,
    );
    _addFinance('Youth promotion: ${promoted.name}', -promotionCost, 'academy');
    if (promoted.overall >= 82) {
      _unlockAchievement(
        id: 'future_icon',
        title: 'Future Icon',
        description: '${promoted.name} entered the first team at OVR 82+.',
      );
    }
    if (youthSignings >= 3) {
      _unlockAchievement(
        id: 'academy_pipeline',
        title: 'Academy Pipeline',
        description: 'Promoted 3 youth players in one career.',
      );
    }
    _log('Promoted academy player ${promoted.name}.');
    _updateObjectives();
    statusBanner = 'Academy talent ${promoted.name} promoted to senior squad.';
    notifyListeners();
  }

  void triggerDynamicEvent() {
    if (fired) return;
    final roll = _random.nextDouble();

    if (roll < 0.34) {
      final candidates = userTeam.squad
          .where((p) => p.inPlayingXI && !p.injured)
          .toList();
      if (candidates.isNotEmpty) {
        final injured = candidates[_random.nextInt(candidates.length)];
        final idx = userTeam.squad.indexWhere((p) => p.id == injured.id);
        final updated = List<Player>.of(userTeam.squad);
        updated[idx] = injured.copyWith(
          injured: true,
          fitness: (injured.fitness - 8).clamp(30, 99),
        );
        userTeam = userTeam.copyWith(
          squad: updated,
          morale: (userTeam.morale - 3).clamp(30, 99),
        );
        _log('Dynamic event: ${injured.name} picked up a minor injury.');
        statusBanner = 'Dynamic Event: ${injured.name} injured (2-3 matches).';
      }
    } else if (roll < 0.67) {
      final star = List<Player>.of(userTeam.squad)
        ..sort((a, b) => b.overall.compareTo(a.overall));
      if (star.isNotEmpty) {
        final top = star.first;
        userTeam = userTeam.copyWith(
          morale: (userTeam.morale - 5).clamp(30, 99),
          cashCr: userTeam.cashCr - 0.8,
        );
        _addFinance('Team dispute settlement', -0.8, 'discipline');
        _log(
          'Dynamic event: Locker-room issue around ${top.name}, resolved by management.',
        );
        statusBanner = 'Dynamic Event: Team dispute resolved with morale hit.';
      }
    } else {
      final veterans = userTeam.squad.where((p) => p.age >= 34).toList();
      if (veterans.isNotEmpty) {
        final retiring = veterans[_random.nextInt(veterans.length)];
        final updated = List<Player>.of(userTeam.squad)
          ..removeWhere((p) => p.id == retiring.id);
        userTeam = userTeam.copyWith(squad: updated);
        _log('Dynamic event: ${retiring.name} announced retirement.');
        statusBanner = 'Dynamic Event: ${retiring.name} retired.';
      } else {
        statusBanner = 'Dynamic Event: No major incidents this week.';
      }
    }

    notifyListeners();
  }

  void upgradeInfrastructure() {
    upgradeFacility('stadium');
  }

  void negotiateSponsor() {
    final requiredFans = 70000 + (userTeam.sponsorLevel * 8000);
    if (userTeam.fans < requiredFans) {
      statusBanner = 'Need $requiredFans fans to unlock next sponsor tier.';
      notifyListeners();
      return;
    }

    userTeam = userTeam.copyWith(
      sponsorLevel: userTeam.sponsorLevel + 1,
      cashCr: userTeam.cashCr + 4.2,
    );
    _addFinance('Sponsor renegotiation bonus', 4.2, 'sponsorship');
    _addFanMovement('Playoff Reputation', 2200);
    statusBanner = 'Sponsor upgraded to tier ${userTeam.sponsorLevel}.';
    notifyListeners();
  }

  int facilityLevel(String facilityId) {
    switch (facilityId) {
      case 'stadium':
        return stadiumLevel;
      case 'training':
        return trainingLevel;
      case 'medical':
        return medicalLevel;
      case 'scouting':
        return scoutingLevel;
      default:
        return 1;
    }
  }

  int facilityMaxLevel(String facilityId) {
    switch (facilityId) {
      case 'stadium':
        return 4;
      case 'training':
        return 3;
      case 'medical':
        return 3;
      case 'scouting':
        return 3;
      default:
        return 3;
    }
  }

  double facilityUpgradeCost(String facilityId) {
    final level = facilityLevel(facilityId);
    switch (facilityId) {
      case 'stadium':
        return 2.8 + level * 1.6;
      case 'training':
        return 2.2 + level * 1.4;
      case 'medical':
        return 1.8 + level * 1.2;
      case 'scouting':
        return 2.0 + level * 1.25;
      default:
        return 3.0;
    }
  }

  void upgradeFacility(String facilityId) {
    final level = facilityLevel(facilityId);
    final maxLevel = facilityMaxLevel(facilityId);
    if (level >= maxLevel) {
      statusBanner =
          '${facilityId[0].toUpperCase()}${facilityId.substring(1)} is maxed.';
      notifyListeners();
      return;
    }

    final cost = facilityUpgradeCost(facilityId);
    if (userTeam.cashCr < cost) {
      statusBanner = 'Need ₹${cost.toStringAsFixed(1)} Cr for this upgrade.';
      notifyListeners();
      return;
    }

    switch (facilityId) {
      case 'stadium':
        stadiumLevel += 1;
        _addFanMovement('League Position', 1200);
        break;
      case 'training':
        trainingLevel += 1;
        break;
      case 'medical':
        medicalLevel += 1;
        break;
      case 'scouting':
        scoutingLevel += 1;
        break;
    }

    userTeam = userTeam.copyWith(
      cashCr: userTeam.cashCr - cost,
      infraLevel: facilitiesCompositeLevel,
      morale: (userTeam.morale + 1).clamp(30, 99),
      squad: userTeam.squad
          .map(
            (p) => p.copyWith(
              fitness: (p.fitness + (facilityId == 'medical' ? 2 : 1)).clamp(
                30,
                99,
              ),
            ),
          )
          .toList(),
    );

    _addFinance('Facility upgrade: $facilityId', -cost, 'infrastructure');
    if (stadiumLevel == facilityMaxLevel('stadium') &&
        trainingLevel == facilityMaxLevel('training') &&
        medicalLevel == facilityMaxLevel('medical') &&
        scoutingLevel == facilityMaxLevel('scouting')) {
      _unlockAchievement(
        id: 'infra_master',
        title: 'Infrastructure Master',
        description: 'Maxed every club facility.',
      );
    }
    statusBanner =
        '$facilityId upgraded to level ${facilityLevel(facilityId)}.';
    notifyListeners();
  }

  void buyOwnersPack() {
    if (adsRemoved) {
      statusBanner = 'Owner\'s Pack already active.';
      notifyListeners();
      return;
    }

    adsRemoved = true;
    stadiumLevel = facilityMaxLevel('stadium');
    trainingLevel = facilityMaxLevel('training');
    medicalLevel = facilityMaxLevel('medical');
    scoutingLevel = facilityMaxLevel('scouting');
    userTeam = userTeam.copyWith(
      cashCr: userTeam.cashCr + 20,
      infraLevel: facilitiesCompositeLevel,
      morale: (userTeam.morale + 6).clamp(30, 99),
    );
    _addFanMovement('Playoff Reputation', 6000);
    _addFinance('Owner\'s Pack purchase', 0, 'iap');
    _addFinance('Owner\'s Pack bonus credit', 20, 'iap_bonus');
    _unlockAchievement(
      id: 'owners_pack',
      title: 'Owner Mode',
      description: 'Activated Owner\'s Pack and boosted the club.',
    );
    statusBanner = 'Owner\'s Pack activated. Facilities maxed + ₹20 Cr bonus.';
    notifyListeners();
  }

  void grantAuctionCash(double amountCr, {String source = 'Cash Pack'}) {
    if (amountCr <= 0) return;
    userTeam = userTeam.copyWith(cashCr: userTeam.cashCr + amountCr);
    _addFinance('$source credit', amountCr, 'iap_bonus');
    statusBanner = 'Purchase credited: +₹${amountCr.toStringAsFixed(1)} Cr.';
    notifyListeners();
  }

  void advanceSeason() {
    if (!seasonComplete) {
      statusBanner = 'Finish all fixtures before advancing season.';
      notifyListeners();
      return;
    }

    seasonYear += 1;
    youthSignings = 0;
    impactCandidateId = null;

    final rolloverCash = userTeam.cashCr + 6.5;
    final refreshedSquad = userTeam.squad.map((p) {
      final age = p.age + 1;
      final ageDrop = age >= 33 ? 2 : 0;
      final refreshedForm = (p.form + _random.nextInt(7) - 3).clamp(35, 96);
      final refreshedFitness = (p.fitness + _random.nextInt(7) - 4).clamp(
        35,
        96,
      );
      final overall = (p.overall - ageDrop).clamp(32, 98);
      return p.copyWith(
        age: age,
        form: refreshedForm,
        fitness: refreshedFitness,
        overall: overall,
        injured: _random.nextDouble() < 0.04,
      );
    }).toList();

    userTeam = userTeam.copyWith(
      wins: 0,
      losses: 0,
      points: 0,
      netRunRate: 0,
      cashCr: rolloverCash,
      squad: refreshedSquad,
    );

    standings = _seed.createStandings(userTeam.name);
    fixtures = _seed.createFixtures(userTeam.name);
    objectives = _defaultObjectives();
    youthAcademy = _createYouthAcademy();
    latestResult = null;
    liveMatch = null;
    _resultCommitted = false;
    fired = false;
    for (final key in fanMovementSeason.keys) {
      fanMovementSeason[key] = 0;
    }
    fanRevenueSeasonCr = 0;
    fanTrendSeason
      ..clear()
      ..add(userTeam.fans);

    if (seasonYear % 3 == 0) {
      auctionLots = _seed.createAuctionLots();
      _log('Mega auction triggered for season $seasonYear.');
      statusBanner = 'Season $seasonYear started. Mega auction is live.';
    } else {
      statusBanner = 'Season $seasonYear started.';
    }

    _log('Entered season $seasonYear.');
    notifyListeners();
  }

  void _updateObjectives() {
    objectives = objectives.map((objective) {
      switch (objective.id) {
        case 'wins':
          return objective.copyWith(current: userTeam.wins);
        case 'fans':
          return objective.copyWith(current: userTeam.fans ~/ 1000);
        case 'youth':
          return objective.copyWith(current: youthSignings);
        default:
          return objective;
      }
    }).toList();
  }

  void restartCareer() {
    _autoTimer?.cancel();
    autoPlay = false;
    liveMatch = null;
    latestResult = null;
    seasonYear = 2026;
    youthSignings = 0;
    fired = false;
    impactCandidateId = null;
    clubCaptainId = null;
    adsRemoved = false;
    stadiumLevel = 1;
    trainingLevel = 1;
    medicalLevel = 1;
    scoutingLevel = 1;
    academyLevel = 1;
    _unlockedAchievements.clear();
    _achievementQueue.clear();
    for (final key in fanMovementSeason.keys) {
      fanMovementSeason[key] = 0;
    }
    fanTrendCareer.clear();
    fanTrendSeason.clear();
    fanRevenueSeasonCr = 0;
    fanRevenueCareerCr = 0;
    for (final key in _recordBook.keys) {
      _recordBook[key] = const _RecordEntry();
    }
    _initialize();
    statusBanner = 'New career started.';
    notifyListeners();
  }

  void _updateRecordBook(MatchResult result, double nrrDelta) {
    final userRuns = result.userInnings.runs;
    final aiRuns = result.aiInnings.runs;
    final opponentName = result.aiInnings.teamName == userTeam.name
        ? result.userInnings.teamName
        : result.aiInnings.teamName;
    final winner = result.userWon ? userTeam.name : opponentName;

    final highestTotal = max(userRuns, aiRuns);
    _setRecord(
      key: 'Highest Team Total',
      metric: highestTotal,
      valueLabel: '$highestTotal',
      holder: highestTotal == userRuns ? userTeam.name : opponentName,
    );

    if (result.userWon && result.userInnings.runs >= result.aiInnings.runs) {
      _setRecord(
        key: 'Best Successful Chase',
        metric: result.userInnings.runs,
        valueLabel: '${result.userInnings.runs}',
        holder: userTeam.name,
      );
      final wkts = 10 - result.userInnings.wickets;
      _setRecord(
        key: 'Biggest Win (Wkts)',
        metric: wkts,
        valueLabel: '$wkts',
        holder: userTeam.name,
      );
    } else if (!result.userWon &&
        result.aiInnings.runs >= result.userInnings.runs) {
      final wkts = 10 - result.aiInnings.wickets;
      _setRecord(
        key: 'Biggest Win (Wkts)',
        metric: wkts,
        valueLabel: '$wkts',
        holder: winner,
      );
    } else {
      final runMargin = (userRuns - aiRuns).abs();
      _setRecord(
        key: 'Biggest Win (Runs)',
        metric: runMargin,
        valueLabel: '$runMargin',
        holder: winner,
      );
    }

    _setRecord(
      key: 'Best NRR Swing',
      metric: (nrrDelta.abs() * 1000).round(),
      valueLabel: nrrDelta.abs().toStringAsFixed(2),
      holder: userTeam.name,
    );
  }

  void _setRecord({
    required String key,
    required int metric,
    required String valueLabel,
    required String holder,
  }) {
    final entry = _recordBook[key];
    if (entry == null) return;
    if (metric <= entry.metric) return;
    _recordBook[key] = _RecordEntry(
      metric: metric,
      displayValue: valueLabel,
      holder: holder,
      season: seasonYear,
    );
  }

  void _unlockAchievement({
    required String id,
    required String title,
    required String description,
  }) {
    if (_unlockedAchievements.containsKey(id)) return;
    final achievement = UnlockedAchievement(
      id: id,
      title: title,
      description: description,
      unlockedAt: DateTime.now(),
    );
    _unlockedAchievements[id] = achievement;
    _achievementQueue.add(achievement);
    _log('Achievement unlocked: $title');
  }

  void _addFanMovement(String reason, int delta) {
    if (!fanMovementSeason.containsKey(reason)) return;
    fanMovementSeason[reason] = (fanMovementSeason[reason] ?? 0) + delta;
    userTeam = userTeam.copyWith(
      fans: (userTeam.fans + delta).clamp(12000, 950000).toInt(),
    );
    fanTrendCareer.add(userTeam.fans);
    fanTrendSeason.add(userTeam.fans);
    if (fanTrendCareer.length > 200) {
      fanTrendCareer.removeAt(0);
    }
    if (fanTrendSeason.length > 80) {
      fanTrendSeason.removeAt(0);
    }
  }

  (String, String) _splitFranchise(String teamName) {
    final parts = teamName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return (teamName, '');
    }
    final franchise = parts.take(parts.length - 1).join(' ');
    final suffix = parts.last;
    return (franchise, suffix);
  }

  void _addFinance(String title, double amountCr, String type) {
    financeLedger.insert(
      0,
      FinanceEntry(
        timestamp: DateTime.now(),
        title: title,
        amountCr: amountCr,
        type: type,
      ),
    );

    if (financeLedger.length > 60) {
      financeLedger.removeLast();
    }
  }

  void _log(String message) {
    careerLog.insert(0, message);
    if (careerLog.length > 100) {
      careerLog.removeLast();
    }
  }
}

class _RecordEntry {
  const _RecordEntry({
    this.metric = 0,
    this.displayValue = '-',
    this.holder = '-',
    this.season = 0,
  });

  final int metric;
  final String displayValue;
  final String holder;
  final int season;
}
