import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'theme/destijl_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to match pure De Stijl aesthetic (white bar, black icons)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: DeStijlTheme.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: DeStijlTheme.black,
    ),
  );

  // Initialize Hive and seed sample notes if empty
  await HiveService.init();
  final hiveService = HiveService();
  await hiveService.seedInitialNotesIfEmpty();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(hiveService),
        ),
      ],
      child: const CatatanDeStijlApp(),
    ),
  );
}

class CatatanDeStijlApp extends StatelessWidget {
  const CatatanDeStijlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zryn udah imo | Notes',
      debugShowCheckedModeBanner: false,
      theme: DeStijlTheme.themeData,
      home: const HomeScreen(),
    );
  }
}

