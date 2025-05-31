import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create:
          (context) => M3ThemeProvider(
            seedColor: Colors.blue, // Seed color for the theme
            themeMode: ThemeMode.system, // Default theme mode
          ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<M3ThemeProvider>(
        context,
        listen: false,
      );
      themeProvider.surfaceColorOverride();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAD Assignment 4',
      debugShowCheckedModeBanner: false,

      themeMode: Provider.of<M3ThemeProvider>(context).themeMode,
      theme: Provider.of<M3ThemeProvider>(context).lightTheme,
      darkTheme: Provider.of<M3ThemeProvider>(context).darkTheme,
      home: Builder(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('Project HMS'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Welcome to Hospital Management System'),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<M3ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();
                      },
                      child: Text('Toggle Theme'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

//settings screen to change seed color and toggle surface color override
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Color> colorOptions = const [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure the theme provider is available
    final themeProvider = Provider.of<M3ThemeProvider>(context, listen: false);
    // pickedColor = themeProvider.lightColorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Consumer<M3ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Colors',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              colorOptions.map((color) {
                                return InkWell(
                                  onTap:
                                      () =>
                                          themeProvider.changeSeedColor(color),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: color,
                                    child:
                                        themeProvider.seedColor == color
                                            ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//Theme provider: using material 3 theme
class M3ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  ColorScheme lightColorScheme;
  ColorScheme darkColorScheme;
  Color seedColor;
  bool get isDarkMode =>
      themeMode == ThemeMode.dark ||
      themeMode == ThemeMode.system &&
          darkColorScheme.brightness == Brightness.dark;

  M3ThemeProvider({this.themeMode = ThemeMode.system, required this.seedColor})
    : lightColorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      darkColorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );

  surfaceColorOverride() {
    lightColorScheme = lightColorScheme; //dont override light surface color
    darkColorScheme = darkColorScheme.copyWith(
      surface:
          HSLColor.fromColor(
            darkColorScheme.surface,
          ).withLightness(0.001).toColor(),
    );

    log('Surface color overridden with darker shade');
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void changeSeedColor(Color seedColor) {
    lightColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    surfaceColorOverride(); // Reapply surface color override
    notifyListeners();
  }

  ThemeData get lightTheme =>
      ThemeData(useMaterial3: true, colorScheme: lightColorScheme);

  ThemeData get darkTheme =>
      ThemeData(useMaterial3: true, colorScheme: darkColorScheme);
}
