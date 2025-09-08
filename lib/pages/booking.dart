import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/shared_pref.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? id;

  Stream? bookingStream;

  Future<void> getontheload() async {
    id = await SharedpreferenceHelper().getUserId();
    bookingStream = await DatabaseMethods().getUserbookings(id!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allUserBookings() {
    return StreamBuilder(
      stream: bookingStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                final format = DateFormat('dd, MMM yyyy');
                final date = format.parse(ds["CheckIn"]);
                final now = DateTime.now();
               
                return  date.isBefore(now) && past ?Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Material(
                    elevation: 1.5,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "images/hotel1.jpg",
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.hotel,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    ds["HotelName"],
                                    style: AppWidget.normaltextstyle(19.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 3,
                                    child: Text(
                                      ds["CheckIn"] + " to " + ds["CheckOut"],
                                      style: AppWidget.normaltextstyle(16.0),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.group,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    ds["Guests"],
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                  SizedBox(width: 10.0),
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "\$" + ds["Total"],
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ): date.isAfter(now) && incoming? Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Material(
                    elevation: 1.5,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "images/hotel1.jpg",
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.hotel,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    ds["HotelName"],
                                    style: AppWidget.normaltextstyle(19.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 3,
                                    child: Text(
                                      ds["CheckIn"] + " to " + ds["CheckOut"],
                                      style: AppWidget.normaltextstyle(16.0),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.group,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    ds["Guests"],
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                  SizedBox(width: 10.0),
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "\$" + ds["Total"],
                                    style: AppWidget.headlinetextstyle(20.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ):Container();
              },
            )
            : Container();
      },
    );
  }

  bool incoming = true, past = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("BOOKING", style: AppWidget.headlinetextstyle(30.0)),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                incoming
                    ? Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 180,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "images/incoming.png",
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Incoming\nBookings",
                              textAlign: TextAlign.center,
                              style: AppWidget.headlinetextstyle(24.0),
                            ),
                          ],
                        ),
                      ),
                    )
                    : GestureDetector(
                      onTap: () {
                        incoming = true;
                        past = false;
                        setState(() {});
                      },
                      child: Container(
                        width: 160,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                "images/incoming.png",
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Incoming\nBookings",
                              textAlign: TextAlign.center,
                              style: AppWidget.normaltextstyle(24.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                SizedBox(width: 30.0),
                past
                    ? Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 180,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "images/past.png",
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Past\nBookings",
                              textAlign: TextAlign.center,
                              style: AppWidget.headlinetextstyle(24.0),
                            ),
                          ],
                        ),
                      ),
                    )
                    : GestureDetector(
                      onTap: () {
                        past = true;
                        incoming = false;
                        setState(() {});
                      },
                      child: Container(
                        width: 160,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                "images/past.png",
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Past\nBookings",
                              textAlign: TextAlign.center,
                              style: AppWidget.normaltextstyle(24.0),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
            SizedBox(height: 30.0),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: allUserBookings(),
            ),
          ],
        ),
      ),
    );
  }
}
