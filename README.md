# Dokumentacja Techniczna Projektu: FishCalculator MVP

## 1. Przegląd Projektu

**Cel:** Stworzenie lekkiej, działającej offline aplikacji na system Android, służącej do szybkiego wyceniania ryb na podstawie wagi oraz monitorowania dziennego utargu w barze.
**Platforma docelowa:** Android (min. SDK 21 / Android 5.0).
**Model dystrybucji:** Plik `.apk` instalowany ręcznie (sideloading).

## 2. Stos Technologiczny (Tech Stack)

| Komponent | Technologia | Uzasadnienie |
| --- | --- | --- |
| **Framework** | **Flutter** | Kompilacja do kodu natywnego, szybki development UI. |
| **Język** | **Dart** | Język natywny dla Fluttera. |
| **Baza Danych** | **Hive** (NoSQL) | Baza klucz-wartość. Szybka, bez mapowania ORM. |
| **Zarządzanie Stanem** | **Provider** | Proste i skuteczne zarządzanie stanem aplikacji i wstrzykiwanie zależności (DI). |
| **Lokalizacja** | **intl** | Formatowanie walut i obsługa wielu języków. |
| **Pliki** | **`path_provider`** | Zapisywanie zdjęć bezpośrednio w pamięci urządzenia. |
| **Zdjęcia** | **`image_picker`** | Obsługa aparatu i galerii. |
| **Konfiguracja** | **`shared_preferences`** | Trwały zapis prostych ustawień (motyw, język). |

## 3. Architektura Danych (Schema)

Aplikacja operuje na dwóch głównych kolekcjach (Hive Boxes).

### A. Model: `FishItem` (Katalog Produktów)

Obiekt reprezentujący rodzaj ryby dostępny w sprzedaży.

* `id` (String): Unikalny identyfikator (UUID).
* `name` (String): Nazwa ryby (np. "Dorsz").
* `pricePerKg` (Double): Cena za 1 kg.
* `imagePath` (String?): Lokalna ścieżka do pliku graficznego (opcjonalna).
* `isActive` (Bool): Flaga dostępności.

### B. Model: `Transaction` (Historia Sprzedaży)

Obiekt pojedynczego ważenia/sprzedaży.

* `id` (String): Unikalny identyfikator transakcji (UUID).
* `fishNameSnapshot` (String): Kopia nazwy ryby w momencie sprzedaży.
* `weightInKg` (Double): Zważona masa.
* `totalPrice` (Double): Wyliczona cena końcowa.
* `date` (DateTime): Data i czas operacji.

## 4. Funkcjonalności Szczegółowe

### 4.1. Moduł Sprzedaży (Dashboard)

* **Widok:** Siatka (Grid) kafelków.
* **Logika:**
    1. Wprowadzenie wagi.
    2. Przeliczenie: `Waga * Cena`.
    3. Zapis transakcji do bazy Hive.

### 4.2. Moduł Historii

* **Zakres:** Lista transakcji z bieżącej sesji.
* **Podsumowanie:** Suma wagi (kg) i utarg całkowity (PLN).
* **Akcje:** Reset dnia (usunięcie wszystkich rekordów z `TransactionBox`).

### 4.3. Moduł Ustawień

* **Wygląd:** Przełącznik motywu Jasny / Ciemny (`ThemeService`).
* **Język:** Wybór języka interfejsu (PL / EN / DE) (`LocaleService`).
* **Zarządzanie Rybami (CRUD):** Dodawanie, edycja i ukrywanie pozycji w menu.

## 5. Wymagania Niefunkcjonalne

1. **Offline-First:** Brak zapytań sieciowych.
2. **Obsługa Błędów:** Walidacja wagi (brak wartości ujemnych), placeholder dla braku zdjęcia.
3. **UI:** Elementy dostosowane do ekranów dotykowych.

## 6. Struktura Plików

```text
lib/
├── main.dart                 # Punkt startowy, konfiguracja Providerów
├── models/                   # Klasy danych (Hive Objects)
│   ├── fish_item.dart
│   └── transaction.dart
├── screens/                  # Główne widoki
│   ├── dashboard_screen.dart
│   ├── history_screen.dart
│   ├── home_screen.dart      # Nawigacja (BottomNavigationBar)
│   └── settings_screen.dart
├── services/                 # Logika biznesowa i serwisy
│   ├── database_service.dart # Obsługa Hive
│   ├── locale_service.dart   # Obsługa zmiany języka
│   └── theme_service.dart    # Obsługa motywu