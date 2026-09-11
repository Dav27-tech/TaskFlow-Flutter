import 'dart:io';

import 'package:share_plus/share_plus.dart';

abstract class ShareService {
  Future<void> shareJsonFile({
    required String jsonContent,
    required String fileName,
    required String subject,
    required String text,
  });
}

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareJsonFile({
    required String jsonContent,
    required String fileName,
    required String subject,
    required String text,
  }) async {
    final tempFile = await _writeTempFile(jsonContent, fileName);
    await SharePlus.instance.share(
      ShareParams(
        subject: subject,
        text: text,
        files: [XFile(tempFile.path)],
      ),
    );
  }

  Future<File> _writeTempFile(String content, String fileName) async {
    final dir = await Directory.systemTemp.createTemp('taskflow_');
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }
}
