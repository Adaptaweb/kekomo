import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../data/models/meal_log.dart';
import '../data/models/reaction.dart';
import 'date_utils.dart';
import 'pdf_save_stub.dart'
    if (dart.library.js_interop) 'pdf_save_web.dart';

class PdfGenerator {
  Future<void> generate({
    required String firstName,
    required String lastName,
    required String category,
    required String fromDate,
    required String toDate,
    required List<MealLog> mealLogs,
    required List<Reaction> reactions,
    required bool includeMeals,
    required bool includeReactions,
    required bool includeNotes,
  }) async {
    final pdf = pw.Document();

    final filteredMeals = mealLogs
        .where((l) =>
            l.date.compareTo(fromDate) >= 0 && l.date.compareTo(toDate) <= 0)
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        final at = a.loggedAt;
        final bt = b.loggedAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return at.compareTo(bt);
      });

    final filteredReactions = reactions
        .where((r) =>
            r.date.compareTo(fromDate) >= 0 && r.date.compareTo(toDate) <= 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final noteEntries = includeNotes
        ? filteredMeals
            .where((l) => l.foodItemsText.trim().isNotEmpty)
            .toList()
        : <MealLog>[];

    final mealsByDate = <String, List<MealLog>>{};
    for (final l in filteredMeals) {
      mealsByDate.putIfAbsent(l.date, () => []).add(l);
    }
    final sortedDates = mealsByDate.keys.toList()..sort();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox.shrink()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  'Reporte KeComo',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700),
                ),
              ),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generado el ${_formatTimestamp(DateTime.now())}',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey700),
              ),
              pw.Text(
                'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        build: (context) => [
          _buildHeader(firstName, lastName, category, fromDate, toDate),
          pw.SizedBox(height: 16),
          if (includeMeals) ...[
            _buildSectionTitle('Historial de Consumo'),
            if (filteredMeals.isEmpty)
              _buildEmpty('No hay comidas registradas en este rango.')
            else
              ...sortedDates.expand((date) => [
                    _buildDayHeader(date),
                    _buildMealsTable(mealsByDate[date]!),
                    pw.SizedBox(height: 12),
                  ]),
          ],
          if (includeReactions) ...[
            _buildSectionTitle('Reacciones Registradas'),
            if (filteredReactions.isEmpty)
              _buildEmpty('No hay reacciones registradas en este rango.')
            else
              _buildReactionsTable(filteredReactions),
          ],
          if (includeNotes && noteEntries.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSectionTitle('Notas y Observaciones'),
            ...noteEntries.map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• [${l.date}] ${l.mealType}: ${l.foodItemsText}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                )),
          ],
        ],
      ),
    );

    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeAlias = (firstName + (lastName.isNotEmpty ? '_$lastName' : ''))
        .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    final fileName = 'KeComo_${safeAlias.isEmpty ? "reporte" : safeAlias}_$ts.pdf';
    final bytes = await pdf.save();

    final savedPath = await savePdfBytes(bytes, fileName);
    if (savedPath == null) {
      throw StateError('No se pudo guardar el PDF en este dispositivo');
    }

    await Share.shareXFiles(
      [XFile(savedPath, mimeType: 'application/pdf', name: fileName)],
      text: 'Reporte KeComo — $firstName',
      subject: 'Reporte KeComo',
    );
  }

  pw.Widget _buildHeader(String firstName, String lastName, String category,
      String fromDate, String toDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'REPORTE KECOMO',
            style: pw.TextStyle(
                fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            'Historial de consumo y reacciones',
            style: const pw.TextStyle(
                fontSize: 11, color: PdfColors.grey700),
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Paciente: $firstName $lastName',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text('Categoría: $category',
                  style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 2),
              pw.Text(
                'Rango: ${formatDate(fromDate)} — ${formatDate(toDate)}',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(width: 4, height: 16, color: PdfColors.blue700),
          pw.SizedBox(width: 8),
          pw.Text(
            text,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDayHeader(String date) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
      child: pw.Text(
        formatDate(date),
        style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800),
      ),
    );
  }

  pw.Widget _buildMealsTable(List<MealLog> logs) {
    return pw.TableHelper.fromTextArray(
      headers: ['Hora', 'Tipo', 'Alimento'],
      data: logs.map((l) {
        final time = l.loggedAt != null
            ? DateFormat('HH:mm').format(l.loggedAt!)
            : '—';
        return [time, l.mealType, l.foodItemsText];
      }).toList(),
      headerStyle: pw.TextStyle(
          fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
  }

  pw.Widget _buildReactionsTable(List<Reaction> reactions) {
    return pw.TableHelper.fromTextArray(
      headers: ['Fecha', 'Comida', 'Síntomas', 'Descripción'],
      data: reactions
          .map((r) => [r.date, r.mealType, r.symptoms, r.description])
          .toList(),
      headerStyle: pw.TextStyle(
          fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red700),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
  }

  pw.Widget _buildEmpty(String message) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(
        message,
        style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey700,
            fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat("d MMM yyyy, HH:mm", 'es').format(dt);
  }
}
