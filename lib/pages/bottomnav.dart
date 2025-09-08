import 'package:bookingapp/pages/booking.dart';
import 'package:bookingapp/pages/home.dart';
import 'package:bookingapp/pages/profile.dart';
import 'package:bookingapp/pages/wallet.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Bottomnav extends StatefulWidget {
  final dynamic redirect; // You can change 'dynamic' to the appropriate type

  const Bottomnav({super.key, required this.redirect});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget> pages;

  late Home HomePage;
  late Booking booking;
  late Profile profile;
  late Wallet wallet;

  int currentTabIndex = 0;

  @override
  void initState() {
    HomePage = Home();
    booking = Booking();
    profile = Profile();
    wallet = Wallet();

    pages = [HomePage, booking, wallet, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
          Icon(Icons.home, color: Colors.white, size: 30.0),
          Icon(Icons.shopping_bag, color: Colors.white, size: 30.0),
          Icon(Icons.wallet, color: Colors.white, size: 30.0),
          Icon(Icons.person, color: Colors.white, size: 30.0),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
