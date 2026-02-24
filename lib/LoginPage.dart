import 'package:flutter/material.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // This widget is the root of your application.
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

          //Isi hati Login Page
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 200),
                      Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 27,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.bold,
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
                        style: TextStyle(color: MainTextColor),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          hintText: "Your Username",
                          hintStyle: TextStyle(color: HintTextColor),
                          filled: true,
                          fillColor: CardFillColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: MainTextColor,
                              width: 1
                            )
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: MainTextColor,
                              width: 1
                            )
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
                      //login button
                      SizedBox(height: 35,),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            print('wowowo');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ButtonFillColor,
                            side: BorderSide(color: CardStrokeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Alexandria",
                              fontWeight: FontWeight.w500,
                              color: BlackTextColor,
                            ),
                          ),
                        ),
                      ),
                      //having trouble
                      SizedBox(height: 5,),
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
                            SizedBox(width: 3,),
                            Text(
                              "Click Here",
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: "Alexandria",
                                fontWeight: FontWeight.w500,
                                color: MainTextColor,
                              ),
                            )
                          ],
                        ),                        
                      ),
                      
                      //divider
                      SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Divider(
                          color: CardStrokeColor,
                          thickness: 1,
                        ),
                      ),

                      //have not regis
                      SizedBox(height: 31,),
                      Center(
                        child: Text(
                          "Have not registered yet?",
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: "Alexandria",
                            fontWeight: FontWeight.w300,
                            color: MainTextColor,
                          ),
                        ),
                      ),
                      
                      //sign up butong
                      SizedBox(height: 5,),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            print('ter sign up up up up');
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
          )
        ],
      ),
    );
  }
}

//todo
//1. interact with admin butong + onpres admin butong
//2. interact clickhere
//3. masukin mata + onpres mata
//4. password hide
//5. onpres login
//6. onpres signup
