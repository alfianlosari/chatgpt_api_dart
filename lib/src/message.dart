class Message {
  final String content;
  final String role;

  Message({required this.content, required this.role});

  Map<String, String> toMap() {
    return {"role": role, "content": content};
  }
}
