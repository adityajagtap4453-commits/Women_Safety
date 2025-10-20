import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/chat_module/chat_screen.dart';
import 'package:women_safety_app/view/login_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink,
        title: Text("Select Child", style: TextStyle(color: white)),
        iconTheme: IconThemeData(color: white),
      ),

      // ✅ If user is null, just show a safe message (no login button)
      body: user == null
          ? const Center(child: Text("User not found or not logged in."))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('type', isEqualTo: 'child')
                  .where(
                    'guardiantEmail',
                    isEqualTo: user.email ?? '', // Safe null handling
                  )
                  .snapshots(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: progressIndicator(context));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No child accounts found."),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final d = snapshot.data!.docs[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: pink150,
                            child: ListTile(
                              onTap: () {
                                goToPush(
                                  context,
                                  ChatScreen(
                                    currentUserId: user.uid,
                                    friendId: d.id,
                                    friendName: d['name'] ?? "Unknown",
                                  ),
                                );
                              },
                              title: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(d['name'] ?? "Unnamed"),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
            ),

      drawer: SizedBox(
        width: 200,
        child: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/logo.png"),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ListTile(
                title: TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      goToPushReplacement(context, const LoginScreen());
                    } on FirebaseAuthException catch (e) {
                      dialogueBox(context, e.message ?? "Sign out failed");
                    }
                  },
                  child: Text("SIGN OUT", style: TextStyle(color: pink400)),
                ),
                trailing: Icon(Icons.logout, color: pink400),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
