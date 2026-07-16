import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {

  static Future<String> sendMessage(String message) async {

    final url = Uri.parse("http://192.168.0.109:8000/predict");
    // 10.0.2.2 = Android emulator → localhost

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"];
    } else {
      return "Server error";
    }
  }
}