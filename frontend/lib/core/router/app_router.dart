import 'package:flutter/material.dart';
import '../../features/auth/language_select_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/symptom/presentation/symptom_analyzer_screen.dart';
import '../../features/hospital/hospital_locator_screen.dart';
import '../../features/medicine/medicine_reminder_screen.dart';
import '../../features/medicine/ocr_scanner_screen.dart';
import '../../features/symptom/presentation/history_screen.dart';
import '../../features/family/family_screen.dart';
import '../../features/ayushman/ayushman_screen.dart';
import '../../features/pregnancy/pregnancy_screen.dart';
import '../../features/vaccine/vaccine_screen.dart';
import '../../features/info/nutrition_screen.dart';
import '../../features/info/outbreaks_screen.dart';
import '../../features/info/donors_screen.dart';
import '../../features/home/settings_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String languageSelect = '/language-select';
  static const String login = '/login';
  static const String home = '/home';
  static const String symptoms = '/symptoms';
  static const String hospitals = '/hospitals';
  static const String reminders = '/reminders';
  static const String ocr = '/ocr';
  static const String history = '/history';
  static const String family = '/family';
  static const String ayushman = '/ayushman';
  static const String pregnancy = '/pregnancy';
  static const String vaccine = '/vaccine';
  static const String nutrition = '/nutrition';
  static const String alerts = '/alerts';
  static const String donors = '/donors';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const LanguageSelectScreen(),
    languageSelect: (context) => const LanguageSelectScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    symptoms: (context) => const SymptomAnalyzerScreen(),
    hospitals: (context) => const HospitalLocatorScreen(),
    reminders: (context) => const MedicineReminderScreen(),
    ocr: (context) => const OcrScannerScreen(),
    history: (context) => const HistoryScreen(),
    family: (context) => const FamilyScreen(),
    ayushman: (context) => const AyushmanScreen(),
    pregnancy: (context) => const PregnancyScreen(),
    vaccine: (context) => const VaccineScreen(),
    nutrition: (context) => const NutritionScreen(),
    alerts: (context) => const OutbreaksScreen(),
    donors: (context) => const DonorsScreen(),
    settings: (context) => const SettingsScreen(),
  };

  // Navigation Helper
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void replaceWith(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void popToDashboard(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName(home));
  }
}
