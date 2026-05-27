import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/login_screen.dart';
import 'package:women_safety_app/view/register/child/bottom_navigation_screen.dart';
import 'package:women_safety_app/widgets/custom_textfield.dart';
import 'package:women_safety_app/widgets/primary_button.dart';

class CheckUserStatusBeforeChatOnProfile extends StatelessWidget {
  const CheckUserStatusBeforeChatOnProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData) {
            return const ProfilePage();
          } else {
            showSnackBar(context: context, msg: 'Please login first');
            return LoginScreen();
          }
        }
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  TextEditingController guardianEmailC = TextEditingController();
  TextEditingController childEmailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  final key = GlobalKey<FormState>();
  String? id;
  bool isSaving = false;

  getDate() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
          setState(() {
            nameC.text = value.docs.first['name'];
            childEmailC.text = value.docs.first['childEmail'];
            guardianEmailC.text = value.docs.first['guardiantEmail'];
            phoneC.text = value.docs.first['phone'];
            id = value.docs.first.id;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isSaving
          ? const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.pink),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Center(
                    child: Form(
                      key: key,
                      child: Column(
                        children: [
                          const Text(
                            "UPDATE YOUR PROFILE",
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 25),

                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: pink200,
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/logo.png', // ⚠️ replace with your app logo
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          CustomTextField(
                            controller: nameC,
                            hintText: nameC.text,
                            validate: (v) {
                              if (v!.isEmpty) {
                                return 'Please enter your updated name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: childEmailC,
                            hintText: "Child email",
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: guardianEmailC,
                            hintText: "Parent email",
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: phoneC,
                            hintText: "Phone number",
                            readOnly: true,
                          ),
                          const SizedBox(height: 25),
                          PrimaryButton(
                            title: "UPDATE",
                            onPressed: () async {
                              if (key.currentState!.validate()) {
                                SystemChannels.textInput.invokeMethod(
                                  'TextInput.hide',
                                );
                                update();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  update() async {
    setState(() {
      isSaving = true;
    });
    Map<String, dynamic> data = {'name': nameC.text};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(data);
    setState(() {
      isSaving = false;
      goToPushReplacement(context, BottomNavigationScreen());
    });
  }
}
