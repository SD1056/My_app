import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/record/domain/record.dart';

class AiService {
  static const _keyStorageKey = 'claude_api_key';
  static const _model = 'claude-sonnet-4-6';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.anthropic.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getApiKey() => _storage.read(key: _keyStorageKey);

  Future<void> saveApiKey(String key) =>
      _storage.write(key: _keyStorageKey, value: key);

  Future<void> deleteApiKey() => _storage.delete(key: _keyStorageKey);

  Future<Record?> getSuggestion(String prompt) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) return null;

    try {
      final response = await _dio.post(
        '/messages',
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 128,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        },
      );

      final text = response.data['content'][0]['text'] as String;
      final match = RegExp(r'\{[^}]+\}').firstMatch(text);
      if (match == null) return null;

      final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      final category = parsed['category'] as String? ?? '';
      final value = parsed['value'] as String? ?? '';

      final validCategories = kCategories.map((c) => c.name).toSet();
      if (!validCategories.contains(category) || value.isEmpty) return null;

      return Record(
        category: category,
        value: value,
        recordedAt: DateTime.now(),
        source: 'ai_accepted',
      );
    } catch (_) {
      return null;
    }
  }
}
