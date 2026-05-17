import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:abaya_designer/api_config.dart';
   
   // Use groqApiKey where you need it

class AIService {
  String apiKey = groqApiKey; // Expose the API key for use in other parts of the app
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  final Random _random = Random();

  Future<Map<String, dynamic>?> getRecommendation(
      String abayaDesc, Map<String, String> hijabs) async {

    final prompt = """
Abaya Color: "$abayaDesc"

Available Hijab Options:
${hijabs.entries.map((e) => "${e.key} = ${e.value}").join(", ")}

STRICT STYLIST RULES:
1. ALWAYS create STRONG CONTRAST (dark vs light).
2. NEVER overuse neutral colors like grey, beige, cream.
3. DO NOT repeat safe/default colors.
4. ALWAYS suggest BOLD, FASHIONABLE combinations.
5. Return EXACTLY 3 DIFFERENT hijab filenames.
6. Ensure variety (different color families).

TASK:
- Pick the TOP 3 best hijabs.
- Write ONE short stylish reason (max 10 words).

OUTPUT FORMAT (STRICT JSON ONLY):
{
  "choices": ["file1.png", "file2.png", "file3.png"],
  "reason": "Short stylish sentence here."
}
""";

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a luxury fashion stylist. You hate boring combinations and avoid repetition."
            },
            {"role": "user", "content": prompt}
          ],
          "response_format": {"type": "json_object"},
          "temperature": 1.0, 
        }),
      );

      dev.log("AI RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        final cleanJson = jsonDecode(content);

        List choices = cleanJson['choices'];

        // HARD FILTER: Remove grey if present too often
        choices = choices.where((c) => c != 'Light Grey.png').toList();

        // FAILSAFE: if AI returns empty or invalid
        if (choices.isEmpty) {
          choices = hijabs.keys.toList();
        }

        //  PICK RANDOM FROM TOP CHOICES
        final selected = choices[_random.nextInt(choices.length)];

        return {
          "id": selected,
          "reason": cleanJson['reason']
        };
      }
    } catch (e) {
      dev.log("AI ERROR: $e");
    }

    // 🔁 FINAL FALLBACK (if API fails completely)
    final fallbackList = hijabs.keys.toList();
    final fallback = fallbackList[_random.nextInt(fallbackList.length)];

    return {
      "id": fallback,
      "reason": "A bold and elegant pairing."
    };
  }
}