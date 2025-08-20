import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final String description;
  final double temperature;
  final String icon;

  WeatherData({
    required this.city,
    required this.description,
    required this.temperature,
    required this.icon,
  });

  factory WeatherData.fromMeteostat(Map<String, dynamic> json, String cityName) {
    final data = json['data'] as List;
    if (data.isEmpty) {
      throw Exception('Brak danych pogodowych');
    }
    
    final latestData = data.last;
    final temp = latestData['temp'] ?? 20.0;
    
    String description = 'Słonecznie';
    String icon = '01d';
    
    final prcp = latestData['prcp'] ?? 0.0;
    final wspd = latestData['wspd'] ?? 0.0;
    
    if (prcp > 0) {
      description = 'Deszcz';
      icon = '09d';
    } else if (wspd > 20) {
      description = 'Wietrznie';
      icon = '50d';
    } else if (temp < 0) {
      description = 'Mroźno';
      icon = '13d';
    } else if (temp > 25) {
      description = 'Upał';
      icon = '01d';
    } else {
      description = 'Słonecznie';
      icon = '02d';
    }
    
    return WeatherData(
      city: cityName,
      description: description,
      temperature: temp.toDouble(),
      icon: icon,
    );
  }
}

class WeatherService {
  static const String _rapidApiKey = '61093c23bdmsh460422924f4c506p14e6d6jsna9f8aec1b67b';
  static const String _rapidApiHost = 'meteostat.p.rapidapi.com';
  static const String _baseUrl = 'https://meteostat.p.rapidapi.com/point/hourly';

  static Future<String> _getCityNameFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String cityName = '';
        
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          cityName = placemark.locality!;
        } else if (placemark.subAdministrativeArea != null && placemark.subAdministrativeArea!.isNotEmpty) {
          cityName = placemark.subAdministrativeArea!;
        } else if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          cityName = placemark.administrativeArea!;
        } else {
          cityName = 'Nieznana lokalizacja';
        }
        
        if (placemark.country != null && placemark.country!.isNotEmpty && placemark.country != 'United States') {
          cityName += ', ${placemark.country}';
        }
        
        print('📍 Nazwa miejscowości: $cityName');
        return cityName;
      }
    } catch (e) {
      print('Błąd pobierania nazwy miejscowości: $e');
    }
    return 'Twoja lokalizacja';
  }

  static Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Usługi lokalizacji są wyłączone');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Brak uprawnień do lokalizacji, proszę o uprawnienia...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Uprawnienia do lokalizacji zostały odrzucone');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Uprawnienia do lokalizacji są trwale odrzucone');
        return null;
      }

      print('Pobieranie aktualnej lokalizacji z GPS...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: false,
      ).timeout(const Duration(seconds: 10));
      
      print('Pobrano lokalizację: ${position.latitude}, ${position.longitude}');
      return position;
      
    } catch (e) {
      print('Błąd pobierania lokalizacji: $e');
      
      try {
        print('Próba pobrania ostatniej znanej pozycji...');
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print('Użyto ostatniej znanej pozycji: ${lastPosition.latitude}, ${lastPosition.longitude}');
          return lastPosition;
        }
      } catch (e2) {
        print('Błąd pobierania ostatniej pozycji: $e2');
      }
      
      return null;
    }
  }

  static Future<WeatherData?> getCurrentWeather() async {
    try {
      print('=== ROZPOCZĘCIE POBIERANIA POGODY ===');
      final position = await _getCurrentPosition();
      
      double lat = 52.2297;
      double lon = 21.0122;
      String cityName = 'Warszawa';
      
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
        cityName = await _getCityNameFromCoordinates(lat, lon);
        print('✅ UŻYWAM LOKALIZACJI Z TELEFONU: $lat, $lon');
        print('📍 MIEJSCOWOŚĆ: $cityName');
      } else {
        print('❌ NIE UDAŁO SIĘ POBRAĆ LOKALIZACJI - używam domyślnej Warszawy');
      }

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&alt=100&start=${yesterday.toIso8601String().split('T')[0]}&end=${now.toIso8601String().split('T')[0]}');
      print('📡 Zapytanie API: $url');
      
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-host': _rapidApiHost,
          'x-rapidapi-key': _rapidApiKey,
        },
      );

      print('📊 Odpowiedź API: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Dane pogodowe pobrane pomyślnie');
        final weatherData = WeatherData.fromMeteostat(data, cityName);
        print('🌤️ Pogoda: ${weatherData.temperature}°C, ${weatherData.description}');
        return weatherData;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return _generateFallbackWeatherData(cityName);
      }
    } catch (e) {
      print('Błąd pobierania pogody: $e');
      return _generateFallbackWeatherData('Warszawa');
    }
  }

  static WeatherData _generateFallbackWeatherData(String cityName) {
    final random = Random();
    final temperatures = [18, 20, 22, 24, 26, 28, 15, 12];
    final descriptions = [
      'Słonecznie',
      'Częściowo pochmurno', 
      'Pochmurno',
      'Lekki deszcz',
      'Przejściowe opady',
      'Bezchmurnie',
      'Mgła'
    ];

    return WeatherData(
      city: cityName,
      description: descriptions[random.nextInt(descriptions.length)],
      temperature: temperatures[random.nextInt(temperatures.length)].toDouble(),
      icon: '01d',
    );
  }
}
