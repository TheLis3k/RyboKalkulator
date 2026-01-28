# Dokumentacja Techniczna Projektu: FishCalculator MVP

## 1. Przegląd Projektu

**Cel:** Stworzenie lekkiej, działającej offline aplikacji na system Android, służącej do szybkiego wyceniania ryb na podstawie wagi oraz monitorowania dziennego utargu w barze.
**Platforma docelowa:** Android (min. SDK 21 / Android 5.0).
**Model dystrybucji:** Plik `.apk` instalowany ręcznie (sideloading).

## 2. Stos Technologiczny (Tech Stack)

| Komponent | Technologia | Uzasadnienie |
| --- | --- | --- |
| **Framework** | **Flutter** | Kompilacja do kodu natywnego (wydajność na starych urządzeniach), szybki development UI, łatwe zarządzanie motywami. |
| **Język** | **Dart** | Język natywny dla Fluttera. |
| **Baza Danych** | **Hive** (NoSQL) | Baza klucz-wartość. Jest szybsza od SQLite, nie wymaga skomplikowanego mapowania ORM, idealna do prostych struktur danych. |
| **Matematyka** | Paczka **`decimal`** | Zapobiega błędom zmiennoprzecinkowym (floating point errors) przy operacjach finansowych. |
| **Pliki** | **`path_provider`** | Zapisywanie zdjęć bezpośrednio w pamięci urządzenia (baza przechowuje tylko ścieżki). |
| **Zdjęcia** | **`image_picker`** | Obsługa aparatu i galerii z wbudowaną kompresją obrazu. |

## 3. Architektura Danych (Schema)

Aplikacja będzie operować na dwóch głównych kolekcjach (Hive Boxes).

### A. Model: `FishItem` (Katalog Produktów)

Obiekt reprezentujący rodzaj ryby dostępny w sprzedaży.

* `uuid` (String): Unikalny identyfikator.
* `name` (String): Nazwa ryby (np. "Dorsz", "Halibut").
* `pricePerKg` (Double/Decimal): Cena za 1 kg.
* `imagePath` (String): Lokalna ścieżka do pliku graficznego na urządzeniu.
* `isActive` (Bool): Flaga dostępności (zamiast usuwania z bazy, ukrywamy na liście sprzedaży).

### B. Model: `Transaction` (Historia Sprzedaży)

Obiekt pojedynczego ważenia/sprzedaży.

* `uuid` (String): Unikalny identyfikator transakcji.
* `fishNameSnapshot` (String): Kopia nazwy ryby w momencie sprzedaży (zabezpieczenie przed edycją katalogu).
* `weightInKg` (Double): Zważona masa (np. 1.250).
* `totalPrice` (Double/Decimal): Wyliczona cena końcowa.
* `timestamp` (DateTime): Data i czas operacji.

## 4. Funkcjonalności Szczegółowe

### 4.1. Moduł Sprzedaży (Dashboard)

* **Widok:** Siatka (Grid) kafelków. Każdy kafelek zawiera zdjęcie, nazwę i cenę/kg.
* **Interakcja:** Kliknięcie w kafelek otwiera modal (Dialog).
* **Logika kalkulatora:**
1. Użytkownik wprowadza wagę (klawiatura numeryczna).
2. Aplikacja przelicza w czasie rzeczywistym: `Waga * Cena`.
3. Zastosowanie zaokrąglenia matematycznego do 2 miejsc po przecinku ("do grosza").


* **Zatwierdzenie:** Przycisk "OK" zapisuje obiekt `Transaction` do bazy, wyświetla komunikat potwierdzenia (Toast) i czyści formularz.

### 4.2. Moduł Historii i Statystyk

* **Zakres:** Lista transakcji z bieżącej sesji (od ostatniego wyczyszczenia).
* **Nagłówek (Sticky Header):** Podsumowanie sumaryczne:
* `Suma Wagi` (kg)
* `Utarg Całkowity` (PLN)


* **Lista:** Przewijana lista wpisów: *Nazwa Ryby | Waga | Cena Końcowa | Godzina*.
* **Reset Dnia:** Przycisk "ZAKOŃCZ DZIEŃ".
* **Akcja:** Trwałe usunięcie wszystkich rekordów z kolekcji `Transaction`.
* **Wymagane potwierdzenie:** Tak (Dialog "Czy na pewno?").



### 4.3. Moduł Ustawień

* **Zarządzanie Wyglądem:** Przełącznik (Switch) Tryb Ciemny / Tryb Jasny.
* **Zarządzanie Rybami (CRUD):**
* **Dodawanie:** Formularz (Nazwa, Cena). Zdjęcie: Wybór źródła (Aparat/Galeria) -> Kompresja -> Zapis do pamięci aplikacji.
* **Edycja:** Zmiana ceny lub zdjęcia istniejącej pozycji.
* **Usuwanie:** Oznaczenie ryby jako nieaktywnej (ukrycie na Dashboardzie).



## 5. Wymagania Niefunkcjonalne i Ograniczenia

1. **Offline-First:** Aplikacja nie wykonuje żadnych zapytań sieciowych.
2. **Zarządzanie Pamięcią:**
* Zdjęcia muszą być kompresowane przy zapisie (max szerokość ~600px, jakość ~50-70%), aby uniknąć `OutOfMemoryError` na starych urządzeniach.


3. **Obsługa Błędów:**
* Brak zdjęcia nie może wywalać aplikacji (zastosowanie `Placeholder` / domyślnej ikony).
* Wpisanie wagi `0` lub ujemnej musi być zablokowane walidacją.


4. **Interfejs (UI):**
* Elementy klikalne (przyciski, kafelki) muszą mieć minimalny rozmiar 48x48dp (łatwość obsługi na ekranie dotykowym w barze).
* Duży kontrast czcionek.



## 6. Struktura Plików (Sugerowana)

```text
lib/
├── main.dart           # Punkt startowy, konfiguracja motywu
├── models/             # Klasy danych (Hive Objects)
│   ├── fish_item.dart
│   └── transaction.dart
├── screens/            # Główne widoki
│   ├── dashboard_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── widgets/            # Elementy wielokrotnego użytku
│   ├── fish_card.dart  # Kafelek ryby
│   └── input_dialog.dart
├── services/           # Logika biznesowa
│   ├── database_service.dart # Obsługa Hive
│   └── image_service.dart    # Obsługa zapisu zdjęć
└── utils/
    └── calculations.dart # Logika matematyczna (Decimal)

```