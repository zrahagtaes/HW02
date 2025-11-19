class Message {
  String id;
  String text;
  String userName;
  DateTime createdAt;

  Message({
    required this.id,
    required this.text,
    required this.userName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Message.fromDoc(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      text: map['text'],
      userName: map['userName'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
