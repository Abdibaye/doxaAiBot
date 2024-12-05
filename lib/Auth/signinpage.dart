import 'package:doxabot/Auth/loginpage.dart';
import 'package:doxabot/hive/boxes.dart';
import 'package:doxabot/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    void register() async {
      print("Register button pressed"); // Debug
      if (usernameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        print("Fields are empty"); // Debug
        _showDialog("Error", "All fields are required");
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        print("Passwords do not match"); // Debug
        _showDialog("Error", "Passwords do not match");
        return;
      }

      // Attempt to register the user
      String message = await chatProvider.registerUser(
        usernameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      );

      print("Register result: $message"); // Debug

      // Show dialog based on registration result
      _showDialog(
        message == 'Registration successful' ? "Success" : "Error",
        message,
        onSuccess: () {
          if (message == 'Registration successful') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildHeader(),
              _buildTextField(usernameController, "Username", Icons.person),
              _buildTextField(emailController, "Email", Icons.email),
              _buildTextField(passwordController, "Password", Icons.lock,
                  obscureText: true),
              _buildTextField(
                  confirmPasswordController, "Confirm Password", Icons.lock,
                  obscureText: true),
              _buildSignupButton(register),
              _buildGoogleSignInButton(),
              _buildLoginRedirect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const <Widget>[
        SizedBox(height: 60.0),
        Text("Sign up",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Text("Create your account",
            style: TextStyle(fontSize: 15, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.purple.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildSignupButton(VoidCallback register) {
    return ElevatedButton(
      onPressed: register,
      child: const Text("Sign up",
          style: TextStyle(fontSize: 20, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.purple),
      ),
      child: TextButton(
        onPressed: () {
          // Implement Google sign-in functionality
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.g_translate, color: Colors.purple), // Google Icon
            SizedBox(width: 18),
            Text("Sign In with Google",
                style: TextStyle(fontSize: 16, color: Colors.purple)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          child: const Text("Login", style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }

  void _showDialog(String title, String content, {VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onSuccess != null) onSuccess();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
