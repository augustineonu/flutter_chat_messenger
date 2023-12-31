import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/components/my_button.dart';
import 'package:flutter_chat_messenger/components/textfield.dart';
import 'package:flutter_chat_messenger/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
        ),
      );
      return;
    }

    // Print the values before sending to the API
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");
    print("Full Name: ${fullNameController.text}");

    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(emailController.text,
          passwordController.text, fullNameController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    // logo
                    const Icon(
                      Icons.message,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    // create an account
                    const Text(
                      "Let's create an account for you!",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // Fullname textfield
                    MyTextField(
                      obscureText: false,
                      hintText: 'Full name',
                      controller: fullNameController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // email textfield
                    MyTextField(
                      obscureText: false,
                      hintText: 'Email',
                      controller: emailController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // password textfield
                    MyTextField(
                      obscureText: true,
                      hintText: 'Password',
                      controller: passwordController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // confirm password textfield
                    MyTextField(
                      obscureText: true,
                      hintText: 'Confirm Password',
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),

                    // sign up button
                    MyButton(onTap: signUp, text: "Sign Up"),
                    const SizedBox(
                      height: 25,
                    ),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already a member?"),
                        const SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
