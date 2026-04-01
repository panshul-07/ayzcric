import 'dart:math';

import 'models.dart';

class SeedFactory {
  SeedFactory(this._random);

  final Random _random;

  static const List<String> clubNames = <String>[
    'Chennai Super Kings',
    'Delhi Capitals',
    'Gujarat Titans',
    'Kolkata Knight Riders',
    'Lucknow Super Giants',
    'Mumbai Indians',
    'Punjab Kings',
    'Rajasthan Royals',
    'Royal Challengers Bengaluru',
    'Sunrisers Hyderabad',
  ];

  static const Map<String, List<_KnownPlayerSeed>> _knownSquads = {
    'Chennai Super Kings': [
      _KnownPlayerSeed('Ruturaj Gaikwad', PlayerRole.opener, 88, false),
      _KnownPlayerSeed('Devon Conway', PlayerRole.opener, 85, true),
      _KnownPlayerSeed('Rachin Ravindra', PlayerRole.allRounder, 83, true),
      _KnownPlayerSeed('Rahul Tripathi', PlayerRole.anchor, 79, false),
      _KnownPlayerSeed('Shivam Dube', PlayerRole.finisher, 85, false),
      _KnownPlayerSeed('Ravindra Jadeja', PlayerRole.allRounder, 90, false),
      _KnownPlayerSeed('MS Dhoni', PlayerRole.wicketKeeper, 80, false),
      _KnownPlayerSeed('Ravichandran Ashwin', PlayerRole.spinner, 84, false),
      _KnownPlayerSeed('Noor Ahmad', PlayerRole.spinner, 84, true),
      _KnownPlayerSeed('Matheesha Pathirana', PlayerRole.pacer, 87, true),
      _KnownPlayerSeed('Khaleel Ahmed', PlayerRole.pacer, 80, false),
      _KnownPlayerSeed('Tushar Deshpande', PlayerRole.pacer, 77, false),
      _KnownPlayerSeed('Mukesh Choudhary', PlayerRole.pacer, 74, false),
      _KnownPlayerSeed('Sameer Rizvi', PlayerRole.finisher, 74, false),
    ],
    'Delhi Capitals': [
      _KnownPlayerSeed('KL Rahul', PlayerRole.wicketKeeper, 89, false),
      _KnownPlayerSeed('Jake Fraser-McGurk', PlayerRole.opener, 85, true),
      _KnownPlayerSeed('Faf du Plessis', PlayerRole.opener, 83, true),
      _KnownPlayerSeed('Tristan Stubbs', PlayerRole.finisher, 85, true),
      _KnownPlayerSeed('Axar Patel', PlayerRole.allRounder, 89, false),
      _KnownPlayerSeed('Kuldeep Yadav', PlayerRole.spinner, 88, false),
      _KnownPlayerSeed('Mitchell Starc', PlayerRole.pacer, 88, true),
      _KnownPlayerSeed('T Natarajan', PlayerRole.pacer, 82, false),
      _KnownPlayerSeed('Mukesh Kumar', PlayerRole.pacer, 79, false),
      _KnownPlayerSeed('Abishek Porel', PlayerRole.wicketKeeper, 76, false),
      _KnownPlayerSeed('Ashutosh Sharma', PlayerRole.finisher, 77, false),
      _KnownPlayerSeed('Karun Nair', PlayerRole.anchor, 74, false),
      _KnownPlayerSeed('Dushmantha Chameera', PlayerRole.pacer, 79, true),
      _KnownPlayerSeed('Lalit Yadav', PlayerRole.allRounder, 73, false),
    ],
    'Gujarat Titans': [
      _KnownPlayerSeed('Shubman Gill', PlayerRole.opener, 91, false),
      _KnownPlayerSeed('Sai Sudharsan', PlayerRole.anchor, 87, false),
      _KnownPlayerSeed('Jos Buttler', PlayerRole.wicketKeeper, 90, true),
      _KnownPlayerSeed('Rahul Tewatia', PlayerRole.finisher, 80, false),
      _KnownPlayerSeed('Shahrukh Khan', PlayerRole.finisher, 77, false),
      _KnownPlayerSeed('Rashid Khan', PlayerRole.spinner, 93, true),
      _KnownPlayerSeed('Mohammed Siraj', PlayerRole.pacer, 88, false),
      _KnownPlayerSeed('Prasidh Krishna', PlayerRole.pacer, 83, false),
      _KnownPlayerSeed('Kagiso Rabada', PlayerRole.pacer, 89, true),
      _KnownPlayerSeed('Washington Sundar', PlayerRole.allRounder, 81, false),
      _KnownPlayerSeed('R Sai Kishore', PlayerRole.spinner, 81, false),
      _KnownPlayerSeed('Sherfane Rutherford', PlayerRole.finisher, 80, true),
      _KnownPlayerSeed('Glenn Phillips', PlayerRole.allRounder, 81, true),
      _KnownPlayerSeed('Arshad Khan', PlayerRole.allRounder, 74, false),
    ],
    'Kolkata Knight Riders': [
      _KnownPlayerSeed('Sunil Narine', PlayerRole.allRounder, 91, true),
      _KnownPlayerSeed('Andre Russell', PlayerRole.allRounder, 90, true),
      _KnownPlayerSeed('Rinku Singh', PlayerRole.finisher, 86, false),
      _KnownPlayerSeed('Venkatesh Iyer', PlayerRole.allRounder, 85, false),
      _KnownPlayerSeed('Quinton de Kock', PlayerRole.wicketKeeper, 86, true),
      _KnownPlayerSeed('Ajinkya Rahane', PlayerRole.anchor, 80, false),
      _KnownPlayerSeed('Varun Chakaravarthy', PlayerRole.spinner, 89, false),
      _KnownPlayerSeed('Harshit Rana', PlayerRole.pacer, 84, false),
      _KnownPlayerSeed('Vaibhav Arora', PlayerRole.pacer, 77, false),
      _KnownPlayerSeed('Anrich Nortje', PlayerRole.pacer, 86, true),
      _KnownPlayerSeed('Ramandeep Singh', PlayerRole.allRounder, 78, false),
      _KnownPlayerSeed('Angkrish Raghuvanshi', PlayerRole.anchor, 76, false),
      _KnownPlayerSeed('Manish Pandey', PlayerRole.anchor, 74, false),
      _KnownPlayerSeed('Spencer Johnson', PlayerRole.pacer, 82, true),
    ],
    'Lucknow Super Giants': [
      _KnownPlayerSeed('Rishabh Pant', PlayerRole.wicketKeeper, 90, false),
      _KnownPlayerSeed('Nicholas Pooran', PlayerRole.wicketKeeper, 89, true),
      _KnownPlayerSeed('Aiden Markram', PlayerRole.allRounder, 84, true),
      _KnownPlayerSeed('Mitchell Marsh', PlayerRole.allRounder, 85, true),
      _KnownPlayerSeed('Ayush Badoni', PlayerRole.finisher, 79, false),
      _KnownPlayerSeed('David Miller', PlayerRole.finisher, 84, true),
      _KnownPlayerSeed('Ravi Bishnoi', PlayerRole.spinner, 87, false),
      _KnownPlayerSeed('Mayank Yadav', PlayerRole.pacer, 88, false),
      _KnownPlayerSeed('Avesh Khan', PlayerRole.pacer, 82, false),
      _KnownPlayerSeed('Mohsin Khan', PlayerRole.pacer, 80, false),
      _KnownPlayerSeed('Abdul Samad', PlayerRole.finisher, 76, false),
      _KnownPlayerSeed('Shahbaz Ahmed', PlayerRole.allRounder, 78, false),
      _KnownPlayerSeed('Akash Deep', PlayerRole.pacer, 79, false),
      _KnownPlayerSeed('M Siddharth', PlayerRole.spinner, 75, false),
    ],
    'Mumbai Indians': [
      _KnownPlayerSeed('Rohit Sharma', PlayerRole.opener, 89, false),
      _KnownPlayerSeed('Ryan Rickelton', PlayerRole.wicketKeeper, 82, true),
      _KnownPlayerSeed('Suryakumar Yadav', PlayerRole.anchor, 92, false),
      _KnownPlayerSeed('Tilak Varma', PlayerRole.anchor, 86, false),
      _KnownPlayerSeed('Hardik Pandya', PlayerRole.allRounder, 89, false),
      _KnownPlayerSeed('Naman Dhir', PlayerRole.finisher, 76, false),
      _KnownPlayerSeed('Jasprit Bumrah', PlayerRole.pacer, 96, false),
      _KnownPlayerSeed('Trent Boult', PlayerRole.pacer, 89, true),
      _KnownPlayerSeed('Deepak Chahar', PlayerRole.pacer, 82, false),
      _KnownPlayerSeed('Mitchell Santner', PlayerRole.allRounder, 82, true),
      _KnownPlayerSeed('Will Jacks', PlayerRole.allRounder, 83, true),
      _KnownPlayerSeed('Reece Topley', PlayerRole.pacer, 80, true),
      _KnownPlayerSeed('Arjun Tendulkar', PlayerRole.pacer, 72, false),
      _KnownPlayerSeed('Piyush Chawla', PlayerRole.spinner, 77, false),
    ],
    'Punjab Kings': [
      _KnownPlayerSeed('Shreyas Iyer', PlayerRole.anchor, 87, false),
      _KnownPlayerSeed('Prabhsimran Singh', PlayerRole.wicketKeeper, 80, false),
      _KnownPlayerSeed('Josh Inglis', PlayerRole.wicketKeeper, 82, true),
      _KnownPlayerSeed('Marcus Stoinis', PlayerRole.allRounder, 86, true),
      _KnownPlayerSeed('Glenn Maxwell', PlayerRole.allRounder, 84, true),
      _KnownPlayerSeed('Arshdeep Singh', PlayerRole.pacer, 88, false),
      _KnownPlayerSeed('Yuzvendra Chahal', PlayerRole.spinner, 89, false),
      _KnownPlayerSeed('Marco Jansen', PlayerRole.allRounder, 84, true),
      _KnownPlayerSeed('Nehal Wadhera', PlayerRole.anchor, 79, false),
      _KnownPlayerSeed('Shashank Singh', PlayerRole.finisher, 82, false),
      _KnownPlayerSeed('Harpreet Brar', PlayerRole.allRounder, 79, false),
      _KnownPlayerSeed('Lockie Ferguson', PlayerRole.pacer, 83, true),
      _KnownPlayerSeed('Azmatullah Omarzai', PlayerRole.allRounder, 81, true),
      _KnownPlayerSeed('Priyansh Arya', PlayerRole.opener, 74, false),
    ],
    'Rajasthan Royals': [
      _KnownPlayerSeed('Sanju Samson', PlayerRole.wicketKeeper, 89, false),
      _KnownPlayerSeed('Yashasvi Jaiswal', PlayerRole.opener, 90, false),
      _KnownPlayerSeed('Riyan Parag', PlayerRole.allRounder, 85, false),
      _KnownPlayerSeed('Dhruv Jurel', PlayerRole.wicketKeeper, 83, false),
      _KnownPlayerSeed('Shimron Hetmyer', PlayerRole.finisher, 85, true),
      _KnownPlayerSeed('Nitish Rana', PlayerRole.anchor, 80, false),
      _KnownPlayerSeed('Jofra Archer', PlayerRole.pacer, 87, true),
      _KnownPlayerSeed('Sandeep Sharma', PlayerRole.pacer, 80, false),
      _KnownPlayerSeed('Maheesh Theekshana', PlayerRole.spinner, 84, true),
      _KnownPlayerSeed('Wanindu Hasaranga', PlayerRole.allRounder, 84, true),
      _KnownPlayerSeed('Akash Madhwal', PlayerRole.pacer, 78, false),
      _KnownPlayerSeed('Kumar Kartikeya', PlayerRole.spinner, 73, false),
      _KnownPlayerSeed('Shubham Dubey', PlayerRole.finisher, 74, false),
      _KnownPlayerSeed('Yudhvir Singh', PlayerRole.pacer, 73, false),
    ],
    'Royal Challengers Bengaluru': [
      _KnownPlayerSeed('Virat Kohli', PlayerRole.opener, 93, false),
      _KnownPlayerSeed('Rajat Patidar', PlayerRole.anchor, 86, false),
      _KnownPlayerSeed('Phil Salt', PlayerRole.wicketKeeper, 85, true),
      _KnownPlayerSeed('Liam Livingstone', PlayerRole.allRounder, 84, true),
      _KnownPlayerSeed('Jitesh Sharma', PlayerRole.wicketKeeper, 81, false),
      _KnownPlayerSeed('Krunal Pandya', PlayerRole.allRounder, 82, false),
      _KnownPlayerSeed('Tim David', PlayerRole.finisher, 83, true),
      _KnownPlayerSeed('Bhuvneshwar Kumar', PlayerRole.pacer, 84, false),
      _KnownPlayerSeed('Josh Hazlewood', PlayerRole.pacer, 89, true),
      _KnownPlayerSeed('Yash Dayal', PlayerRole.pacer, 81, false),
      _KnownPlayerSeed('Suyash Sharma', PlayerRole.spinner, 79, false),
      _KnownPlayerSeed('Rasikh Salam', PlayerRole.pacer, 76, false),
      _KnownPlayerSeed('Swapnil Singh', PlayerRole.allRounder, 74, false),
      _KnownPlayerSeed('Manoj Bhandage', PlayerRole.allRounder, 72, false),
    ],
    'Sunrisers Hyderabad': [
      _KnownPlayerSeed('Abhishek Sharma', PlayerRole.opener, 89, false),
      _KnownPlayerSeed('Travis Head', PlayerRole.opener, 91, true),
      _KnownPlayerSeed('Nitish Kumar Reddy', PlayerRole.allRounder, 86, false),
      _KnownPlayerSeed('Heinrich Klaasen', PlayerRole.wicketKeeper, 90, true),
      _KnownPlayerSeed('Pat Cummins', PlayerRole.pacer, 91, true),
      _KnownPlayerSeed('Mohammed Shami', PlayerRole.pacer, 88, false),
      _KnownPlayerSeed('Harshal Patel', PlayerRole.pacer, 82, false),
      _KnownPlayerSeed('Rahul Chahar', PlayerRole.spinner, 81, false),
      _KnownPlayerSeed('Adam Zampa', PlayerRole.spinner, 84, true),
      _KnownPlayerSeed('Kamindu Mendis', PlayerRole.allRounder, 80, true),
      _KnownPlayerSeed('Simarjeet Singh', PlayerRole.pacer, 76, false),
      _KnownPlayerSeed('Atharva Taide', PlayerRole.anchor, 74, false),
      _KnownPlayerSeed('Aniket Verma', PlayerRole.finisher, 73, false),
      _KnownPlayerSeed('Abhinav Manohar', PlayerRole.finisher, 76, false),
    ],
  };

  static const List<_KnownPlayerSeed> _auctionPool = [
    _KnownPlayerSeed('Prithvi Shaw', PlayerRole.opener, 79, false),
    _KnownPlayerSeed('KS Bharat', PlayerRole.wicketKeeper, 76, false),
    _KnownPlayerSeed('Sarfaraz Khan', PlayerRole.anchor, 77, false),
    _KnownPlayerSeed('Kedar Jadhav', PlayerRole.anchor, 72, false),
    _KnownPlayerSeed('Chetan Sakariya', PlayerRole.pacer, 76, false),
    _KnownPlayerSeed('Kartik Tyagi', PlayerRole.pacer, 76, false),
    _KnownPlayerSeed('Saurabh Kumar', PlayerRole.spinner, 75, false),
    _KnownPlayerSeed('R Sai Kishore', PlayerRole.spinner, 80, false),
    _KnownPlayerSeed('Manish Pandey', PlayerRole.anchor, 74, false),
    _KnownPlayerSeed('Umesh Yadav', PlayerRole.pacer, 76, false),
    _KnownPlayerSeed('Anmolpreet Singh', PlayerRole.anchor, 73, false),
    _KnownPlayerSeed('Armaan Jaffer', PlayerRole.finisher, 71, false),
    _KnownPlayerSeed('Jason Behrendorff', PlayerRole.pacer, 80, true),
    _KnownPlayerSeed('Tom Banton', PlayerRole.wicketKeeper, 79, true),
    _KnownPlayerSeed('Daryl Mitchell', PlayerRole.allRounder, 82, true),
    _KnownPlayerSeed('Josh Little', PlayerRole.pacer, 80, true),
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
    return _buildPlayerFromRatings(
      id: id,
      name: _randomName(),
      age: 19 + _random.nextInt(16),
      role: role,
      baseCore: base,
      overseas: _random.nextDouble() < 0.22,
      inXI: inXI ?? false,
      traits: randomTraits(),
    );
  }

  TeamProfile createUserTeam() {
    final squad = createTeamSquad(
      'Royal Challengers Bengaluru',
      inXIForFirst11: true,
    );

    return TeamProfile(
      name: 'Royal Challengers Bengaluru',
      shortName: 'RCB',
      squad: squad,
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

  List<Player> createTeamSquad(
    String teamName, {
    required bool inXIForFirst11,
  }) {
    final seeds = _knownSquads[teamName];
    if (seeds == null || seeds.isEmpty) {
      return List<Player>.generate(
        18,
        (i) => createPlayer(id: '$teamName-$i', inXI: i < 11),
      );
    }

    return List<Player>.generate(seeds.length, (int i) {
      final seed = seeds[i];
      return _createKnownPlayer(
        id: '$teamName-$i',
        seed: seed,
        inXI: inXIForFirst11 ? i < 11 : false,
      );
    });
  }

  List<Player> createTeamXI(String teamName) {
    final squad = createTeamSquad(teamName, inXIForFirst11: true);
    return squad.take(11).toList();
  }

  List<TeamStanding> createStandings(String userTeamName) {
    return clubNames.map((String club) {
      if (club == userTeamName) {
        return TeamStanding(
          name: userTeamName,
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
    final shuffled = List<_KnownPlayerSeed>.of(_auctionPool)..shuffle(_random);
    final picks = shuffled.take(12).toList();

    final lots = <AuctionLot>[];
    for (var i = 0; i < picks.length; i++) {
      final seed = picks[i];
      final player = _createKnownPlayer(id: 'lot-$i', seed: seed, inXI: false);
      final basePrice = (0.5 + (seed.core / 100) * 2.4);
      lots.add(
        AuctionLot(
          id: 'lot-$i',
          player: player,
          basePriceCr: double.parse(basePrice.toStringAsFixed(1)),
          currentBidCr: double.parse(basePrice.toStringAsFixed(1)),
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

  Player _createKnownPlayer({
    required String id,
    required _KnownPlayerSeed seed,
    required bool inXI,
  }) {
    final age = 20 + _random.nextInt(16);
    final traits = _traitsForRole(seed.role);
    return _buildPlayerFromRatings(
      id: id,
      name: seed.name,
      age: age,
      role: seed.role,
      baseCore: seed.core,
      overseas: seed.overseas,
      inXI: inXI,
      traits: traits,
    );
  }

  Player _buildPlayerFromRatings({
    required String id,
    required String name,
    required int age,
    required PlayerRole role,
    required int baseCore,
    required bool overseas,
    required bool inXI,
    required List<PlayerTrait> traits,
  }) {
    int hitting = baseCore;
    int anchoring = baseCore;
    int bowling = baseCore;
    int economy = baseCore;

    switch (role) {
      case PlayerRole.opener:
        hitting = _clamp(baseCore + 5);
        anchoring = _clamp(baseCore + 4);
        bowling = _clamp(baseCore - 22);
        economy = _clamp(baseCore - 20);
        break;
      case PlayerRole.anchor:
        hitting = _clamp(baseCore + 2);
        anchoring = _clamp(baseCore + 7);
        bowling = _clamp(baseCore - 20);
        economy = _clamp(baseCore - 18);
        break;
      case PlayerRole.finisher:
        hitting = _clamp(baseCore + 7);
        anchoring = _clamp(baseCore - 2);
        bowling = _clamp(baseCore - 18);
        economy = _clamp(baseCore - 16);
        break;
      case PlayerRole.allRounder:
        hitting = _clamp(baseCore + 2);
        anchoring = _clamp(baseCore + 1);
        bowling = _clamp(baseCore + 2);
        economy = _clamp(baseCore + 3);
        break;
      case PlayerRole.pacer:
        hitting = _clamp(baseCore - 16);
        anchoring = _clamp(baseCore - 14);
        bowling = _clamp(baseCore + 8);
        economy = _clamp(baseCore + 7);
        break;
      case PlayerRole.spinner:
        hitting = _clamp(baseCore - 12);
        anchoring = _clamp(baseCore - 10);
        bowling = _clamp(baseCore + 8);
        economy = _clamp(baseCore + 9);
        break;
      case PlayerRole.wicketKeeper:
        hitting = _clamp(baseCore + 3);
        anchoring = _clamp(baseCore + 3);
        bowling = _clamp(baseCore - 24);
        economy = _clamp(baseCore - 22);
        break;
    }

    final pressure = _clamp(baseCore + _random.nextInt(9) - 4);
    final fitness = _clamp(68 + _random.nextInt(28));
    final form = _clamp(baseCore + _random.nextInt(13) - 6);

    final overall =
        ((hitting + anchoring + bowling + economy + pressure + fitness + form) /
                7)
            .round();

    final salary = (0.45 + (baseCore / 100) * 3.7) * (overseas ? 1.1 : 1.0);
    final market = salary * (1.08 + _random.nextDouble() * 0.32);

    return Player(
      id: id,
      name: name,
      age: age,
      role: role,
      overall: overall,
      hitting: hitting,
      anchoring: anchoring,
      bowling: bowling,
      economySkill: economy,
      pressure: pressure,
      fitness: fitness,
      form: form,
      salaryCr: double.parse(salary.toStringAsFixed(2)),
      marketValueCr: double.parse(market.toStringAsFixed(2)),
      overseas: overseas,
      injured: false,
      inPlayingXI: inXI,
      traits: traits,
    );
  }

  List<PlayerTrait> _traitsForRole(PlayerRole role) {
    switch (role) {
      case PlayerRole.opener:
        return [traitPool[0], traitPool[2]];
      case PlayerRole.anchor:
        return [traitPool[2], traitPool[3]];
      case PlayerRole.finisher:
        return [traitPool[0], traitPool[2]];
      case PlayerRole.allRounder:
        return [traitPool[2], traitPool[4]];
      case PlayerRole.pacer:
        return [traitPool[1], traitPool[4]];
      case PlayerRole.spinner:
        return [traitPool[3], traitPool[2]];
      case PlayerRole.wicketKeeper:
        return [traitPool[0], traitPool[2]];
    }
  }

  String _randomName() {
    const firstNames = <String>[
      'Arjun',
      'Vikram',
      'Rohan',
      'Kabir',
      'Ishan',
      'Dev',
      'Yash',
      'Pranav',
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
    ];

    const lastNames = <String>[
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

    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  int _clamp(int value) => value.clamp(30, 98);
}

class _KnownPlayerSeed {
  const _KnownPlayerSeed(this.name, this.role, this.core, this.overseas);

  final String name;
  final PlayerRole role;
  final int core;
  final bool overseas;
}
