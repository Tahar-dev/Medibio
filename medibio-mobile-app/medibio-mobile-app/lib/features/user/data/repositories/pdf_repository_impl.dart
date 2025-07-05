import 'package:srasav_vf_v1/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/email_request.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/pdf_repository.dart';


class PdfRepositoryImpl implements PdfRepository {
  final UserRemoteDataSource dataSource;

  PdfRepositoryImpl({required this.dataSource});

  @override
  Future<void> sendPdf(EmailRequest emailRequest) {
    return dataSource.sendPdfToBackend(
      filePath: emailRequest.filePath,
      to: emailRequest.to,
      subject: emailRequest.subject,
      text: emailRequest.text,
    );
  }
}
