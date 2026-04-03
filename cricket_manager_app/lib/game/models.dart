import 'package:flutter/foundation.dart';

enum MatchFormat { t20, odi, test }

extension MatchFormatX on MatchFormat {
  String get label {
    switch (this) {
      case MatchFormat.t20:
        return 'T20';
      case MatchFormat.odi:
        return 'ODI';
      case MatchFormat.test:
        return 'Test';
    }
  }

  int get oversPerInnings {
    switch (this) {
      case MatchFormat.t20:
        return 20;
      case MatchFormat.odi:
        return 50;
      case MatchFormat.test:
        return 90;
    }
  }

  int get powerplayOvers {
    switch (this) {
      case MatchFormat.t20:
        return 6;
      case MatchFormat.odi:
        return 10;
      case MatchFormat.test:
        return 18;
    }
  }

  int get deathStartOvers {
    switch (this) {
      case MatchFormat.t20:
        return 16;
      case MatchFormat.odi:
        return 41;
      case MatchFormat.test:
        return 80;
    }
  }
}

enum PlayerRole {
  opener,
  anchor,
  finisher,
  allRounder,
  pacer,
  spinner,
  wicketKeeper,
}

extension PlayerRoleX on PlayerRole {
  String get label {
    switch (this) {
      case PlayerRole.opener:
        return 'Opener';
      case PlayerRole.anchor:
        return 'Anchor';
      case PlayerRole.finisher:
        return 'Finisher';
      case PlayerRole.allRounder:
        return 'All-Rounder';
      case PlayerRole.pacer:
        return 'Pacer';
      case PlayerRole.spinner:
        return 'Spinner';
      case PlayerRole.wicketKeeper:
        return 'Wicket Keeper';
    }
  }
}

enum TeamBadgeShape { circle, diamond, hexagon, pentagon, shield }

enum TeamBadgePattern { chevron, diagonal, band }

enum TeamBadgeEmblem { sword, star, bolt, crown, anchor }

@immutable
class TeamBranding {
  const TeamBranding({
    required this.shape,
    required this.pattern,
    required this.emblem,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  final TeamBadgeShape shape;
  final TeamBadgePattern pattern;
  final TeamBadgeEmblem emblem;
  final int primaryColor;
  final int secondaryColor;
  final int accentColor;

  TeamBranding copyWith({
    TeamBadgeShape? shape,
    TeamBadgePattern? pattern,
    TeamBadgeEmblem? emblem,
    int? primaryColor,
    int? secondaryColor,
    int? accentColor,
  }) {
    return TeamBranding(
      shape: shape ?? this.shape,
      pattern: pattern ?? this.pattern,
      emblem: emblem ?? this.emblem,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

@immutable
class PlayerTrait {
  const PlayerTrait({
    required this.name,
    required this.description,
    required this.boundaryBoost,
    required this.wicketRiskDelta,
    required this.bowlingBoost,
  });

  final String name;
  final String description;
  final double boundaryBoost;
  final double wicketRiskDelta;
  final double bowlingBoost;
}

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.overall,
    required this.hitting,
    required this.anchoring,
    required this.bowling,
    required this.economySkill,
    required this.pressure,
    required this.fitness,
    required this.form,
    required this.salaryCr,
    required this.marketValueCr,
    required this.overseas,
    required this.injured,
    required this.inPlayingXI,
    required this.traits,
  });

  final String id;
  final String name;
  final int age;
  final PlayerRole role;
  final int overall;
  final int hitting;
  final int anchoring;
  final int bowling;
  final int economySkill;
  final int pressure;
  final int fitness;
  final int form;
  final double salaryCr;
  final double marketValueCr;
  final bool overseas;
  final bool injured;
  final bool inPlayingXI;
  final List<PlayerTrait> traits;

  Player copyWith({
    String? id,
    String? name,
    int? age,
    PlayerRole? role,
    int? overall,
    int? hitting,
    int? anchoring,
    int? bowling,
    int? economySkill,
    int? pressure,
    int? fitness,
    int? form,
    double? salaryCr,
    double? marketValueCr,
    bool? overseas,
    bool? injured,
    bool? inPlayingXI,
    List<PlayerTrait>? traits,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      overall: overall ?? this.overall,
      hitting: hitting ?? this.hitting,
      anchoring: anchoring ?? this.anchoring,
      bowling: bowling ?? this.bowling,
      economySkill: economySkill ?? this.economySkill,
      pressure: pressure ?? this.pressure,
      fitness: fitness ?? this.fitness,
      form: form ?? this.form,
      salaryCr: salaryCr ?? this.salaryCr,
      marketValueCr: marketValueCr ?? this.marketValueCr,
      overseas: overseas ?? this.overseas,
      injured: injured ?? this.injured,
      inPlayingXI: inPlayingXI ?? this.inPlayingXI,
      traits: traits ?? this.traits,
    );
  }

  int get battingRating =>
      ((hitting * 0.5) + (anchoring * 0.25) + (pressure * 0.25)).round();

  int get bowlingRating =>
      ((bowling * 0.55) + (economySkill * 0.2) + (pressure * 0.25)).round();

  int get currentImpact =>
      ((overall * 0.4) + (form * 0.35) + (fitness * 0.25)).round();
}

@immutable
class TeamProfile {
  const TeamProfile({
    required this.name,
    required this.shortName,
    required this.branding,
    required this.squad,
    required this.cashCr,
    required this.fans,
    required this.sponsorLevel,
    required this.infraLevel,
    required this.morale,
    required this.wins,
    required this.losses,
    required this.points,
    required this.netRunRate,
    required this.trophies,
  });

  final String name;
  final String shortName;
  final TeamBranding branding;
  final List<Player> squad;
  final double cashCr;
  final int fans;
  final int sponsorLevel;
  final int infraLevel;
  final int morale;
  final int wins;
  final int losses;
  final int points;
  final double netRunRate;
  final int trophies;

  TeamProfile copyWith({
    String? name,
    String? shortName,
    TeamBranding? branding,
    List<Player>? squad,
    double? cashCr,
    int? fans,
    int? sponsorLevel,
    int? infraLevel,
    int? morale,
    int? wins,
    int? losses,
    int? points,
    double? netRunRate,
    int? trophies,
  }) {
    return TeamProfile(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      branding: branding ?? this.branding,
      squad: squad ?? this.squad,
      cashCr: cashCr ?? this.cashCr,
      fans: fans ?? this.fans,
      sponsorLevel: sponsorLevel ?? this.sponsorLevel,
      infraLevel: infraLevel ?? this.infraLevel,
      morale: morale ?? this.morale,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      points: points ?? this.points,
      netRunRate: netRunRate ?? this.netRunRate,
      trophies: trophies ?? this.trophies,
    );
  }
}

@immutable
class TeamRecord {
  const TeamRecord({
    required this.title,
    required this.value,
    required this.holder,
    required this.season,
  });

  final String title;
  final String value;
  final String holder;
  final int season;

  TeamRecord copyWith({
    String? title,
    String? value,
    String? holder,
    int? season,
  }) {
    return TeamRecord(
      title: title ?? this.title,
      value: value ?? this.value,
      holder: holder ?? this.holder,
      season: season ?? this.season,
    );
  }
}

@immutable
class TeamStanding {
  const TeamStanding({
    required this.name,
    required this.played,
    required this.wins,
    required this.losses,
    required this.points,
    required this.netRunRate,
  });

  final String name;
  final int played;
  final int wins;
  final int losses;
  final int points;
  final double netRunRate;

  TeamStanding copyWith({
    String? name,
    int? played,
    int? wins,
    int? losses,
    int? points,
    double? netRunRate,
  }) {
    return TeamStanding(
      name: name ?? this.name,
      played: played ?? this.played,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      points: points ?? this.points,
      netRunRate: netRunRate ?? this.netRunRate,
    );
  }
}

@immutable
class Fixture {
  const Fixture({
    required this.round,
    required this.opponent,
    required this.home,
    required this.played,
    required this.resultSummary,
    required this.won,
  });

  final int round;
  final String opponent;
  final bool home;
  final bool played;
  final String? resultSummary;
  final bool? won;

  Fixture copyWith({
    int? round,
    String? opponent,
    bool? home,
    bool? played,
    String? resultSummary,
    bool? won,
  }) {
    return Fixture(
      round: round ?? this.round,
      opponent: opponent ?? this.opponent,
      home: home ?? this.home,
      played: played ?? this.played,
      resultSummary: resultSummary ?? this.resultSummary,
      won: won ?? this.won,
    );
  }
}

@immutable
class FinanceEntry {
  const FinanceEntry({
    required this.timestamp,
    required this.title,
    required this.amountCr,
    required this.type,
  });

  final DateTime timestamp;
  final String title;
  final double amountCr;
  final String type;
}

@immutable
class BoardObjective {
  const BoardObjective({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.current,
  });

  final String id;
  final String title;
  final String description;
  final int target;
  final int current;

  bool get completed => current >= target;

  BoardObjective copyWith({
    String? id,
    String? title,
    String? description,
    int? target,
    int? current,
  }) {
    return BoardObjective(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      current: current ?? this.current,
    );
  }
}

@immutable
class AuctionLot {
  const AuctionLot({
    required this.id,
    required this.player,
    required this.basePriceCr,
    required this.currentBidCr,
    required this.highestBidder,
    required this.closed,
    required this.soldToUser,
  });

  final String id;
  final Player player;
  final double basePriceCr;
  final double currentBidCr;
  final String highestBidder;
  final bool closed;
  final bool soldToUser;

  AuctionLot copyWith({
    String? id,
    Player? player,
    double? basePriceCr,
    double? currentBidCr,
    String? highestBidder,
    bool? closed,
    bool? soldToUser,
  }) {
    return AuctionLot(
      id: id ?? this.id,
      player: player ?? this.player,
      basePriceCr: basePriceCr ?? this.basePriceCr,
      currentBidCr: currentBidCr ?? this.currentBidCr,
      highestBidder: highestBidder ?? this.highestBidder,
      closed: closed ?? this.closed,
      soldToUser: soldToUser ?? this.soldToUser,
    );
  }
}

@immutable
class MatchBallEvent {
  const MatchBallEvent({
    required this.overText,
    required this.description,
    required this.runs,
    required this.isWicket,
    required this.batter,
    required this.bowler,
  });

  final String overText;
  final String description;
  final int runs;
  final bool isWicket;
  final String batter;
  final String bowler;
}

@immutable
class BattingEntry {
  const BattingEntry({
    required this.name,
    required this.runs,
    required this.balls,
    required this.out,
  });

  final String name;
  final int runs;
  final int balls;
  final bool out;

  double get strikeRate => balls == 0 ? 0 : (runs * 100 / balls);
}

@immutable
class InningsSummary {
  const InningsSummary({
    required this.teamName,
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.battingCard,
  });

  final String teamName;
  final int runs;
  final int wickets;
  final int balls;
  final List<BattingEntry> battingCard;

  String get oversText => '${balls ~/ 6}.${balls % 6}';
}

@immutable
class MatchResult {
  const MatchResult({
    required this.userInnings,
    required this.aiInnings,
    required this.userWon,
    required this.summary,
  });

  final InningsSummary userInnings;
  final InningsSummary aiInnings;
  final bool userWon;
  final String summary;
}

class LiveInningsState {
  LiveInningsState({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.battingOrder,
    required this.maxBalls,
  });

  final String battingTeam;
  final String bowlingTeam;
  final List<Player> battingOrder;
  final int maxBalls;

  int runs = 0;
  int wickets = 0;
  int balls = 0;
  int strikerIndex = 0;
  int nonStrikerIndex = 1;
  int nextBatterIndex = 2;

  final Map<String, int> batterRuns = <String, int>{};
  final Map<String, int> batterBalls = <String, int>{};
  final Set<String> outBatters = <String>{};
  final List<int> runProgression = <int>[];
  final List<int> overRuns = <int>[];
  int currentOverRuns = 0;
  int boundaries = 0;
  int sixes = 0;
  int dots = 0;
  int singles = 0;
  int doubles = 0;
  int triples = 0;
  final Map<String, int> shotZones = <String, int>{
    'fine': 0,
    'square': 0,
    'cover': 0,
    'straight': 0,
    'midwicket': 0,
    'thirdman': 0,
  };

  bool get complete => wickets >= 10 || balls >= maxBalls;

  String get overText => '${balls ~/ 6}.${balls % 6}';

  Player get striker => battingOrder[strikerIndex];

  Player get nonStriker => battingOrder[nonStrikerIndex];

  double get runRate => balls == 0 ? 0 : (runs * 6.0 / balls);
}
