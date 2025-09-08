import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/shared_pref.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
    String? id, name;

  Future<void> getonthesharedpref() async {
    id = await SharedpreferenceHelper().getUserId();
    name= await SharedpreferenceHelper().getUserName();
    bookingStream= await DatabaseMethods().getAdminbookings(id!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getonthesharedpref();
  }

  Stream? bookingStream;

 Widget allAdminBookings() {
    return StreamBuilder(
      stream: bookingStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                final format = DateFormat('dd, MMM yyyy');
                final date = format.parse(ds["CheckIn"]);
                final now = DateTime.now();
               
                return  date.isAfter(now) ? Container(
                     margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Material(
                      elevation: 3.0,
                       borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color.fromARGB(17, 0, 0, 0), borderRadius: BorderRadius.circular(10)),
                       
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                "images/boy.jpg",
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.blue),
                                    SizedBox(width: 10.0,),
                                    Text(
                                     ds["Username"],
                                      style: AppWidget.normaltextstyle(20.0),
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
                  ): Container();
              },
            )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name==null? Center(child: CircularProgressIndicator()): Container(
        child: Stack(
          children: [
            Container(
              child: Image.asset(
                "images/home.jpg",
                width: MediaQuery.of(context).size.width,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 280,
              decoration: BoxDecoration(
                color: const Color.fromARGB(83, 0, 0, 0),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40.0, left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "images/wave.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        "Hello, ${name!}",
                        style: AppWidget.boldwhitetextstyle(22.0),
                      ),
                    ],
                  ),
                  Text(
                    "ready to welcome\nyour next guest?",
                    style: AppWidget.whitetextstyle(24.0),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 4.5,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/1.4,
                    child: allAdminBookings()),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
