import 'dart:math';

import 'models.dart';

class SeedFactory {
  SeedFactory(this._random);

  final Random _random;

  static const List<String> clubNames = <String>[
    'Mumbai Meteors',
    'Delhi Dynamos',
    'Bengal Blazers',
    'Chennai Cyclones',
    'Punjab Pulse',
    'Hyderabad Hawks',
    'Rajasthan Royalsmiths',
    'Lucknow Legends',
    'Gujarat Gladiators',
    'Kolkata Kingsguard',
  ];

  static const List<String> firstNames = <String>[
    'Arjun',
    'Vikram',
    'Rohan',
    'Kabir',
    'Ishan',
    'Dev',
    'Yash',
    'Pranav',
    'Hardik',
    'Nikhil',
    'Ravi',
    'Samar',
    'Harsh',
    'Aditya',
    'Karan',
    'Farhan',
    'Rehan',
    'Aman',
    'Shiv',
    'Tarun',
    'Naman',
    'Udit',
    'Mihir',
    'Rahul',
    'Virat',
    'Shrey',
    'Deep',
    'Manav',
    'Laksh',
    'Tushar',
  ];

  static const List<String> lastNames = <String>[
    'Sharma',
    'Patel',
    'Khan',
    'Iyer',
    'Mehta',
    'Yadav',
    'Rana',
    'Gill',
    'Saini',
    'Bisht',
    'Tripathi',
    'Nair',
    'Joshi',
    'Kapoor',
    'Verma',
    'Singh',
    'Das',
    'Malik',
    'Reddy',
    'Chopra',
  ];

  static const List<PlayerTrait> traitPool = <PlayerTrait>[
    PlayerTrait(
      name: 'Powerplay Punisher',
      description: 'Scores faster in field restriction overs.',
      boundaryBoost: 0.08,
      wicketRiskDelta: 0.01,
      bowlingBoost: 0,
    ),
    PlayerTrait(
      name: 'Death Specialist',
      description: 'Improved yorkers in final overs.',
      boundaryBoost: 0,
      wicketRiskDelta: -0.01,
      bowlingBoost: 0.09,
    ),
    PlayerTrait(
      name: 'Calm Under Fire',
      description: 'Better control under pressure situations.',
      boundaryBoost: 0.03,
      wicketRiskDelta: -0.02,
      bowlingBoost: 0.03,
    ),
    PlayerTrait(
      name: 'Spin Reader',
      description: 'Excellent strike rotation against spin.',
      boundaryBoost: 0.04,
      wicketRiskDelta: -0.01,
      bowlingBoost: 0,
    ),
    PlayerTrait(
      name: 'Hit-the-Deck',
      description: 'Generates extra bounce with pace.',
      boundaryBoost: 0,
      wicketRiskDelta: 0,
      bowlingBoost: 0.07,
    ),
  ];

  String randomName() {
    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  PlayerRole randomRole() {
    const roles = PlayerRole.values;
    return roles[_random.nextInt(roles.length)];
  }

  List<PlayerTrait> randomTraits() {
    final count = _random.nextInt(2) + 1;
    final shuffled = List<PlayerTrait>.of(traitPool)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  Player createPlayer({required String id, PlayerRole? forceRole, bool? inXI}) {
    final role = forceRole ?? randomRole();
    final base = 58 + _random.nextInt(35);
    final hitting = _clamp(base + _random.nextInt(18) - 9);
    final anchoring = _clamp(base + _random.nextInt(18) - 9);
    final bowling = _clamp(base + _random.nextInt(20) - 10);
    final economy = _clamp(base + _random.nextInt(18) - 9);
    final pressure = _clamp(base + _random.nextInt(16) - 8);
    final fitness = _clamp(64 + _random.nextInt(33));
    final form = _clamp(58 + _random.nextInt(36));
    final overall =
        ((hitting + anchoring + bowling + economy + pressure + fitness + form) /
                7)
            .round();

    return Player(
      id: id,
      name: randomName(),
      age: 19 + _random.nextInt(16),
      role: role,
      overall: overall,
      hitting: hitting,
      anchoring: anchoring,
      bowling: bowling,
      economySkill: economy,
      pressure: pressure,
      fitness: fitness,
      form: form,
      salaryCr: (0.6 + _random.nextDouble() * 3.9),
      marketValueCr: (0.8 + _random.nextDouble() * 5.2),
      overseas: _random.nextDouble() < 0.22,
      injured: false,
      inPlayingXI: inXI ?? false,
      traits: randomTraits(),
    );
  }

  TeamProfile createUserTeam() {
    final players = List<Player>.generate(
      18,
      (int i) => createPlayer(id: 'user-$i', inXI: i < 11),
    );

    return TeamProfile(
      name: 'My Franchise',
      shortName: 'MYF',
      squad: players,
      cashCr: 100,
      fans: 64000,
      sponsorLevel: 1,
      infraLevel: 1,
      morale: 72,
      wins: 0,
      losses: 0,
      points: 0,
      netRunRate: 0,
      trophies: 0,
    );
  }

  List<TeamStanding> createStandings(String userTeamName) {
    return clubNames.map((String club) {
      if (club == userTeamName) {
        return const TeamStanding(
          name: 'My Franchise',
          played: 0,
          wins: 0,
          losses: 0,
          points: 0,
          netRunRate: 0,
        );
      }
      return TeamStanding(
        name: club,
        played: 0,
        wins: 0,
        losses: 0,
        points: 0,
        netRunRate: 0,
      );
    }).toList();
  }

  List<Fixture> createFixtures(String userTeamName) {
    final opponents = clubNames
        .where((String club) => club != userTeamName)
        .toList();
    final fixtures = <Fixture>[];
    var round = 1;
    for (final opponent in opponents) {
      fixtures.add(
        Fixture(
          round: round++,
          opponent: opponent,
          home: _random.nextBool(),
          played: false,
          resultSummary: null,
          won: null,
        ),
      );
    }
    for (final opponent in opponents) {
      fixtures.add(
        Fixture(
          round: round++,
          opponent: opponent,
          home: _random.nextBool(),
          played: false,
          resultSummary: null,
          won: null,
        ),
      );
    }
    return fixtures;
  }

  List<AuctionLot> createAuctionLots() {
    final lots = <AuctionLot>[];
    for (var i = 0; i < 12; i++) {
      final player = createPlayer(id: 'lot-$i');
      final basePrice = (0.4 + _random.nextDouble() * 2.6);
      lots.add(
        AuctionLot(
          id: 'lot-$i',
          player: player,
          basePriceCr: basePrice,
          currentBidCr: basePrice,
          highestBidder: 'Open',
          closed: false,
          soldToUser: false,
        ),
      );
    }
    return lots;
  }

  BoardObjective objective({
    required String id,
    required String title,
    required String description,
    required int target,
  }) {
    return BoardObjective(
      id: id,
      title: title,
      description: description,
      target: target,
      current: 0,
    );
  }

  int _clamp(int value) => value.clamp(30, 98);
}
