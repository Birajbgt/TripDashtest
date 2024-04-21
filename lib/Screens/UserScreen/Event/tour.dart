// import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tripdash/Repositeries/hotel_repositories.dart';
import 'package:tripdash/Screens/HotelViewScreen/hotel_theme.dart';
import 'package:tripdash/model/hotel_model.dart';

class CostumizedTour extends StatefulWidget {
  const CostumizedTour({Key? key}) : super(key: key);
  static String routeName = '/CostumizedTour';

  @override
  State<CostumizedTour> createState() => _CostumizedTourState();
}

class _CostumizedTourState extends State<CostumizedTour>
    with TickerProviderStateMixin {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    // Initialize flutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Configure the notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 5));

  AnimationController? animationController;
  List<QueryDocumentSnapshot<HotelModel>> hotelFirebase = [];
  List<QueryDocumentSnapshot<HotelModel>> filteredHotels = [];

  // Form fields and state variables
  final String _selectedDestination = '';
  DateTime _selectedDate = DateTime.now();
  int _numberOfDays = 1;
  String _additionalPreferences = '';
  String email = '';
  String _Contact = '';
  String _selectedVehicle = "Stick"; // Default vehicle selection

  final Map<String, String> vehicleImages = {
    // D:\Tripdashtest\TripDash\Assets\Images\Hotel.png
    'Stick': 'Assets/images/stick.png', // Replace with your image asset path
    'Bag': 'Assets/images/bag.png', // Replace with your image asset path
    // 'Bus': 'Assets/images/boudha.jpg', // Replace with your image asset path
  };

  // Function to handle form submission
  void _submitForm() {
    // Handle form submission here
    // For example, you can print the form data
    print('Destination: $_selectedDestination');
    print('Date: $_selectedDate');
    print('Number of days: $_numberOfDays');
    print('Number of days: $_Contact');
    print('Additional Preferences: $_additionalPreferences');
    print('Additional Preferences: $email');
    // Show sweet alert
    _showSuccessAlert(context);
    // Show notification
    _showNotification();
  }

  Future<void> getData() async {
    final response = await HotelRepository().getDataNormal();
    setState(() {
      hotelFirebase = response;
      filteredHotels = response;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getData();
  //   animationController = AnimationController(
  //       duration: const Duration(milliseconds: 1000), vsync: this);
  // }

  @override
  void dispose() {
    super.dispose();
    animationController?.dispose();
  }

  void searchHotels(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredHotels = hotelFirebase
            .where((hotel) => hotel
                .data()
                .hotelName!
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      } else {
        filteredHotels = hotelFirebase;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        getAppBarUI(),
        Expanded(
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Column(
                        children: <Widget>[
                          getSearchBarUI(),
                        ],
                      );
                    }, childCount: 1),
                  ),
                  // SliverPersistentHeader(
                  //   floating: true,
                  //   pinned: true,
                  //   delegate: ContestTabHeader(getFilterBarUI()),
                  // ),
                ];
              },
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      ListTile(
                        title: const Text('Select Date'),
                        subtitle: Text(
                          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicle,
                        items: vehicleImages.keys.map((String vehicle) {
                          return DropdownMenuItem<String>(
                            value: vehicle,
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  vehicleImages[vehicle]!,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(vehicle),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedVehicle = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Number of Days',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _numberOfDays = int.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Contacts',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _Contact = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Additional Preferences',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _additionalPreferences = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ],
    ));
  }

  getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8, left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HotelTheme.buildLightTheme().colorScheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(38.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 4, bottom: 4),
                  child: TextField(
                    onChanged: (query) => searchHotels(query),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    cursorColor: HotelTheme.buildLightTheme().primaryColor,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Packaage",
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: HotelTheme.buildLightTheme().primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(38.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.search,
                    size: 26,
                    color: HotelTheme.buildLightTheme().colorScheme.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: HotelTheme.buildLightTheme().colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 8,
          right: 8,
        ),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Gear Rent",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32.0)),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.favorite_border),
                      ),
                    ),
                  ),
                  // Material(
                  //   color: Colors.transparent,
                  //   child: InkWell(
                  //     borderRadius:
                  //         const BorderRadius.all(Radius.circular(32.0)),
                  //     onTap: () {},
                  //     child: const Padding(
                  //       padding: EdgeInsets.all(8.0),
                  //       child: Icon(Icons.location_on_rounded),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      // 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Package Booked',
      'Your package is booked successfully!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

void _showSuccessAlert(BuildContext context) {
  Alert(
    context: context,
    type: AlertType.success,
    title: "Success",
    desc: "Your package is booked successfully!",
    buttons: [
      DialogButton(
        onPressed: () => Navigator.pop(context),
        width: 120,
        child: const Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

class ContestTabHeader extends SliverPersistentHeaderDelegate {
  final Widget searchUI;

  ContestTabHeader(this.searchUI);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return searchUI;
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
