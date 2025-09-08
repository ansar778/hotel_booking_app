import 'package:bookingapp/hotelowner/hotel_detail.dart';
import 'package:bookingapp/pages/bottomnav.dart';
import 'package:bookingapp/pages/login.dart';
import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/shared_pref.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  final String redirect;
  SignUp({required this.redirect});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool user = false, owner = false;
  String email = "", password = "", name = "";
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  registration() async {
    if (namecontroller.text != "" && mailcontroller.text != "") {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String id = randomAlphaNumeric(10);
        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "Id": id,
          "Role": widget.redirect == "Owner" ? "Owner" : "User",
          "Wallet": "0",
        };
        await SharedpreferenceHelper().saveUserName(namecontroller.text);
        await SharedpreferenceHelper().saveUserEmail(mailcontroller.text);
        await SharedpreferenceHelper().saveUserId(id);
        await DatabaseMethods().addUserInfo(userInfoMap, id);
        await SharedpreferenceHelper().saveUserWallet("0");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully!",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        );
        widget.redirect == "Owner"
            ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HotelDetail()),
            )
            : Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Bottomnav(redirect: widget.redirect),
              ),
            );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "images/signup.png",
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 5.0),
            Center(
              child: Text("Sign Up", style: AppWidget.headlinetextstyle(25.0)),
            ),
            SizedBox(height: 5.0),
            Center(
              child: Text(
                "Please enter the details to continue.",
                style: AppWidget.normaltextstyle(17.0),
              ),
            ),
            SizedBox(height: 20.0),

            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text("Name", style: AppWidget.normaltextstyle(20.0)),
            ),
            SizedBox(height: 10.0),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: namecontroller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: const Color.fromARGB(255, 4, 104, 186),
                  ),
                  hintText: "Enter Name",
                  hintStyle: AppWidget.normaltextstyle(18.0),
                ),
              ),
            ),
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
            SizedBox(height: 15.0),
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
            SizedBox(height: 30.0),
            GestureDetector(
              onTap: () {
                if (namecontroller.text != "" &&
                    mailcontroller.text != "" &&
                    passwordcontroller.text != "") {
                  setState(() {
                    email = mailcontroller.text;
                    password = passwordcontroller.text;
                  });
                }
                registration();
              },
              child: Center(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 104, 200, 107),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Center(
                    child: Text(
                      "Sign Up",
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
                  "Already have an account? ",
                  style: AppWidget.normaltextstyle(18.0),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogIn(redirect: widget.redirect),
                      ),
                    );
                  },
                  child: Text(
                    "LogIn",
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
