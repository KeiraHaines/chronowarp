import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_creation_page.dart';
import 'package:chronowarp/services/firestore_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // The root auth listener opens Home as soon as sign-in succeeds.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      // Profile synchronization must not delay entering the app or report a
      // successful authentication as a failed login.
      try {
        await FirestoreService.instance.ensureUserDoc(
          credential.user?.displayName ?? email.split('@').first,
        );
      } catch (error) {
        debugPrint('Profile synchronization after login failed: $error');
      }
    } on FirebaseAuthException catch (e) {
      // ... rest unchanged
      String message;

      switch (e.code) {
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'user-not-found':
          message = 'No user found';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        case 'invalid-credential':
          // Newer Firebase versions return this for both wrong password
          // and unknown user, to avoid leaking which one it was.
          message = 'Incorrect email or password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        default:
          message = 'Login failed';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 111, 101),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: const Color.fromRGBO(20, 20, 20, 0.9),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 41, 49, 1),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/DarkLoginBck.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/DarkBannerReBck.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            if (!keyboardVisible)
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/DarkBannerReBck.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/LogoLightNoBck.png'),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            filled: true,
                            fillColor: const Color.fromRGBO(242, 234, 223, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: Color.fromARGB(255, 255, 111, 101),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: const Color.fromRGBO(242, 234, 223, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: Color.fromARGB(255, 255, 111, 101),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: 300,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2EADF),
                            foregroundColor: const Color(0xFF1A2931),
                            disabledBackgroundColor: const Color(0xFFD9D2C8),
                            disabledForegroundColor: const Color(0xFF607078),
                            surfaceTintColor: Colors.transparent,
                            elevation: 2,
                            shadowColor: const Color(0x66000000),
                            side: const BorderSide(
                              color: Color(0xFFE86D1F),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE86D1F),
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserCreationPage(),
                                  ),
                                );
                              },
                        child: const Text("Create account"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
