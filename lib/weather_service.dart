import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class WeatherService {
    final String apiKey = ""; 
    final String baseUrl = "https://api.weatherapi.com/v1/current.json";

    Future<Map<String, dynamic>> fetchWeather(String cityName) async {
        try {
            final url = Uri.parse("$baseUrl?key=$apiKey&q=${cityName.trim()}");
            
            final response = await http.get(url);

            if (response.statusCode == 200) {
                return json.decode(response.body);
            } else if (response.statusCode == 400) {
                // The weatherapi.com uses 400 for 'City not found' and bad input.
                // It usually includes an error message in the body.
                final errorJson = json.decode(response.body);
                final errorMsg = errorJson['error']['message'] ?? "City not found or bad request.";
                
                // Throw an exception that includes the specific error message from the API.
                throw Exception("API Error 400: $errorMsg"); 
            } else {
                // Handle all other status codes (e.g., 401 for bad key, 5xx for server issues)
                throw Exception("API Error: Failed to load weather data. Status Code: ${response.statusCode}");
            }
        } catch (e) {
            // This is still catching network errors (SocketException) or the Exceptions thrown above.
            developer.log("Service error occurred", name: 'WeatherService', error: e);
            rethrow; 
        }
    }
}