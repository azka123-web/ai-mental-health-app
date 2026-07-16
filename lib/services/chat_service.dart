import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {

  // Replace with your PC IP
  final String baseUrl = "http://192.168.0.109:8000/predict";

  Future<String> sendMessage(String message) async {

    final response = await http.post(
      Uri.parse(baseUrl),
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