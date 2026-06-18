import 'package:flutter_riverpod/flutter_riverpod.dart';

final pdfFromDateProvider = StateProvider<String>((ref) => '');
final pdfToDateProvider = StateProvider<String>((ref) => '');

final pdfIncludeMealsProvider = StateProvider<bool>((ref) => true);
final pdfIncludeReactionsProvider = StateProvider<bool>((ref) => true);
final pdfIncludeNotesProvider = StateProvider<bool>((ref) => true);
