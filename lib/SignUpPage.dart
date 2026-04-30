import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/google_auth_config.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isVisible1 = true;
  bool _isVisible2 = true;
  bool _isLoadingSignUp = false;
  bool _isLoadingGoogle = false;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: googleServerClientId,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      _showError('All fields are required');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoadingSignUp = true);
    try {
      final result = await AuthService.register(username, email, password);
      if (!mounted) return;
      final userRaw = result['user'];
      if (userRaw is! Map) throw Exception('Invalid registration response');
      final user = Map<String, dynamic>.from(userRaw);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
        (_) => false,
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoadingSignUp = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    if (!isGoogleSignInConfigured) {
      _showError('Google Sign-In is not configured for this build.');
      return;
    }

    setState(() => _isLoadingGoogle = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        final idToken = auth.idToken;

        if (idToken == null) {
          _showError('Could not get Google token. Set serverClientId first.');
          return;
        }

        final result = await AuthService.loginWithGoogle(idToken);
        if (!mounted) return;
        final userRaw = result['user'];
        if (userRaw is! Map) throw Exception('Invalid login response');
        final user = Map<String, dynamic>.from(userRaw);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)),
          (_) => false,
        );
      }
    } catch (e) {
      _showError('Google Sign-Up failed');
      debugPrint('Google Sign-Up error: $e');
    } finally {
      setState(() => _isLoadingGoogle = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }


  @override
  Widget build(BuildContext context) {
    Color BGColor = const Color(0xE61F1F1F);
    Color MainTextColor = const Color(0xFFF5F5F5);
    Color HintTextColor = const Color(0xFF88888A);
    Color CardFillColor = const Color(0x1AD9D9D9);
    Color CardStrokeColor = const Color(0xFFDBDBDB);
    Color ButtonFillColor = const Color(0x80D9D9D9);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/loginpage/backgroundImage.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: BGColor),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 130),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Alexandria",
                      color: MainTextColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: MainTextColor, fontSize: 12),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            hintText: "player@genshin.import",
                            hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
                            filled: true,
                            fillColor: CardFillColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: MainTextColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 13),
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: _usernameController,
                          style: TextStyle(color: MainTextColor, fontSize: 12),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            hintText: "Your name",
                            hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
                            filled: true,
                            fillColor: CardFillColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: MainTextColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 13),
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isVisible1,
                          style: TextStyle(color: MainTextColor, fontSize: 12),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            hintText: "min. 8 characters",
                            hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
                            filled: true,
                            fillColor: CardFillColor,
                            suffixIcon: IconButton(
                              icon: Image.asset(
                                _isVisible1
                                    ? "assets/loginpage/eyeClose.png"
                                    : "assets/loginpage/eyeOpen.png",
                                width: 17,
                                height: 17,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isVisible1 = !_isVisible1;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: MainTextColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 13),
                        Text(
                          "Reconfirm Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _isVisible2,
                          style: TextStyle(color: MainTextColor, fontSize: 12),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            hintText: "min. 8 characters",
                            hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
                            filled: true,
                            fillColor: CardFillColor,
                            suffixIcon: IconButton(
                              icon: Image.asset(
                                _isVisible2
                                    ? "assets/loginpage/eyeClose.png"
                                    : "assets/loginpage/eyeOpen.png",
                                width: 17,
                                height: 17,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isVisible2 = !_isVisible2;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: MainTextColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: (_isLoadingSignUp || _isLoadingGoogle) ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonFillColor,
                              side: BorderSide(color: CardStrokeColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoadingSignUp
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: MainTextColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Alexandria",
                                      fontWeight: FontWeight.w600,
                                      color: MainTextColor,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Divider(color: CardStrokeColor, thickness: 1),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: (_isLoadingSignUp || _isLoadingGoogle) ? null : _handleGoogleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonFillColor,
                              side: BorderSide(color: CardStrokeColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoadingGoogle
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: MainTextColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icon/google-icon.png',
                                        width: 18,
                                        height: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Sign Up with Google",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Alexandria",
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: "Alexandria",
                                  fontWeight: FontWeight.w300,
                                  color: MainTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: "Alexandria",
                                    fontWeight: FontWeight.w600,
                                    color: MainTextColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: MainTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
