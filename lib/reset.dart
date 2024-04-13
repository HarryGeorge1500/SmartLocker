import 'package:flutter/material.dart';
import 'package:locker/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final TextEditingController newPassController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('**You cannot set a previous password \n**Password must be at-least 6 characters long'
              '\n**Password should have 1 capital letter'),
          const SizedBox(height: 100),
          TextField(
            controller: newPassController,
            decoration: const InputDecoration(
              labelText: 'New Password',
            ),
          ),
          if (errorMessage != null)
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final newPassword = newPassController.text;

    // Validate password (add your validation logic here)
    if (!_isValidPassword(newPassword)) {
      setState(() {
        errorMessage = 'Password must meet above criteria';
        isLoading = false;
      });
      return;
    }

    try {
      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context)=>const MyApp(),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error resetting password: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  bool _isValidPassword(String password) {
    // Example validation (adjust as needed)
    return password.length >= 6 &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'\d'));
  }
}
