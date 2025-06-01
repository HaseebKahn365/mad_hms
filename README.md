# mad_hms

A mobile flutter app for managing hospital.

## Architecture

the app will use an enum to define the type of user currently logged in.
enum AppFor { patient, doctor, admin }

AppFor currUserType = AppFor.patient;


# Patient app:

a login and registration page for patients.

there is not auth just simply using the document on the firestore to create and login the user.

There are gonna be 4 tabs:
1. Home : shows profile settings, appointments and medicine orders.
2. Doctors : shows a list of doctors with their details and a button to book an appointment.
3. Medicines : shows a list of medicines with their details and a button to order the medicine.
4. Profile : shows the profile of the user with a button to edit the profile.
