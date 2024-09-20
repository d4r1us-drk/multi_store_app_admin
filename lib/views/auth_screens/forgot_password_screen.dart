import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app_admin/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final authController = AuthController();
  bool _isLoading = false;

  void resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var response = await authController.resetPassword(emailController.text);

      if (response == "success") {
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent!')),
          );
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
            emailController.clear();
          });
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $response')),
        );
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
                    color: Colors.purpleAccent,
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
                      child: _buildForgotPasswordForm(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: _buildForgotPasswordForm(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forgot Password',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
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
                  onPressed: _isLoading ? null : resetPassword,
                  child: Text(
                    'Send Reset Link',
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
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Go back to login',
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
    );
  }
}
