import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskflow/core/errors/exceptions.dart';

abstract class ShareService {
  Future<void> shareJsonFile({
    required String jsonContent,
    required String fileName,
    String? subject,
    String? text,
  });
}

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareJsonFile({
    required String jsonContent,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonContent);

      final xFile = XFile(file.path, mimeType: 'application/json');
      await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'TaskFlow Project Export',
        text: text ?? 'Here is the exported project data from TaskFlow.',
      );
    } catch (e) {
      throw ExportException('Impossible de créer ou de partager le fichier JSON : $e');
    }
  }
}
