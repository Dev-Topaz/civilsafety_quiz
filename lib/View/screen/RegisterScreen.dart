import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Controller/UserCommand.dart';
import 'package:civilsafety_quiz/View/widget/CurvePointer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isLogging = false;

  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> register(userName, email, password, confirmPassword) async {
    if (userName == '') {
      Fluttertoast.showToast(
          msg: "Please enter your username.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

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
          msg: "Please enter password.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (confirmPassword == '') {
      Fluttertoast.showToast(
          msg: "Please enter confirm password.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (password != confirmPassword) {
      passwordController.text = '';
      confirmPasswordController.text = '';

      Fluttertoast.showToast(
          msg: "Password does not match. Please enter password again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    setState(() {
      isLogging = true;
    });

    String userToken = await UserCommand()
        .register(userName, email, password, confirmPassword);

    print('[RegisterScreen] $userToken');

    if (userToken != '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userToken', userToken);

      await QuizCommand().downloadQuizList(userToken);
      await QuizCommand().removeQuizList(userToken);
      await QuizCommand().sendAllSavedResult(userToken);

      this.widget.callback(true, true);
    } else {
      Fluttertoast.showToast(
          msg: "This email has already registered. Please log in.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
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
                height: height * 0.2,
                width: width,
                child: Stack(
                  children: <Widget>[
                    CustomPaint(painter: CurvePainter(height * 0.2, width)),
                    Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.075, left: width * 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('SIGN UP',
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
                height: height * 0.15,
                width: width,
                child: Image(
                  image: AssetImage('assets/images/login_logo.png'),
                  fit: BoxFit.fitWidth,
                )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20 * ratio),
              child: Column(
                children: <Widget>[
                  TextField(
                      controller: userNameController,
                      cursorColor: color,
                      style: TextStyle(fontSize: 18 * ratio),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.person_outline, color: lightColor[400]),
                        labelText: 'USERNAME',
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
                  SizedBox(height: 10 * ratio),
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
                  SizedBox(height: 10 * ratio),
                  TextField(
                      controller: passwordController,
                      cursorColor: color,
                      style: TextStyle(fontSize: 18 * ratio),
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
                          fontSize: 14 * ratio,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(
                    height: 10 * ratio,
                  ),
                  TextField(
                      controller: confirmPasswordController,
                      cursorColor: color,
                      style: TextStyle(fontSize: 18 * ratio),
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
                          fontSize: 14 * ratio,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: lightColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.amberAccent)),
                      )),
                  SizedBox(
                    height: 10 * ratio,
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
                          register(
                              userNameController.text,
                              emailController.text,
                              passwordController.text,
                              confirmPasswordController.text);
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20 * ratio),
              height: height * 0.12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Divider(
                    color: lightColor,
                  ),
                  SizedBox(
                    height: 10 * ratio,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("ALREADY HAVE YOUR ACCOUNT?",
                          style:
                              TextStyle(color: lightColor[400], fontSize: 13 * ratio)),
                      SizedBox(
                        width: 5 * ratio,
                      ),
                      InkWell(
                          onTap: () {
                            this.widget.callback(true, false);
                          },
                          child: Text('SIGN IN',
                              style: TextStyle(
                                  color: Colors.deepOrangeAccent[200],
                                  fontSize: 14 * ratio,
                                  fontWeight: FontWeight.bold)))
                    ],
                  ),
                  SizedBox(
                    height: 30 * ratio,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
