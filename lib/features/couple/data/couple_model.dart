class CoupleModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime startDate;
  final String inviteCode;

  CoupleModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.startDate,
    required this.inviteCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'startDate': startDate.toIso8601String(),
      'inviteCode': inviteCode,
    };
  }

  factory CoupleModel.fromMap(Map<String, dynamic> map) {
    return CoupleModel(
      id: map['id'],
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
      startDate: DateTime.parse(map['startDate']),
      inviteCode: map['inviteCode'],
    );
  }

  // 🔥 LINK GENERATOR
  String get inviteLink {
    return "romanza://join/$inviteCode";
  }
}