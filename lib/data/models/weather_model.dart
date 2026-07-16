class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'] ?? '',
      temperature: (json['current']['temp_c'] as num).toDouble(),
      condition: json['current']['condition']['text'].toString().toLowerCase(),
    );
  }
}
