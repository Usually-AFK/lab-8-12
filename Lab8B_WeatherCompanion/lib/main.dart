import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WeatherApp());

class Weather {
  const Weather({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.code,
    required this.rainChance,
  });
  final String city;
  final double temperature, feelsLike, wind;
  final int humidity, code, rainChance;
  factory Weather.fromJson(String city, Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final rain =
        (hourly['precipitation_probability'] as List<dynamic>? ?? const [0]);
    return Weather(
      city: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      wind: (current['wind_speed_10m'] as num).toDouble(),
      code: (current['weather_code'] as num).toInt(),
      rainChance: (rain.first as num).toInt(),
    );
  }
  String get advice => rainChance >= 40
      ? 'Bring an umbrella today.'
      : temperature >= 32
      ? 'It is hot. Choose a shaded, easy walk.'
      : temperature <= 10
      ? 'Wear a warm layer outside.'
      : 'Looks good for an outdoor walk.';
  String get description => code >= 95
      ? 'Thunderstorm'
      : code >= 71
      ? 'Snow'
      : code >= 51
      ? 'Drizzle'
      : code >= 45
      ? 'Foggy'
      : code >= 3
      ? 'Cloudy'
      : 'Clear sky';
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  Future<Weather> fetch(String name) async {
    final geo = await _client
        .get(
          Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
            'name': name,
            'count': '1',
            'language': 'en',
            'format': 'json',
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (geo.statusCode != 200) {
      throw Exception('Location search failed (${geo.statusCode}).');
    }
    final results =
        (jsonDecode(geo.body) as Map<String, dynamic>)['results']
            as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('City not found. Try another name.');
    }
    final place = results.first as Map<String, dynamic>;
    final label =
        '${place['name']}${place['country'] == null ? '' : ', ${place['country']}'}';
    final forecast = await _client
        .get(
          Uri.https('api.open-meteo.com', '/v1/forecast', {
            'latitude': '${place['latitude']}',
            'longitude': '${place['longitude']}',
            'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
            'hourly': 'precipitation_probability',
            'forecast_days': '1',
            'timezone': 'auto',
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (forecast.statusCode != 200) {
      throw Exception('Weather service returned ${forecast.statusCode}.');
    }
    return Weather.fromJson(
      label,
      jsonDecode(forecast.body) as Map<String, dynamic>,
    );
  }
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Weather Companion',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b68)),
      useMaterial3: true,
    ),
    home: const WeatherScreen(),
  );
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _service = WeatherService();
  final _city = TextEditingController(text: 'Bangkok');
  late Future<Weather> _weather = _service.fetch(_city.text);
  void _search() {
    final name = _city.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _weather = _service.fetch(name));
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Weather companion')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Plan your day with a local forecast.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _city,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _search, child: const Text('Search')),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<Weather>(
          future: _weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, size: 40),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      TextButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final w = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.city,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${w.temperature.round()}°',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Text(w.description),
                        const SizedBox(height: 8),
                        Text(
                          w.advice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Feels like'),
                        trailing: Text('${w.feelsLike.round()}°'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.water_drop_outlined),
                        title: const Text('Humidity'),
                        trailing: Text('${w.humidity}%'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.air),
                        title: const Text('Wind'),
                        trailing: Text('${w.wind.round()} km/h'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.umbrella_outlined),
                        title: const Text('Rain chance'),
                        trailing: Text('${w.rainChance}%'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
