import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/pdf_service.dart';

class SendPdfScreen extends StatefulWidget {
  @override
  _SendPdfScreenState createState() => _SendPdfScreenState();
}

class _SendPdfScreenState extends State<SendPdfScreen> {
  String? pdfUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Firebase App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final pdfService = PdfService();
                final url = await pdfService.generateAndUploadPdf();
                setState(() {
                  pdfUrl = url;
                });
              },
              child: Text('Generate and Upload PDF'),
            ),
          ),
          if (pdfUrl != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'PDF URL: $pdfUrl',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
