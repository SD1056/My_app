import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/ai_service.dart';
import '../../../core/ai/pattern_analyzer.dart';
import '../../record/domain/record.dart';
import '../../record/presentation/record_provider.dart';

final aiServiceProvider = Provider((_) => AiService());

final suggestionProvider = FutureProvider.autoDispose<Record?>((ref) async {
  final records = await ref.watch(recordListProvider.future);
  final prompt = PatternAnalyzer().buildPrompt(records, DateTime.now());
  if (prompt.isEmpty) return null;
  return ref.read(aiServiceProvider).getSuggestion(prompt);
});
