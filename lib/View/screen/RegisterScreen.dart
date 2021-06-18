import 'package:civilsafety_quiz/View/widget/CurvePointer.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  Function callback;

  RegisterScreen(this.callback);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isPasswordObscured =
      true; //for enabling and disabling obscurity in password field
  bool isConfirmPasswordObscured =
      true; //for enabling and disabling obscurity in password field

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    final lightColor = Colors.grey;
    final primaryColor = Colors.white;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Material(
      color: primaryColor,
      child: Column(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                    Colors.amberAccent,
                    Colors.deepOrangeAccent,
                  ])),
              height: height * 0.2,
              width: width,
              child: Stack(
                children: <Widget>[
                  CustomPaint(painter: CurvePainter(height * 0.2, width)),
                  Padding(
                    padding:
                        EdgeInsets.only(top: height * 0.075, left: width * 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('SIGN UP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ],
              )),
          Container(
              height: height * 0.15,
              width: width,
              child: Image(
                image: AssetImage('assets/images/login_logo.png'),
                fit: BoxFit.fitWidth,
              )),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  TextField(
                      cursorColor: color,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.person_outline, color: lightColor[400]),
                        labelText: 'USERNAME',
                        labelStyle: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(height: 10),
                  TextField(
                      cursorColor: color,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.email_outlined, color: lightColor[400]),
                        labelText: 'EMAIL',
                        labelStyle: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(height: 10),
                  TextField(
                      cursorColor: color,
                      style: TextStyle(fontSize: 18),
                      obscureText: isPasswordObscured,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock_open, color: lightColor[400]),
                        suffixIcon: IconButton(
                            icon: isPasswordObscured
                                ? Icon(Icons.visibility_off, color: lightColor)
                                : Icon(Icons.visibility, color: lightColor),
                            onPressed: () {
                              setState(() {
                                isPasswordObscured = !isPasswordObscured;
                              });
                            }),
                        labelText: 'PASSWORD',
                        labelStyle: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      cursorColor: color,
                      style: TextStyle(fontSize: 18),
                      obscureText: isConfirmPasswordObscured,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock_open, color: lightColor[400]),
                        suffixIcon: IconButton(
                            icon: isConfirmPasswordObscured
                                ? Icon(Icons.visibility_off, color: lightColor)
                                : Icon(Icons.visibility, color: lightColor),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordObscured =
                                    !isConfirmPasswordObscured;
                              });
                            }),
                        labelText: 'CONFIRM PASSWORD',
                        labelStyle: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    width: width,
                    child: TextButton(
                      // color: Colors.blueGrey,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey),
                      ),
                      onPressed: () {
                        this.widget.callback(true, true);
                      },
                      child: Text('CONTINUE',
                          style: TextStyle(color: primaryColor, fontSize: 18)),
                      // shape: RoundedRectangleBorder(
                      // borderRadius: BorderRadius.circular(30))
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: height * 0.12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(
                  color: lightColor,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("ALREADY HAVE YOUR ACCOUNT?",
                        style: TextStyle(color: lightColor[400], fontSize: 13)),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          this.widget.callback(true, false);
                        },
                        child: Text('SIGN IN',
                            style: TextStyle(
                                color: Colors.deepOrangeAccent[200],
                                fontSize: 14,
                                fontWeight: FontWeight.bold)))
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
