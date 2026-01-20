import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/signup_screen.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        developer.log('Attempting login for: ${_emailController.text}',
            name: 'LoginScreen');
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        developer.log('Login successful!', name: 'LoginScreen');
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        developer.log('Login Error: ${e.code} - ${e.message}',
            name: 'LoginScreen');
        String message;
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          message = 'No user found or wrong password.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password.';
        } else if (e.code == 'operation-not-allowed') {
          message =
              'Login disabled. Please enable Email/Password Sign-in in Firebase Console.';
        } else {
          message = 'Error (${e.code}): ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        developer.log('Unknown Login Error: $e', name: 'LoginScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. YOUR LOGO
                Image.asset(
                  'assets/images/rx_genie_logo.png',
                  height: 200,
                ),
                const SizedBox(height: 16),
                
                // 2. WELCOME BACK TEXT (Updated to White)
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ Changed to White
                      ),
                ),
                const SizedBox(height: 48),

                // 3. EMAIL INPUT
                TextFormField(
                  controller: _emailController,
                  // Added style to make input text white if needed
                  style: const TextStyle(color: Colors.white), 
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    // Make label and icon lighter so they are visible
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. PASSWORD INPUT
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 5. SIGN IN BUTTON
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. SIGN UP TEXT LINK (Updated to White)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      // ✅ Base text color changed to white
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white, 
                          ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // You can keep primary color or make it a bright accent
                            color: Theme.of(context).colorScheme.primary, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 7. GUEST LOGIN BUTTON (Updated to White)
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signInAnonymously();
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        String msg = 'Guest login failed: ${e.message}';
                        if (e.code == 'operation-not-allowed') {
                          msg =
                              'Guest Login disabled. Enable "Anonymous" in Firebase Console.';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(msg), backgroundColor: Colors.red));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Guest login failed: $e')));
                      }
                    }
                  },
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(color: Colors.white70), // ✅ Changed to light color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}