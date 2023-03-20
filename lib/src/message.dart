/// ChatGPT message
class Message {
  /// Content of message
  final String content;

  /// Role of message (system, user, assistant)
  final String role;

  /// Initializer
  Message({required this.content, required this.role});

  /// Convert instance to dictionary
  Map<String, String> toMap() {
    return {"role": role, "content": content};
  }
}
