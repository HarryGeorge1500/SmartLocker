import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locker/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController emailId = TextEditingController();
final TextEditingController username = TextEditingController();
final TextEditingController password = TextEditingController();
final TextEditingController cPassword = TextEditingController();

final userDetailsService = UserDetailsService();

class NewRegister extends StatelessWidget {
  const NewRegister({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Registration'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'User Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: emailId,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: cPassword,
              decoration: const InputDecoration(labelText: 'Conform Password'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  if (!emailId.text.endsWith('@gcek.ac.in')) {
                    //checking mail entered have gcek handle
                    showDialog(
                      context: context, // Pass the context explicitly
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Invalid email'),
                          content: const Text(
                              'Please enter a valid email address ending with @gcek.ac.in.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  } else if(password!=cPassword){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Conform Password'),
                          content: const Text('Please check your password. Re-entered password dosen\'t match with '
                              'initial password'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                  else {
                    try {
                      final AuthResponse res = await supabase.auth.signUp(
                        email: emailId.text,
                        password: password.text,
                      );
                      final Session? session = res.session;
                      final User? user = res.user;
                      await userDetailsService.writeUserData();

                      if (user != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Registration successful'),
                              content: const Text(
                                  'Please Log-In with your User ID and Password'),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        if (kDebugMode) {
                          print('Registration Failed');
                        }
                      }
                    } catch (error) {
                      if (kDebugMode) {
                        print('Error Registering');
                      }
                      showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text('Registration Failed'),
                              content: const Text(
                                  'Error Registering. Please try again later.'),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                      },);
                    };
                  }
                },
                child: const Text('Register'),
              );
            }),
          )
        ],
      ),
    );
  }
}

class UserDetailsService {

  Future<void> writeUserData() async {
    try {
      final response = await supabase.from('UserDetails').insert({
        'name': username.text,
        'email_id': emailId.text,
        'status':0,
      });

      if (response.error != null) {
        throw Exception('Error writing data to Supabase: ${response.error.message}');
      }

      if (kDebugMode) {
        print('Data written to Supabase successfully!');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }
}