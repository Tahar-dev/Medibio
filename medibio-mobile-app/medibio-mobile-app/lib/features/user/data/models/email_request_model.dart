import '../../domain/entities/email_request.dart';

class EmailRequestModel extends EmailRequest {
  EmailRequestModel({
    required String to,
    required String subject,
    required String text,
    required String filePath,
  }) : super(to: to, subject: subject, text: text, filePath: filePath);
}
