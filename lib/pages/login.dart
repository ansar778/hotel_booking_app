import 'package:bookingapp/hotelowner/owner_home.dart';
import 'package:bookingapp/pages/bottomnav.dart';
import 'package:bookingapp/pages/signup.dart';
import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/shared_pref.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  final String redirect;
  LogIn({required this.redirect});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "", role = "", name = "", id = "", wallet = "";
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      QuerySnapshot querySnapshot = await DatabaseMethods().getUserbyemail(
        email,
      );
      name = "${querySnapshot.docs[0]["Name"]}";
      id = "${querySnapshot.docs[0]["Id"]}";
      role = "${querySnapshot.docs[0]["Role"]}";
      wallet = "${querySnapshot.docs[0]["Wallet"]}";

      await SharedpreferenceHelper().saveUserName(name);
      await SharedpreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedpreferenceHelper().saveUserId(id);
      await SharedpreferenceHelper().saveUserWallet(wallet);

      role == "Owner"
          ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OwnerHome()),
          )
          : Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Bottomnav(redirect: widget.redirect),
            ),
          );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No user Found for that Email",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("images/login.png"),
            SizedBox(height: 5.0),
            Center(
              child: Text("LogIn", style: AppWidget.headlinetextstyle(25.0)),
            ),
            SizedBox(height: 5.0),
            Center(
              child: Text(
                "Please enter the details to continue.",
                style: AppWidget.normaltextstyle(17.0),
              ),
            ),
            SizedBox(height: 20.0),

            SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text("Email", style: AppWidget.normaltextstyle(20.0)),
            ),
            SizedBox(height: 10.0),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: mailcontroller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.mail,
                    color: const Color.fromARGB(255, 4, 104, 186),
                  ),
                  hintText: "Enter Email",
                  hintStyle: AppWidget.normaltextstyle(18.0),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text("Password", style: AppWidget.normaltextstyle(20.0)),
            ),
            SizedBox(height: 10.0),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                obscureText: true,
                controller: passwordcontroller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.password,
                    color: const Color.fromARGB(255, 4, 104, 186),
                  ),
                  hintText: "Enter Password",
                  hintStyle: AppWidget.normaltextstyle(18.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password ?",
                    style: AppWidget.normaltextstyle(18.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            GestureDetector(
              onTap: () {
                if (mailcontroller.text != "" &&
                    passwordcontroller.text != "") {
                  setState(() {
                    email = mailcontroller.text;
                    password = passwordcontroller.text;
                  });
                  userLogin();
                }
              },
              child: Center(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 11, 131, 230),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Center(
                    child: Text(
                      "LogIn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account ",
                  style: AppWidget.normaltextstyle(18.0),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUp(redirect: widget.redirect),
                      ),
                    );
                  },
                  child: Text(
                    "SignUp",
                    style: AppWidget.headlinetextstyle(20.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
