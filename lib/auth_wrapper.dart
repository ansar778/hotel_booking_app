import 'package:bookingapp/pages/home.dart'; // Import your Home page
import 'package:bookingapp/pages/login.dart'; // Import your Login page
import 'package:bookingapp/pages/onboarding.dart'; // Import your Onboarding page
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a StreamBuilder to listen to the user's authentication state
    return StreamBuilder<User?>(
      // This stream provides events whenever the user's login state changes
      // (e.g., user signs in, signs out)
      stream: FirebaseAuth.instance.authStateChanges(),

      // The builder is called every time the stream emits a new event (user state changes)
      builder: (context, snapshot) {
        // Check the state of the connection to the Firebase stream
        if (snapshot.connectionState == ConnectionState.active) {
          // The connection is active. Now we can check the data.

          // Get the User object from the stream snapshot.
          // If the user is logged in, this will be a User object.
          // If the user is logged out, this will be 'null'.
          final User? user = snapshot.data;

          if (user != null) {
            // User is LOGGED IN
            // Therefore, take them to the main app screen (Home)
            return Home();
          } else {
            // User is NOT LOGGED IN (user is null)
            // Therefore, take them to the Onboarding screen (which has options to Login/Signup)
            return Onboarding();
          }
        }

        // If the connection to Firebase is not yet active (e.g., still checking),
        // show a loading spinner so the user doesn't see a blank screen.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // This is the loading spinner
          ),
        );
      },
    );
  }
}
