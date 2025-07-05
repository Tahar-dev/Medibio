import '../entities/email_request.dart';

abstract class PdfRepository {
  Future<void> sendPdf(EmailRequest emailRequest);
}
