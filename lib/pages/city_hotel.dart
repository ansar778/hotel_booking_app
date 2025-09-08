import 'package:bookingapp/pages/detail_page.dart';
import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityHotel extends StatefulWidget {
  final String city;
  const CityHotel({super.key, required this.city});

  @override
  State<CityHotel> createState() => _CityHotelState();
}

class _CityHotelState extends State<CityHotel> {
  Stream? cityStream;

  Future<void> getontheload() async {
    cityStream = await DatabaseMethods().getUserCityHotel(widget.city);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allHotels() {
    return StreamBuilder(
      stream: cityStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DetailPage(
                              bathroom: ds["Bathroom"],
                              desc: ds["HotelDesc"],
                              hdtv: ds["HDTV"],
                              kitchen: ds["Kitchen"],
                              name: ds["HotelName"],
                              price: ds["HotelCharges"],
                              wifi: ds["WiFi"],
                              hotelid: ds.id,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20.0, bottom: 20.0),
                    child: Material(
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                ds["Image"],
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                height: 230,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 230,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Icon(Icons.hotel, color: Colors.grey[700], size: 50),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 230,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ds["HotelName"],
                                    style: AppWidget.headlinetextstyle(22.0),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      "\$" + ds["HotelCharges"],
                                      style: AppWidget.headlinetextstyle(25.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    ds["HotelAddress"],
                                    style: AppWidget.normaltextstyle(18.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city, style: AppWidget.headlinetextstyle(28.0)),
      ),
      body: Container(margin: EdgeInsets.only(right: 20.0), child: allHotels()),
    );
  }
}
