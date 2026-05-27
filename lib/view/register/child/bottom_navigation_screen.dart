import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/add_contacts.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/chat_page.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/child_home_screen.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/profile_page.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_pages/review_page.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    ChildHomeScreen(),
    AddContactsPage(),
    ChatPage(),
    ReviewPage(),
    CheckUserStatusBeforeChatOnProfile(),
    // SettingsPage(),
  ];
  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: pink,
        currentIndex: currentIndex,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: "Review",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
