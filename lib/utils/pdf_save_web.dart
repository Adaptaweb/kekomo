// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Crea un Blob con los bytes del PDF y devuelve una URL blob://
/// apta para `XFile`/`<a download>` en el navegador.
Future<String?> savePdfBytes(List<int> bytes, String fileName) async {
  try {
    final blob = html.Blob(<dynamic>[bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    return url;
  } catch (_) {
    return null;
  }
}
