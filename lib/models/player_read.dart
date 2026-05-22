class PlayerRead {
  final String id;
  final String userId;
  final String playerLabel;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlayerRead({
    required this.id,
    required this.userId,
    required this.playerLabel,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayerRead.fromJson(Map<String, dynamic> j) => PlayerRead(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        playerLabel: j['player_label'] as String,
        tags: List<String>.from(j['tags'] as List? ?? []),
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

class PlayerReadNote {
  final String id;
  final String readId;
  final String? noteText;
  final String? position;
  final String? action;
  final String? sizing;
  final String? street;
  final String? cardsShown;
  final DateTime createdAt;

  const PlayerReadNote({
    required this.id,
    required this.readId,
    this.noteText,
    this.position,
    this.action,
    this.sizing,
    this.street,
    this.cardsShown,
    required this.createdAt,
  });

  factory PlayerReadNote.fromJson(Map<String, dynamic> j) => PlayerReadNote(
        id: j['id'] as String,
        readId: j['read_id'] as String,
        noteText: j['note_text'] as String?,
        position: j['position'] as String?,
        action: j['action'] as String?,
        sizing: j['sizing'] as String?,
        street: j['street'] as String?,
        cardsShown: j['cards_shown'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  bool get isEmpty =>
      (noteText?.isEmpty ?? true) &&
      position == null &&
      action == null &&
      sizing == null &&
      street == null &&
      cardsShown == null;
}
