import 'package:google_generative_ai/google_generative_ai.dart';

class LLMService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<List<String>> generateSuggestions({
    required List<String> habits,
    required List<String> logsSummary,
  }) async {
    if (_apiKey.isEmpty) {
      // Return helpful fallback mock suggestions if API Key is not set yet
      return [
        'Turn off lights and appliances when leaving a room.',
        'Use reusable shopping bags instead of single-use plastic.',
        'Plant a small herb or flower pot on your windowsill.',
      ];
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
User habits list:
${habits.map((h) => '- $h').join('\n')}

User habit logs activity recently:
${logsSummary.map((l) => '- $l').join('\n')}

Suggest 3 simple eco-friendly actions that the user can take based on their activity. Return ONLY the 3 suggestions, each on a new line, without any numbering, bullet points, introduction, or formatting.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('Received empty response from Gemini API');
      }

      final suggestions = text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) {
            // Strip leading bullet points or numbers if Gemini accidentally generated them
            return s.replaceFirst(RegExp(r'^[-*•\d\.\s]+'), '');
          })
          .take(3)
          .toList();

      while (suggestions.length < 3) {
        suggestions.add('Try walking or cycling for short trips instead of driving.');
      }

      return suggestions;
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }
}
