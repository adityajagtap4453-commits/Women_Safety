import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:send_message/send_message.dart';
import 'package:women_safety_app/controller/db_services.dart';
import 'package:women_safety_app/models/contact_model.dart';
import 'package:women_safety_app/widgets/primary_button.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({super.key});
  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _currentPosition;
  String? _currentAddress;
  List<ContactModel> contactList = []; // initially empty

  @override
  void initState() {
    super.initState();
    _getSavedContacts(); // fetch contacts from DB
    _getCurrentLocation(); // get location automatically
  }

  // ✅ Fetch contacts from database
  Future<void> _getSavedContacts() async {
    List<ContactModel> contacts = await DatabaseHelper().getContactModelList();
    setState(() {
      contactList = contacts;
    });
  }

  // ✅ Request SMS + Location permissions
  Future<bool> _requestPermissions() async {
    var sms = await Permission.sms.request();
    var location = await Permission.location.request();
    return sms.isGranted && location.isGranted;
  }

  // ✅ Get current location and address
  Future<void> _getCurrentLocation() async {
    bool ok = await _requestPermissions();
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Permission denied")));
      return;
    }

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
  }

  // ✅ Send alert to all saved contacts
  Future<void> _sendAlert() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Get location first")));
      return;
    }

    if (contactList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No emergency contacts found")),
      );
      return;
    }

    String message =
        "🚨 I'm in trouble! My location: https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude} ($_currentAddress)";

    List<String> recipients = contactList
        .map((e) => e.number.toString())
        .toList();

    try {
      String result = await sendSMS(message: message, recipients: recipients);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("SMS sent: $result")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ✅ Bottom sheet
  void showBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Send your current location to emergency contacts",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  if (_currentAddress != null) Text("📍 $_currentAddress"),
                  const SizedBox(height: 15),
                  PrimaryButton(
                    title: "Get Location",
                    onPressed: () async {
                      await _getCurrentLocation();
                      setModalState(() {}); // ✅ Refresh bottom sheet UI
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(title: "Send Alert", onPressed: _sendAlert),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showBottomSheet(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text(
                    "Send Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Share your current location quickly"),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/route.jpg', height: 140),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
