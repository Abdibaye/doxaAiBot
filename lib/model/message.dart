class Message {
  String messageId;
  String chatId;
  Role role;
  StringBuffer message;
  List<String> imageUrls;
  DateTime timeSent;

  // Constructor
  Message({
    required this.messageId,
    required this.chatId,
    required this.role,
    required this.message,
    required this.imageUrls,
    required this.timeSent,
  });

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role.index, // Save the enum as an index
      'message': message.toString(),
      'imageUrls': imageUrls,
      'timeSent': timeSent.toIso8601String(),
    };
  }

  // fromMap
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] as String,
      chatId: map['chatId'] as String,
      role: Role.values[map['role'] as int],
      message: StringBuffer(map['message'] as String),
      imageUrls: List<String>.from(map['imageUrls']),
      timeSent: DateTime.parse(map['timeSent'] as String),
    );
  }

  // copyWith
  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imageUrls,
    DateTime? timeSent,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      message: message ?? StringBuffer(this.message.toString()),
      imageUrls: imageUrls ?? List<String>.from(this.imageUrls),
      timeSent: timeSent ?? this.timeSent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }
}

enum Role {
  user,
  assistant,
}
