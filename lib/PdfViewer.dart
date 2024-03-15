import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:printing/printing.dart';

class PdfViewerPage extends StatelessWidget {
   String filePath;
   final Future<Uint8List> generatePdf;

  PdfViewerPage({required this.filePath ,  required  this.generatePdf}){

  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Note'),
      ),
      body: FutureBuilder(
        future: generatePdf, // Your function that generates the PDF data
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final pdfData = snapshot.data as dynamic; // Get the PDF data
            return PdfPreview(
              build: (format) => pdfData ,
            );
          } else if (snapshot.hasError) {
            return Text('Error generating PDF: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}