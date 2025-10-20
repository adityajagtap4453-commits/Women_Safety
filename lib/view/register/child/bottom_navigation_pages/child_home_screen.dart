import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:send_message/send_message.dart';
import 'package:shake/shake.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:women_safety_app/controller/db_services.dart';
import 'package:women_safety_app/models/contact_model.dart';
import 'package:women_safety_app/utils/quotes.dart';
import 'package:women_safety_app/widgets/custom_appbar.dart';
import 'package:women_safety_app/widgets/custom_carousel.dart';
import 'package:women_safety_app/widgets/emergency.dart';
import 'package:women_safety_app/widgets/life_safe.dart';
import 'package:women_safety_app/widgets/safe_home.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  ShakeDetector? _detector;
  int qIndex = 0;
  DateTime _lastShakeTime = DateTime.now();
  Position? _currentPosition;
  String _currentAddress = '';
  List<ContactModel> contactList = [];

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    _loadContacts();
    _startShakeDetector();
  }

  void getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(sweetSayings.length);
    });
  }

  Future<void> _loadContacts() async {
    List<ContactModel> contacts = await DatabaseHelper().getContactModelList();
    setState(() {
      contactList = contacts;
    });
  }

  Future<bool> _requestPermissions() async {
    var sms = await Permission.sms.request();
    var location = await Permission.location.request();
    return sms.isGranted && location.isGranted;
  }

  Future<void> _getCurrentLocation() async {
    bool ok = await _requestPermissions();
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Permission denied")));
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = pos;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.first;
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.street}, ${place.postalCode}";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location error: $e")));
    }
  }

  Future<void> _sendLocationToContacts() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return; // Still null? Stop
    }

    if (contactList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No contacts found")));
      return;
    }

    String message =
        "🚨My location: https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude} ($_currentAddress)";

    List<String> recipients = contactList.map((e) => e.number).toList();

    try {
      String result = await sendSMS(message: message, recipients: recipients);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("SMS sent: $result")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending SMS: $e")));
    }
  }

  void _startShakeDetector() {
    _detector?.stopListening();

    _detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) async {
        final now = DateTime.now();
        if (now.difference(_lastShakeTime).inSeconds < 2) return;
        _lastShakeTime = now;

        // 🔥 Action on shake: send current location to trusted contacts
        await _sendLocationToContacts();
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
      useFilter: false,
    );
  }

  @override
  void dispose() {
    _detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(qouteIndex: qIndex, onTap: getRandomQuote),
                const SizedBox(height: 6),
                const CustomCarousel(),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Emergency",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Emergency(),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Explore LifeSafe",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const LiveSafe(),
                const SafeHome(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
