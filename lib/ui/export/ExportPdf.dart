import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class ExportPdfPage extends StatefulWidget {
  final int clientId;
  final DatePeriod selectedPeriod;

  ExportPdfPage(
      {Key key, @required this.clientId, @required this.selectedPeriod})
      : super(key: key);

  @override
  _ExportPdfPageState createState() => _ExportPdfPageState();
}

class _ExportPdfPageState extends State<ExportPdfPage> {
  String path;

  @override
  void initState() {
    super.initState();
    loadPdf(widget.clientId, widget.selectedPeriod);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tellow-time-hours.pdf');
  }

  Future<File> writeCounter(Uint8List stream) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsBytes(stream);
  }


  loadPdf(int id, DatePeriod datePeriod) async {
//    writeCounter(await getPdfReport(id, datePeriod));
    path = (await _localFile).path;

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pdf"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
        ),
        actions: <Widget>[
          // action button
          Visibility(
            visible: path != null ? true : false,
            child: IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {

              },
            ),
          ),
        ],
      ),
      body: Container(alignment: Alignment.center, child: pdfView()),
    );
  }

  Widget pdfView() {
    if (path != null) {
      return PdfViewer(
        filePath: path,
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
