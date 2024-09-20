import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app_admin/views/main_screen.dart';
import 'package:multi_store_app_admin/views/auth_screens/register_screen.dart';
import 'package:multi_store_app_admin/controllers/auth_controller.dart';
import 'package:multi_store_app_admin/views/auth_screens/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authController = AuthController();

  bool _isLoading = false;
  bool _isObscure = true;

  late String email;
  late String password;

  @override
  void initState() {
    super.initState();

    // Listen for authentication state changes to detect if user is already logged in
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in, navigate to MainScreen
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        });
      }
    });
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var response = await authController.loginUser(email, password);

      if (response == "success") {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return const MainScreen();
            },
          ));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged in Successfully')));
        }).whenComplete(() {
          _formKey.currentState!.reset();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login Failed: $response')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Image.asset(
                          'assets/images/Illustration.png',
                          width: 300,
                          height: 300,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: _buildLoginForm(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Enter your email',
              hintText: 'user@example.com',
              prefixIcon: const Icon(Icons.mail),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onChanged: (value) {
              email = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: passwordController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            obscureText: _isObscure,
            onChanged: (value) {
              password = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 10.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _isLoading ? null : loginUser,
                  child: Text(
                    'Login',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const RegisterScreen();
                    },
                  ));
                },
                child: Text(
                  'Register here',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
