import 'package:flutter/material.dart';
import 'package:mad_hms/notifications/notification_service.dart';
import 'package:provider/provider.dart';

import 'theme_settings_widget.dart';

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProfileProvider>(
      builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profileProvider.profilePictureUrl.isNotEmpty
                          ? NetworkImage(profileProvider.profilePictureUrl)
                          : null,
                  child:
                      profileProvider.profilePictureUrl.isEmpty
                          ? Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Logic to upload profile picture
                },
                child: const Text('Upload Profile Picture'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: profileProvider.name),
                onChanged: (value) {
                  profileProvider.updateProfile(
                    newName: value,
                    newAge: profileProvider.age,
                    newDescription: profileProvider.description,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Age'),
                controller: TextEditingController(text: profileProvider.age),
                onChanged: (value) {
                  profileProvider.updateProfile(
                    newName: profileProvider.name,
                    newAge: value,
                    newDescription: profileProvider.description,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                controller: TextEditingController(
                  text: profileProvider.description,
                ),
                onChanged: (value) {
                  profileProvider.updateProfile(
                    newName: profileProvider.name,
                    newAge: profileProvider.age,
                    newDescription: value,
                  );
                },
              ),
              const SizedBox(height: 64),
              const ThemeSettingsWidget(),
            ],
          ),
        );
      },
    );
  }
}

//Here the what the patient profile page will look like:

/*

Here he should be able to upload his profile picture, edit his personal information like name, age, gender, and contact number, description.

and also adjust the app theme settings.


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




we should create a provider to manage the profile of the user and also handle all the firebase related operations like uploading the profile picture, updating the user information, etc.
 */

class PatientProfileProvider with ChangeNotifier {
  String name = '';
  String age = '';
  DateTime? createdAt;
  String description = '';
  String profilePictureUrl = '';
  String myFMCToken = '';

  List<Appointment> appointments = [];

  bool isUploading = false;

  void updateProfile({
    required String newName,
    required String newAge,
    required String newDescription,
  }) {
    name = newName;
    age = newAge;
    description = newDescription;

    notifyListeners();
  }

  Future<void> forceDownloadProfileFromFirebase() async {
    myFMCToken = await NotificationService.getFCMToken();

    // Logic to force download profile from Firebase
    // This could involve fetching the latest data from Firestore or Realtime Database
    // and updating the local state accordingly.
  }

  Future<void> uploadProfilePicture(String filePath) async {
    isUploading = true;
    notifyListeners();
    // Logic to upload profile picture to Firebase Storage
    // After uploading, update the profilePictureUrl and notify listeners
    // Example:
    // profilePictureUrl = await uploadToFirebaseStorage(filePath);
    isUploading = false;
    notifyListeners();
  }
}

class Appointment {
  final String docRefOfDoctor;
  final DateTime appointmentDateTime;

  Appointment({
    required this.docRefOfDoctor,
    required this.appointmentDateTime,
  });
}
