import 'package:civilsafety_quiz/Controller/LoginCommand.dart';
import 'package:civilsafety_quiz/View/widget/CurvePointer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  Function callback;

  LoginScreen(this.callback);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscured =
      true; //for enabling and disabling obscurity in password field

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(String email, String password) async {
    print('[LoginScreen] login');

    if (email == '') {
      Fluttertoast.showToast(
          msg: "Please enter your email.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (password == '') {
      Fluttertoast.showToast(
          msg: "Please enter your password.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    String userToken = await LoginCommand().run(email, password);

    print('[LoginScreen] $userToken');

    if (userToken != '') {
      this.widget.callback(true, true);
    } else {
      Fluttertoast.showToast(
          msg: "Please enter email and password correctly.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    return;
  }

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
              height: height * 0.25,
              width: width,
              child: Stack(
                children: <Widget>[
                  CustomPaint(painter: CurvePainter(height * 0.25, width)),
                  Padding(
                    padding:
                        EdgeInsets.only(top: height * 0.1, left: width * 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('SIGN IN',
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
              height: height * 0.2,
              width: width,
              child: Image(
                image: AssetImage('assets/images/login_logo.png'),
                fit: BoxFit.fitWidth,
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: height * 0.4,
            child: Column(
              children: <Widget>[
                TextField(
                    controller: emailController,
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
                SizedBox(height: 30),
                TextField(
                    controller: passwordController,
                    cursorColor: color,
                    style: TextStyle(fontSize: 18),
                    obscureText: isObscured,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_open, color: lightColor[400]),
                      suffixIcon: IconButton(
                          icon: isObscured
                              ? Icon(Icons.visibility_off, color: lightColor)
                              : Icon(Icons.visibility, color: lightColor),
                          onPressed: () {
                            setState(() {
                              isObscured = !isObscured;
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
                SizedBox(height: 15),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //     InkWell(
                //         onTap: () {},
                //         child: Text('FORGOT PASSWORD?',
                //             style: TextStyle(
                //                 color: lightColor[400], fontSize: 12)))
                //   ],
                // ),
                SizedBox(
                  height: 20,
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
                      login(emailController.text, passwordController.text);
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: height * 0.1,
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
                    Text("DON'T HAVE AN ACCOUNT?",
                        style: TextStyle(color: lightColor[400], fontSize: 13)),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          this.widget.callback(false, false);
                        },
                        child: Text('CREATE',
                            style: TextStyle(
                                color: Colors.deepOrangeAccent[200],
                                fontSize: 14,
                                fontWeight: FontWeight.bold)))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
