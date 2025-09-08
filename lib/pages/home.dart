import 'package:bookingapp/pages/city_hotel.dart';
import 'package:bookingapp/pages/detail_page.dart';
import 'package:bookingapp/services/database.dart';
import 'package:bookingapp/services/shared_pref.dart';
import 'package:bookingapp/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? hotelStream;
  String? address, name;

  Future<void> getontheload() async {
    name = await SharedpreferenceHelper().getUserName();
    hotelStream = await DatabaseMethods().getallHotels();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeData();

    _getLocationAndAddress();
  }

  Future<void> _initializeData() async {
    try {
      print('1. Starting initialization...');
      // 1. Get user name
      name = await SharedpreferenceHelper().getUserName();
      print('2. UserName loaded: $name');
      print('UserName loaded: $name');

      // 2. Load hotel stream (DON'T use await if it returns a Stream)
      // Assuming getallHotels() returns a Stream<QuerySnapshot>
      hotelStream = await DatabaseMethods().getallHotels();
      print('Hotel stream initialized');

      // 3. Get city counts
      await getCityCounts();
      print('4. City counts loaded');

      // 4. Get location and address
      _getLocationAndAddress();
      print('5. Location and address loaded');

      // 5. Update UI after everything is loaded
      setState(() {});
      print('6. UI updated successfully!');
    } catch (e, stackTrace) {
      // This will catch any errors and print them, so you know what's wrong
      print('Error in initialization: $e');
      print('Stack trace: $stackTrace');
      // You might want to show an error message to the user here
    }
  }

  bool search = false;

  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchcontroller = TextEditingController();

  void initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });

    var CapitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['UpdatedName'].startsWith(CapitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
    }
  }

  int? mumbaicount, newyorkcount, balicount, dubaicount;

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      return '${place.locality}, ${place.country}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _getLocationAndAddress() async {
    print('Getting location...');
    try {
      Position position = await _getCurrentPosition();
      address = await _getAddressFromLatLng(position);
      print('Address: $address');
    } catch (e) {
      print('Error getting location: $e');

      // Set a default address instead of leaving it null
      address = "New York, USA"; // Or any default city you prefer
      print('Using default address: $address');
    } finally {
      setState(() {});
    }

    print('Address: $address');
  }

  Future<void> getCityCounts() async {
    print('Getting city counts...');
    final firestore = FirebaseFirestore.instance;

    // Count documents where city == 'mumbai'
    final mumbaiQuerySnapshot =
        await firestore
            .collection('Hotel')
            .where('HotelCity', isEqualTo: 'mumbai')
            .get();

    mumbaicount = mumbaiQuerySnapshot.docs.length;

    // Count documents where city == 'New York'
    final newYorkQuerySnapshot =
        await firestore
            .collection('Hotel')
            .where('HotelCity', isEqualTo: 'newyork')
            .get();
    newyorkcount = newYorkQuerySnapshot.docs.length;

    final BaliQuerySnapshot =
        await firestore
            .collection('Hotel')
            .where('HotelCity', isEqualTo: 'bali')
            .get();
    balicount = BaliQuerySnapshot.docs.length;

    final DubaiQuerySnapshot =
        await firestore
            .collection('Hotel')
            .where('HotelCity', isEqualTo: 'dubai')
            .get();
    dubaicount = DubaiQuerySnapshot.docs.length;

    print('Number of hotels in bangladesh: $mumbaicount');
    print('Number of hotels in New York: $newyorkcount');
    print('Number of hotels in New York: $balicount');
    print('City counts loaded');
    setState(() {});
  }

  Widget allHotels() {
    return StreamBuilder(
      stream: hotelStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              scrollDirection: Axis.horizontal,
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
                    margin: EdgeInsets.only(left: 20.0, bottom: 5.0),
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
                              child: Image.asset(
                                "images/hotel1.jpg",
                                width: MediaQuery.of(context).size.width / 1.2,
                                fit: BoxFit.cover,
                                height: 230,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Text(
                                    ds["HotelName"],
                                    style: AppWidget.headlinetextstyle(22.0),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                  ),
                                  Text(
                                    "\$" + ds["HotelCharges"],
                                    style: AppWidget.headlinetextstyle(25.0),
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
      backgroundColor: const Color.fromARGB(255, 244, 241, 241),
      body:
          address == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            child: Image.asset(
                              "images/home.jpg",
                              width: MediaQuery.of(context).size.width,
                              height: 280,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 50.0, left: 20.0),
                            width: MediaQuery.of(context).size.width,
                            height: 280,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(97, 0, 0, 0),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      address!,
                                      style: AppWidget.whitetextstyle(20.0),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30.0),
                                Text(
                                  "GhureAshi",
                                  style: AppWidget.whitetextstyle(24.0),
                                ),
                                SizedBox(height: 20.0),
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5.0,
                                    top: 5.0,
                                  ),
                                  margin: EdgeInsets.only(right: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      103,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: TextField(
                                    controller: searchcontroller,
                                    onChanged: (value) {
                                      initiateSearch(value.toUpperCase());
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon:
                                          search
                                              ? GestureDetector(
                                                onTap: () {
                                                  searchcontroller.text = "";
                                                  search = false;
                                                  setState(() {});
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              )
                                              : Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ),
                                      hintText: "Search Hotels..",
                                      hintStyle: AppWidget.whitetextstyle(20.0),
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      search
                          ? ListView(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            primary: false,
                            shrinkWrap: true,
                            children:
                                tempSearchStore.map((element) {
                                  return buildResultCard(element);
                                }).toList(),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "The most relevant",
                                  style: AppWidget.headlinetextstyle(22.0),
                                ),
                              ),

                              SizedBox(height: 20.0),
                              SizedBox(height: 330, child: allHotels()),
                              SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Discover new places",
                                  style: AppWidget.headlinetextstyle(22.0),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                height: 280,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    CityHotel(city: "Mumbai"),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 5.0),
                                        child: Material(
                                          elevation: 2.0,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.asset(
                                                    "images/mumbai.jpg",
                                                    height: 200,
                                                    width: 180,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(height: 10.0),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20.0,
                                                      ),
                                                  child: Text(
                                                    "Mumbai",
                                                    style:
                                                        AppWidget.headlinetextstyle(
                                                          20.0,
                                                        ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.hotel,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      Text(
                                                        "$mumbaicount Hotels",
                                                        style:
                                                            AppWidget.normaltextstyle(
                                                              18.0,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    CityHotel(city: "NewYork"),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 20.0,
                                          bottom: 5.0,
                                        ),
                                        child: Material(
                                          elevation: 2.0,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.asset(
                                                    "images/newyork.jpg",
                                                    height: 200,
                                                    width: 180,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(height: 10.0),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20.0,
                                                      ),
                                                  child: Text(
                                                    "NewYork",
                                                    style:
                                                        AppWidget.headlinetextstyle(
                                                          20.0,
                                                        ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.hotel,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      Text(
                                                        "$newyorkcount Hotels",
                                                        style:
                                                            AppWidget.normaltextstyle(
                                                              18.0,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 20.0,
                                        bottom: 5.0,
                                      ),
                                      child: Material(
                                        elevation: 2.0,
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  "images/bali.jpg",
                                                  height: 200,
                                                  width: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                ),
                                                child: Text(
                                                  "Bali",
                                                  style:
                                                      AppWidget.headlinetextstyle(
                                                        20.0,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.hotel,
                                                      color: Colors.blue,
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      "$balicount Hotels",
                                                      style:
                                                          AppWidget.normaltextstyle(
                                                            18.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 20.0,
                                        bottom: 5.0,
                                      ),
                                      child: Material(
                                        elevation: 2.0,
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  "images/dubai.jpg",
                                                  height: 200,
                                                  width: 180,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                ),
                                                child: Text(
                                                  "Dubai",
                                                  style:
                                                      AppWidget.headlinetextstyle(
                                                        20.0,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.hotel,
                                                      color: Colors.blue,
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      "$dubaicount Hotels",
                                                      style:
                                                          AppWidget.normaltextstyle(
                                                            18.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 50.0),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.only(left: 20.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 100,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "images/hotel1.jpg",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["HotelName"],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      "\$" + data["HotelCharges"],
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DetailPage(
                              bathroom: data["Bathroom"],
                              desc: data["HotelDesc"],
                              hdtv: data["HDTV"],
                              kitchen: data["Kitchen"],
                              name: data["HotelName"],
                              price: data["HotelCharges"],
                              wifi: data["WiFi"],
                              hotelid: data["Id"],
                            ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20.0),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xff0000ff),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
