import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'LoginPage.dart';

class LoginPageAdmin extends StatefulWidget {
  const LoginPageAdmin({super.key});

  // This widget is the root of your application.
  @override
  State<LoginPageAdmin> createState() => _LoginPageAdminState();
}

class _LoginPageAdminState extends State<LoginPageAdmin> {

  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    Color BGColor = const Color(0xE61F1F1F);
    Color MainTextColor = const Color(0xFFF5F5F5);
    Color HintTextColor = const Color(0xFF88888A);
    Color CardFillColor = const Color(0x1AD9D9D9);
    Color CardStrokeColor = const Color(0xFFDBDBDB);
    Color ButtonFillColor = const Color(0x80D9D9D9);
    Color BlackTextColor = const Color(0xFF000000);

    return Scaffold(
      body: Stack(
        children: [
          //background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/loginpage/backgroundImage.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          //background color
          Container(color: BGColor),

          //Icom admin
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: 0.4,
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
          ),

          //Isi hati Login Page
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 280),
                      Text(
                        "Hey, Admin!",
                        style: TextStyle(
                          fontSize: 27,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.bold,
                          color: MainTextColor,
                          //height: 20,
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                          color: MainTextColor,
                          //height: 20,
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
                        "Admin Code",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                          color: MainTextColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        style: TextStyle(color: MainTextColor, fontSize: 12),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          hintText: "12**56",
                          hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
                          filled: true,
                          fillColor: CardFillColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: MainTextColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 13),
                      //password
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
                        obscureText: _isVisible,
                        style: TextStyle(color: MainTextColor, fontSize: 12),

                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          hintText: "min. 8 characters",
                          hintStyle: TextStyle(color: HintTextColor, fontSize: 12),
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
                            borderSide: BorderSide(
                              color: MainTextColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/loginpage/backArrow.png"),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Alexandria",
                      fontWeight: FontWeight.w300,
                      color: MainTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      )
    );
  }
}