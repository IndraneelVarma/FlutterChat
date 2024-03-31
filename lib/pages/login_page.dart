import 'package:flutter/material.dart';
import 'package:flutterchat/components/text_field.dart';
import 'package:flutterchat/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final emailController = TextEditingController();

  final pwController = TextEditingController();

  //sign in
  void signIn() async {
    print("Tapped");
    //get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailPassword(
          emailController.text, pwController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 85,
                ),
                //logo
                const Icon(
                  Icons.message,
                  size: 80,
                  color: Colors.lightBlue,
                ),
                const SizedBox(
                  height: 75,
                ),

                //welcome back
                const Text(
                  "Welcome back You've been missed!",
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                ),
                const SizedBox(
                  height: 25,
                ),
                //email textfield
                MyTextField(
                    controller: emailController,
                    obscureText: false,
                    hintText: 'Email'),
                const SizedBox(
                  height: 15,
                ),
                //pw textfield
                MyTextField(
                    controller: pwController,
                    obscureText: true,
                    hintText: 'password'),
                const SizedBox(
                  height: 25,
                ),

                //sign in button
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                    onPressed: signIn,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.lightBlue, fontSize: 20),
                    )),
                const SizedBox(
                  height: 40,
                ),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
