import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locker/avail_lock.dart';
import 'package:locker/subscription.dart';
import 'main.dart';

class FindLocker extends StatelessWidget {
  final String email;

  const FindLocker({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Locker'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(email),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              onPressed: () async {
                // Sign-out logic
                await supabase.auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
                await supabase
                    .from('UserDetails')
                    .update({'status': 0})
                    .match({'email_id': email});
              },
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 200),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Availability(
                        currentUser: email, country: 'India', state: 'Kerala', district: 'Kannur'
                    ),
                  ),
                );
              },
              child: const Text('Check Availability'),
            ),
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final response = await supabase
                      .from('DeviceStatus')
                      .select('device')
                      .eq('current_user', email)
                      .single();

                  final deviceName = response['device'] as String?;
                  if (deviceName != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SubscriptionPage(name: deviceName, user: email),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                        content: const Text('Please subscribe a locker'),
                        duration: const Duration(seconds: 5),
                        width: 280.0,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  // Handle unexpected errors, e.g., network issues
                  if (kDebugMode) {
                    print('Error: $error');
                  }
                  // Show an error message to the user if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {},
                      ),
                      content: const Text('Please subscribe a locker'),
                      duration: const Duration(seconds: 15),
                      width: 280.0,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                }
              },
              child: const Text('My Locker'),
            ),
          ),
        ],
      ),
    );
  }
}
