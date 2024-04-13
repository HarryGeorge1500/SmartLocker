/*
Auther : Harry George
Github : https://github.com/HarryGeorge1500/
 */
import 'package:flutter/material.dart';
import 'package:locker/forgot.dart';
import 'package:locker/home.dart';
import 'package:locker/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//TODO: Payment

void main() async{
  await Supabase.initialize(
    url: 'url',
    anonKey: 'api key',
  );
  runApp(const MyApp());
}
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController controllerEmail =TextEditingController();
    final TextEditingController controllerPassword =TextEditingController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 25,
            color: Colors.white
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ),
      home:Scaffold(
        appBar: AppBar(
          title: const Text('Smart Lock'),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: controllerEmail,
                decoration: const InputDecoration(
                  labelText: 'Email'
                ),
              ),
              TextField(
                controller: controllerPassword,
                decoration: const InputDecoration(
                    labelText: 'Password'
                ),
                obscureText: true,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(onPressed: () async {
                      if (!controllerEmail.text.endsWith('@gcek.ac.in')) {
                        //checking mail entered have gcek handle
                        showDialog(
                          context: context,  // Pass the context explicitly
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Invalid email'),
                              content: const Text('Please enter a valid email address ending with @gcek.ac.in.'),
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
                      }
                      try {
                        final AuthResponse res = await supabase.auth.signInWithPassword(
                          email: controllerEmail.text,
                          password: controllerPassword.text,
                        );

                        await supabase
                            .from('UserDetails')
                            .update({ 'status': 1 })
                            .match({ 'email_id': controllerEmail.text });
                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context)=>FindLocker(
                                email:controllerEmail.text
                              ),
                            ),
                          );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }

                    },
                        child: const Text('Sign-In'),
                    );
                  }
                ),
              ),
              Builder(
                builder: (context) {
                  return TextButton(onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context)=>const NewRegister(),
                      ),
                    );
                  },
                      child: const Text('New User? Register'));
                }
              ),
              Builder(
                builder: (context) {
                  return TextButton(onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context)=>const ForgotPass(),
                      ),
                    );
                  },
                      child: const Text('Forgot Password'));
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
