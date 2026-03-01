import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'SignUpPage.dart';
import 'HomePage.dart';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isVisible = true;
  bool _isLoadingLogin = false;
  bool _isLoadingGoogle = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '62326984297-7h3mhkib7rjg4paqfkomvrq83t8omnrb.apps.googleusercontent.com',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Username and password cannot be empty');
      return;
    }

    setState(() => _isLoadingLogin = true);
    try {
      final result = await AuthService.login(username, password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: result['user'])),
        (_) => false,
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoadingLogin = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: result['user'])),
          (_) => false,
        );
      }
    } catch (e) {
      _showError('Google Sign-In failed');
      debugPrint('Google Sign-In error: $e');
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
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              height: 20.0,
              width: 20.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/loginpage/adminLogo.png"),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 130),
                      Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 27,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.bold,
                          color: MainTextColor,
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                          color: MainTextColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: MainTextColor),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          hintText: "Your Username",
                          hintStyle: TextStyle(color: HintTextColor),
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
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                          color: MainTextColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isVisible,
                        style: TextStyle(color: MainTextColor),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          hintText: "min. 8 characters",
                          hintStyle: TextStyle(color: HintTextColor),
                          filled: true,
                          fillColor: CardFillColor,
                          suffixIcon: IconButton(
                            icon: Image.asset(
                              _isVisible
                                  ? "assets/loginpage/eyeClose.png"
                                  : "assets/loginpage/eyeOpen.png",
                              width: 17,
                              height: 17,
                            ),
                            onPressed: () {
                              setState(() {
                                _isVisible = !_isVisible;
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
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: (_isLoadingLogin || _isLoadingGoogle) ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ButtonFillColor,
                            side: BorderSide(color: CardStrokeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoadingLogin
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: MainTextColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Log In",
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
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Having trouble logging in?",
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: "Alexandria",
                                fontWeight: FontWeight.w300,
                                color: MainTextColor,
                              ),
                            ),
                            SizedBox(width: 3),
                            GestureDetector(
                              onTap: () async {
                                final Uri url = Uri.parse(
                                  "https://cs.hoyoverse.com/static/hoyoverse-new-csc-service-hall-fe/index.html?page_id=19&login_type=visitor&game_biz=platform_hyvpass&lang=en-us&utm_source=genshin&utm_medium=footer#/home",
                                );
                                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                  throw Exception("Could not launch $url");
                                }
                              },
                              child: Text(
                                "Click Here",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: "Alexandria",
                                  fontWeight: FontWeight.w500,
                                  color: MainTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Divider(color: CardStrokeColor, thickness: 1),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: (_isLoadingLogin || _isLoadingGoogle) ? null : _handleGoogleSignIn,
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
                                      "Sign In with Google",
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
                      SizedBox(height: 31),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Have not registered yet? ",
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: "Alexandria",
                                fontWeight: FontWeight.w300,
                                color: MainTextColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
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
        ],
      ),
    );
  }
}
