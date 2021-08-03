import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Controller/UserCommand.dart';
import 'package:civilsafety_quiz/View/widget/CurvePointer.dart';
import 'package:civilsafety_quiz/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  Function callback;

  LoginScreen(this.callback);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscured = true;
  bool isLogging = false; //for enabling and disabling obscurity in password field

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(String email, String password, double ratio) async {
    print('[LoginScreen] login');

    if (email == '') {
      Fluttertoast.showToast(
          msg: "Please enter your email.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0 * ratio);
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
          fontSize: 16.0 * ratio);
      return;
    }

    setState(() {
      isLogging = true;
    });

    Map loginResponse = await UserCommand().login(email, password);

    print('[LoginScreen] $loginResponse');


    if (loginResponse['success'] == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String prevUserToken = prefs.getString('userToken') ?? '';

      if (prevUserToken != loginResponse['userToken']) {
        await prefs.setBool('isChangeUser', true);
      } else {
        await prefs.setBool('isChangeUser', false);
      }

      await prefs.setString('userToken', loginResponse['userToken']);

      await QuizCommand().downloadQuizList(loginResponse['userToken']);
      await QuizCommand().removeQuizList(loginResponse['userToken']);
      await QuizCommand().sendAllSavedResult(loginResponse['userToken']);

      global.isFirst = false;

      this.widget.callback(true, true);
    } else {
      Fluttertoast.showToast(
          msg: loginResponse['message'],
          // msg: "Please enter email and password correctly.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0 * ratio);
    }

    setState(() {
      isLogging = false;
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    final lightColor = Colors.grey;
    final primaryColor = Colors.white;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    double ratio;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      ratio = width / 360;
    } else {
      ratio = height / 640;
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
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
                                  fontSize: 24 * ratio,
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
              margin: EdgeInsets.symmetric(horizontal: 20 * ratio),
              height: height * 0.4,
              child: Column(
                children: <Widget>[
                  TextField(
                      controller: emailController,
                      cursorColor: color,
                      style: TextStyle(fontSize: 18 * ratio),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.email_outlined, color: lightColor[400]),
                        labelText: 'EMAIL',
                        labelStyle: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * ratio),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(height: 30 * ratio),
                  TextField(
                      controller: passwordController,
                      cursorColor: color,
                      style: TextStyle(fontSize: 18 * ratio),
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock_open, color: lightColor[400]),
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
                          fontSize: 14 * ratio,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(height: 15 * ratio),
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
                    height: 20 * ratio,
                  ),
                  Container(
                    height: 55 * ratio,
                    width: width,
                    child: TextButton(
                      // color: Colors.blueGrey,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey),
                      ),
                      onPressed: () {
                        if (!isLogging)
                          login(emailController.text, passwordController.text, ratio);
                      },
                      child: isLogging
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text('CONTINUE',
                              style:
                                  TextStyle(color: primaryColor, fontSize: 18 * ratio)),
                      // shape: RoundedRectangleBorder(
                      // borderRadius: BorderRadius.circular(30))
                    ),
                  )
                ],
              ),
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 20 * ratio),
            //   height: height * 0.1,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Divider(
            //         color: lightColor,
            //       ),
            //       SizedBox(
            //         height: 10 * ratio,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: <Widget>[
            //           Text("DON'T HAVE AN ACCOUNT?",
            //               style:
            //                   TextStyle(color: lightColor[400], fontSize: 13 * ratio)),
            //           SizedBox(
            //             width: 5 * ratio,
            //           ),
            //           InkWell(
            //               onTap: () {
            //                 this.widget.callback(false, false);
            //               },
            //               child: Text('CREATE',
            //                   style: TextStyle(
            //                       color: Colors.deepOrangeAccent[200],
            //                       fontSize: 14 * ratio,
            //                       fontWeight: FontWeight.bold)))
            //         ],
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
