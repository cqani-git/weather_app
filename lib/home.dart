import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'dart:io';


class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}
class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  bool isButtonEnabled = false;

@override
void initState() {
  super.initState();

  // Listen for changes in the text field
  _controller.addListener(() {
    setState(() {
      isButtonEnabled = _controller.text.trim().isNotEmpty;
    });
  });
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
  
  IconData _getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'clouds':
      return WeatherIcons.cloud;
    case 'rain':
      return WeatherIcons.rain;
    case 'drizzle':
      return WeatherIcons.sprinkle;
    case 'thunderstorm':
      return WeatherIcons.thunderstorm;
    case 'snow':
      return WeatherIcons.snow;
    case 'clear':
      return WeatherIcons.day_sunny;
    case 'mist':
    case 'fog':
    case 'haze':
      return WeatherIcons.fog;
    default:
      return WeatherIcons.day_sunny_overcast;
  }
}
 Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // **A. Check for No Internet Connectivity FIRST**
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw const SocketException("No Internet Connection");
      }

      // **B. Proceed with API call if network is available**
      final data = await _weatherService.fetchWeather(_controller.text.trim());
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      // **C. Differentiate Error Messages**

      String errorText;
      if (e is SocketException) {
        // This catches the 'No Internet' error thrown above or a direct network failure from http
        errorText = "❌ No internet connection. Please try again.";
      } else if (e.toString().contains('400')) {
        // Catches the API 400 Bad Request error (often for city not found)
        errorText = "⚠️ City not found. Please check your spelling.";
      } else {
        // General error handling for other API or unexpected issues
        errorText = "An unexpected error occurred: ${e.toString()}";
      }

      setState(() {
        errorMessage = errorText;
        weatherData = null; // Clear old data on error
      });
        
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
      ),
     body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      // Main content scrollable
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Enter city name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isButtonEnabled ? fetchWeather : null,
                child: const Text("Get Weather"),
              ),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
            if (weatherData != null) ...[
                  Text(
                  weatherData!['location']['name'],
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                BoxedIcon(
                  _getWeatherIcon(weatherData!['current']['condition']['text']),
                  size: 50,
                ),
                const SizedBox(height: 8),
                Text(
                  "${weatherData!['current']['temp_c']}°C",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  weatherData!['current']['condition']['text'],
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ],
          ),
        ),
      ),

      // Footer fixed at the bottom
      const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Text(
          "Weather App by abdikani",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
      ),
    ],
  ),
),

     
    );
  }
}