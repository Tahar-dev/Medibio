class EmailRequest {
  final String to;
  final String subject;
  final String text;
  final String filePath;

  EmailRequest({
    required this.to,
    required this.subject,
    required this.text,
    required this.filePath,
  });
}
