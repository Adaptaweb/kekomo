import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Escribe los bytes del PDF al directorio de documentos del sistema
/// y devuelve la ruta del archivo.
///
/// Devuelve `null` si no se pudo escribir.
Future<String?> savePdfBytes(List<int> bytes, String fileName) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  } catch (_) {
    return null;
  }
}
