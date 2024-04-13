import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:locker/reset.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithOtp(
        email: emailController.text,
        shouldCreateUser: false,
      );
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (EmailValidator.validate(emailController.text)) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context)=>VerifyOtpScreen(email: emailController.text),
                    ),
                  );
                  _sendPasswordResetEmail();
                } else {
                  // Show an error message for invalid email
                  print('Invalid email address');
                }
              },
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyOtpScreen extends StatelessWidget {
  VerifyOtpScreen({super.key, required this.email});

  final String email;
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the 6-digit code',
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  final response =
                  await Supabase.instance.client.auth.verifyOTP(
                    email: email,
                    token: _otpController.text,
                    type: OtpType.email,
                  );
                  final route = MaterialPageRoute(
                      builder: (_) => const Reset());
                  navigator.pushReplacement(route);
                } catch (err) {
                  scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Something went wrong')));
                }
              },
              child: const Text('Verify OTP'),
            )
          ],
        ),
      ),
    );
  }
}
