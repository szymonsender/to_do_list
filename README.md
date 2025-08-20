# Lista Zadań - Flutter App

Aplikacja mobilna do zarządzania codziennymi zadaniami, stworzona w Flutter.

## 🚀 Funkcjonalności

### ✅ Podstawowe funkcjonalności
- **Tworzenie zadań** - dodawanie zadań z tytułem, opisem i deadline'em
- **Lista zadań** - wyświetlanie wszystkich zadań posortowanych według deadline'u  
- **Oznaczanie wykonania** - przenoszenie zadań między sekcjami "Do zrobienia" i "Wykonane"
- **Edycja zadań** - modyfikacja tytułu, opisu i deadline'u
- **Usuwanie zadań** - usuwanie przez przeciągnięcie (swipe)

### 🔔 Powiadomienia
- Lokalne przypomnienia dzień przed deadline'em
- Powiadomienie w dniu wykonania zadania
- Automatyczne anulowanie powiadomień dla wykonanych zadań

### 📊 Statystyki  
- Liczba wykonanych zadań
- Wskaźnik ukończenia w procentach
- Najbardziej produktywny dzień tygodnia
- Wizualizacja postępu

### 🌦️ Widget pogodowy (opcjonalny)
- Wyświetlanie aktualnej pogody na podstawie lokalizacji
- Czytelny design z ikoną i temperaturą

## 🏗️ Architektura

### Struktura projektu
```
lib/
├── models/
│   └── task.dart              # Model zadania
├── database/
│   └── database_helper.dart   # Obsługa SQLite
├── providers/
│   └── task_provider.dart     # Zarządzanie stanem (Provider)
├── services/
│   ├── notification_service.dart  # Powiadomienia lokalne
│   └── weather_service.dart      # API pogodowe
├── screens/
│   ├── home_screen.dart          # Główny ekran
│   ├── add_edit_task_screen.dart # Dodawanie/edycja
│   └── statistics_screen.dart    # Statystyki
├── widgets/
│   ├── task_tile.dart           # Widget zadania
│   └── weather_widget.dart      # Widget pogody  
├── utils/
│   └── date_utils.dart         # Pomocnicze funkcje dat
└── main.dart                   # Punkt wejścia
```

### Technologie
- **Flutter** - framework UI
- **SQLite** (sqflite) - lokalna baza danych
- **Provider** - zarządzanie stanem  
- **flutter_local_notifications** - powiadomienia lokalne
- **geolocator** - lokalizacja użytkownika
- **http** - zapytania HTTP dla API pogody
- **intl** - internacjonalizacja i formatowanie dat

## 🎨 Design

### Główne cechy UI
- **Material Design 3** z kolorystyką opartą na fioletowym
- **Intuicyjny interfejs** z łatwą nawigacją
- **Zakładki** rozdzielające aktywne i wykonane zadania  
- **Kolorowe wskaźniki** stanu zadań (przeterminowane, dzisiaj, jutro)
- **Smooth animations** i transitions
- **Responsywny design** dopasowany do różnych rozmiarów ekranu

### Kolory i ikony
- Fioletowy jako kolor główny (Purple)
- Czerwony dla zadań przeterminowanych
- Pomarańczowy dla zadań dzisiejszych  
- Żółty dla zadań jutrzejszych
- Zielony dla zadań wykonanych

## 🔧 Wymagania techniczne

### Spełnione wymagania
✅ Użycie lokalnej bazy danych SQLite  
✅ Intuicyjny i przyjazny UI  
✅ **Brak użycia typu `dynamic`** - wszystkie typy są explicite zdefiniowane  
✅ Polskie komentarze w kodzie  
✅ Wszystkie wymagane funkcjonalności

### Dodatkowe funkcjonalności
✅ Widget pogodowy z geolokalizacją  
✅ Powiadomienia push  
✅ Statystyki i analityka  
✅ Pull-to-refresh  
✅ Swipe-to-delete  

## 🚀 Instalacja i uruchomienie

### Wymagania
- Flutter SDK (>=2.17.5)
- Android Studio / Xcode
- Android/iOS device lub emulator

### Kroki
1. Sklonuj repozytorium
2. Zainstaluj zależności:
   ```bash
   flutter pub get
   ```
3. Uruchom aplikację:
   ```bash  
   flutter run
   ```

### Budowanie
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 📝 Konfiguracja

### API pogodowe (opcjonalne)
Aby włączyć funkcję pogody, wstaw swój klucz API z [WeatherAPI](https://weatherapi.com/) do pliku `lib/services/weather_service.dart`:

```dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
```

### Uprawnienia
Aplikacja wymaga następujących uprawnień:
- **Powiadomienia** - dla przypomnień o zadaniach
- **Lokalizacja** (opcjonalne) - dla widgetu pogodowego

## 🧪 Testy

Uruchom testy:
```bash
flutter test
```

---

**Autor:** Szymon Sender  
**Data:** Sierpień 2025  
**Wersja:** 1.0.0





