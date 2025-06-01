import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//settings screen to change seed color and toggle surface color override
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Color> colorOptions = const [
    Colors.blue,
    Colors.lightGreen,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  String getColorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.lightGreen) return 'Light Green';
    if (color == Colors.green) return 'Green';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.indigo) return 'Indigo';
    return 'Unknown Color';
  }

  @override
  Widget build(BuildContext context) {
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Colors',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...colorOptions.map((color) {
                          log(
                            'Theme color: $color and this color: ${color.toString()}',
                          );
                          String colorName = getColorName(color);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: color,
                            ),
                            title: Text(colorName),
                            trailing:
                                themeProvider.seedColor.toString() ==
                                        color.toString()
                                    ? Icon(
                                      Icons.check,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                    : null,
                            onTap: () => themeProvider.changeSeedColor(color),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  elevation: 0,
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
    this.seedColor = seedColor;
    surfaceColorOverride(); // Reapply surface color override
    notifyListeners();
  }

  ThemeData get lightTheme =>
      ThemeData(useMaterial3: true, colorScheme: lightColorScheme);

  ThemeData get darkTheme =>
      ThemeData(useMaterial3: true, colorScheme: darkColorScheme);
}
