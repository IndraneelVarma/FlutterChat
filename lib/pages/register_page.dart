import 'package:flutter/material.dart';
import 'package:flutterchat/components/text_field.dart';
import 'package:flutterchat/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();

  final pwController = TextEditingController();

  final cpwController = TextEditingController();

  //sign up
  void signUp() async {
    if (pwController.text != cpwController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords don't match!")));
      return;
    }

    //get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailAndPassword(
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

                //create account message
                const Text(
                  "Let's create an account for you!",
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

                //confirm pw textfield
                MyTextField(
                    controller: cpwController,
                    obscureText: true,
                    hintText: "confirm"),
                const SizedBox(
                  height: 25,
                ),

                //sign in button
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                    onPressed: signUp,
                    child: const Text(
                      "Sign Up",
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
                      "Already a member?",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Sign in",
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
