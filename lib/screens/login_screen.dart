import 'package:flutter/material.dart';
import 'package:sync_list/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //1. Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter an email';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),

              //2. Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Enter a valid password';
                  }
                  return null;
                },
              ),

              //3. SignUp and LogIn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3.1 SignUp
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = await _authService.signUp(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (user != null) {
                          print('Success! User created: ${user.uid}');
                        }
                      }
                    },
                    child: Text('Sign up'),
                  ),

                  // 3.2 LogIn
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = await _authService.logIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (user != null) {
                          print('Success! Logged in as: ${user.uid}');
                        }
                      }
                    },
                    child: Text('LogIn'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
