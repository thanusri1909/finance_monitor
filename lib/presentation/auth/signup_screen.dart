import 'dart:developer';
import 'package:finance_monitor/core/shared_preference.dart';
import 'package:finance_monitor/presentation/auth/auth_service.dart';
import 'package:finance_monitor/presentation/auth/login_screen.dart';
import 'package:finance_monitor/presentation/home/home_screen.dart';
import 'package:finance_monitor/presentation/widgets/button.dart';
import 'package:finance_monitor/presentation/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Spacer(),
                const Text("Signup",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
                const SizedBox(
                  height: 50,
                ),
                CustomTextField(
                  hint: "Enter Name",
                  label: "Name",
                  controller: _name,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    if (p0.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Email",
                  label: "Email",
                  controller: _email,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(p0)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Password",
                  label: "Password",
                  controller: _password,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    if (p0.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Signup",
                  onPressed: _signup,
                ),
                const SizedBox(height: 50),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Already have an account? "),
                  InkWell(
                    onTap: () => goToLogin(context),
                    child: const Text("Login",
                        style: TextStyle(color: Colors.red)),
                  )
                ]),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

  _signup() async {
    if (_formKey.currentState!.validate()) {
      final user = await _auth.createUserWithEmailAndPassword(
          _email.text, _password.text);
      if (user != null) {
        await SharedPrefHelper.setLoginStatus(true);
        log("User Created Succesfully");
        goToHome(context);
      } else {
        Fluttertoast.showToast(
          msg: "Create profile properly",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }
}
