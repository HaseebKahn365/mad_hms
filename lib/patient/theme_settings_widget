import 'package:flutter/material.dart';
import 'package:mad_hms/themes/provider.dart';
import 'package:provider/provider.dart';

class ThemeSettingsWidget extends StatelessWidget {
  const ThemeSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<M3ThemeProvider>(
      builder: (context, themeProvider, child) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      String colorName = getColorName(color);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: color,
                        ),
                        title: Text(colorName),
                        trailing: themeProvider.seedColor.toString() ==
                                color.toString()
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
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
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}