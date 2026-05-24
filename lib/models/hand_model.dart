enum ActionType { post, postStraddle, fold, check, call, raise, allIn }

enum Street { preflop, flop, turn, river }

extension StreetLabel on Street {
  String get label {
    switch (this) {
      case Street.preflop:
        return 'Pre-flop';
      case Street.flop:
        return 'Flop';
      case Street.turn:
        return 'Turn';
      case Street.river:
        return 'River';
    }
  }
}

class HandAction {
  final int seat;
  final ActionType type;
  final int? amount;
  final bool isAllIn;
  final bool isOpeningBet;

  const HandAction({
    required this.seat,
    required this.type,
    this.amount,
    this.isAllIn = false,
    this.isOpeningBet = false,
  });

  String get label {
    switch (type) {
      case ActionType.fold:
        return 'FOLD';
      case ActionType.check:
        return 'CHECK';
      case ActionType.call:
        return 'CALL \$${amount ?? 0}';
      case ActionType.raise:
        if (isOpeningBet) return 'BET \$${amount ?? 0}';
        return isAllIn ? 'ALL-IN \$${amount ?? 0}' : 'RAISE \$${amount ?? 0}';
      case ActionType.allIn:
        return 'ALL-IN \$${amount ?? 0}';
      case ActionType.post:
        return 'POST \$${amount ?? 0}';
      case ActionType.postStraddle:
        return 'STRADDLE \$${amount ?? 0}';
    }
  }

  Map<String, dynamic> toJson() => {
        'seat': seat,
        'type': type.name,
        if (amount != null) 'amount': amount,
        'allIn': isAllIn,
        if (isOpeningBet) 'openingBet': true,
      };

  factory HandAction.fromJson(Map<String, dynamic> j) => HandAction(
        seat: j['seat'] as int,
        type: ActionType.values.byName(j['type'] as String),
        amount: j['amount'] as int?,
        isAllIn: j['allIn'] as bool? ?? false,
        isOpeningBet: j['openingBet'] as bool? ?? false,
      );
}

class StreetData {
  final Street street;
  final List<String> communityCards;
  final List<HandAction> actions;

  const StreetData({
    required this.street,
    this.communityCards = const [],
    required this.actions,
  });

  Map<String, dynamic> toJson() => {
        'street': street.name,
        'communityCards': communityCards,
        'actions': actions.map((a) => a.toJson()).toList(),
      };

  factory StreetData.fromJson(Map<String, dynamic> j) => StreetData(
        street: Street.values.byName(j['street'] as String),
        communityCards:
            List<String>.from(j['communityCards'] as List? ?? []),
        actions: (j['actions'] as List? ?? [])
            .map((a) => HandAction.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}

class HandPlayer {
  final int seatIndex;
  final String name;
  final int startingStack;
  final bool isHero;
  final List<String>? holeCards;

  const HandPlayer({
    required this.seatIndex,
    required this.name,
    required this.startingStack,
    this.isHero = false,
    this.holeCards,
  });

  HandPlayer copyWith({List<String>? holeCards}) => HandPlayer(
        seatIndex: seatIndex,
        name: name,
        startingStack: startingStack,
        isHero: isHero,
        holeCards: holeCards ?? this.holeCards,
      );

  Map<String, dynamic> toJson() => {
        'seat': seatIndex,
        'name': name,
        'stack': startingStack,
        'isHero': isHero,
        if (holeCards != null) 'holeCards': holeCards,
      };

  factory HandPlayer.fromJson(Map<String, dynamic> j) => HandPlayer(
        seatIndex: j['seat'] as int,
        name: j['name'] as String,
        startingStack: j['stack'] as int,
        isHero: j['isHero'] as bool? ?? false,
        holeCards: j['holeCards'] != null
            ? List<String>.from(j['holeCards'] as List)
            : null,
      );
}

class TableSetup {
  final int numSeats;
  final int buttonSeat;
  final int heroSeat;
  final int smallBlind;
  final int bigBlind;
  final int? straddle;

  const TableSetup({
    required this.numSeats,
    required this.buttonSeat,
    required this.heroSeat,
    required this.smallBlind,
    required this.bigBlind,
    this.straddle,
  });

  int get sbSeat => (buttonSeat + 1) % numSeats;
  int get bbSeat => (buttonSeat + 2) % numSeats;
  int get straddleSeat =>
      straddle != null ? (buttonSeat + 3) % numSeats : -1;

  String positionName(int seat) {
    final off = (seat - buttonSeat + numSeats) % numSeats;
    if (straddle != null && off == 3) return 'STR';
    if (numSeats <= 6) {
      const n = ['BTN', 'SB', 'BB', 'UTG', 'HJ', 'CO'];
      return off < n.length ? n[off] : 'P${seat + 1}';
    } else {
      const n = [
        'BTN', 'SB', 'BB', 'UTG', 'UTG+1', 'UTG+2', 'MP', 'HJ', 'CO'
      ];
      return off < n.length ? n[off] : 'P${seat + 1}';
    }
  }

  List<int> preflopOrder(List<int> active) {
    final firstOffset = straddle != null ? 4 : 3;
    final start = (buttonSeat + firstOffset) % numSeats;
    return List.generate(numSeats, (i) => (start + i) % numSeats)
        .where(active.contains)
        .toList();
  }

  List<int> postflopOrder(List<int> active) {
    return List.generate(numSeats, (i) => (sbSeat + i) % numSeats)
        .where(active.contains)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'numSeats': numSeats,
        'buttonSeat': buttonSeat,
        'heroSeat': heroSeat,
        'smallBlind': smallBlind,
        'bigBlind': bigBlind,
        if (straddle != null) 'straddle': straddle,
      };

  factory TableSetup.fromJson(Map<String, dynamic> j) => TableSetup(
        numSeats: j['numSeats'] as int,
        buttonSeat: j['buttonSeat'] as int,
        heroSeat: j['heroSeat'] as int,
        smallBlind: j['smallBlind'] as int,
        bigBlind: j['bigBlind'] as int,
        straddle: j['straddle'] as int?,
      );
}

class PokerHand {
  final String id;
  final String userId;
  final String? sessionId;
  final DateTime playedAt;
  final TableSetup tableSetup;
  final List<HandPlayer> players;
  final List<StreetData> streets;
  final String? notes;

  const PokerHand({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.playedAt,
    required this.tableSetup,
    required this.players,
    required this.streets,
    this.notes,
  });

  HandPlayer? get hero => players.where((p) => p.isHero).firstOrNull;

  List<String> get allCommunityCards =>
      streets.expand((s) => s.communityCards).toList();

  String get streetReached {
    if (streets.length == 1) return 'Pre-flop';
    if (streets.length == 2) return 'Flop';
    if (streets.length == 3) return 'Turn';
    return 'River';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        if (sessionId != null) 'sessionId': sessionId,
        'playedAt': playedAt.toIso8601String(),
        'tableSetup': tableSetup.toJson(),
        'players': players.map((p) => p.toJson()).toList(),
        'streets': streets.map((s) => s.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };

  factory PokerHand.fromJson(Map<String, dynamic> j) => PokerHand(
        id: j['id'] as String,
        userId: j['userId'] as String,
        sessionId: j['sessionId'] as String?,
        playedAt: DateTime.parse(j['playedAt'] as String),
        tableSetup:
            TableSetup.fromJson(j['tableSetup'] as Map<String, dynamic>),
        players: (j['players'] as List)
            .map((p) => HandPlayer.fromJson(p as Map<String, dynamic>))
            .toList(),
        streets: (j['streets'] as List)
            .map((s) => StreetData.fromJson(s as Map<String, dynamic>))
            .toList(),
        notes: j['notes'] as String?,
      );
}
