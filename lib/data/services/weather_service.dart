import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeather(String city) async {
    final url = Uri.parse("https://wttr.in/$city?format=j1");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        double temp = double.parse(data['current_condition'][0]['temp_C']);
        String condition =
            data['current_condition'][0]['weatherDesc'][0]['value']
                .toString()
                .toLowerCase();

        return WeatherModel(
          cityName: city,
          temperature: temp,
          condition: condition,
        );
      } else {
        throw Exception("API Hatası");
      }
    } catch (e) {
      // İnternet yoksa veya hata oluşursa varsayılan değer döner
      return WeatherModel(
        cityName: city,
        temperature: 22.0,
        condition: "sunny",
      );
    }
  }
}
