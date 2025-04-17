import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService with ChangeNotifier {
  String _temperature = '';
  String _condition = '';
  String _location = '';
  bool _isLoading = false;

  String get temperature => _temperature;
  String get condition => _condition;
  String get location => _location;
  bool get isLoading => _isLoading;

  Future<void> getCurrentWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener la ubicación actual
      Position position = await _determinePosition();
      
      // Llamada a la API del clima (OpenWeatherMap como ejemplo)
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=TU_API_KEY&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _temperature = '${data['main']['temp'].round()}°C';
        _condition = data['weather'][0]['main'];
        _location = data['name'];
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _temperature = 'Error';
      _condition = 'No disponible';
      _location = 'Desconocida';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están permanentemente denegados');
    }

    return await Geolocator.getCurrentPosition();
  }
}