import 'package:flutter/material.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  // This widget is the root of your application.
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isVisible1 = true;
  bool _isVisible2 = true;

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
          //bg image

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/loginpage/backgroundImage.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          //bg color with opacity
          Container(color: BGColor),

          //Sign up
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [

                  SizedBox(height: 200),
                  Container(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Alexandria",
                        color: MainTextColor,
                      ),
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
                        SizedBox(height: 5,),
                        TextField(
                          style: TextStyle(color: MainTextColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            hintText: "player@genshin.import",
                            hintStyle: TextStyle(color: HintTextColor),
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
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          style: TextStyle(color: MainTextColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            hintText: "Your name",
                            hintStyle: TextStyle(color: HintTextColor),
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
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          obscureText: _isVisible1,
                          style: TextStyle(color: MainTextColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            hintText: "min. 8 characters",
                            hintStyle: TextStyle(color: HintTextColor),
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
                        SizedBox(height: 13,),
                        Text(
                          "Reconfirm Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Alexandria",
                            color: MainTextColor,
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          obscureText: _isVisible2,
                          style: TextStyle(color: MainTextColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            hintText: "min. 8 characters",
                            hintStyle: TextStyle(color: HintTextColor),
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
                        SizedBox(height: 35,),
                        SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            print('save db sign up');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ButtonFillColor,
                            side: BorderSide(color: CardStrokeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Alexandria",
                              fontWeight: FontWeight.w500,
                              color: BlackTextColor,
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
                      fontWeight: FontWeight.w200,
                      color: MainTextColor,
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

//todo
//1. match password
//2. onpres signup