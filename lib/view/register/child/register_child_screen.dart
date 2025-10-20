import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/widgets/secondary_button.dart';
import 'package:women_safety_app/widgets/custom_textfield.dart';
import 'package:women_safety_app/widgets/primary_button.dart';
import 'package:women_safety_app/models/user_model.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/view/login_screen.dart';

class RegisterChildScreen extends StatefulWidget {
  const RegisterChildScreen({super.key});

  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  bool isPasswordShown = true;
  bool isRetypePasswordShown = true;

  final _formKey = GlobalKey<FormState>();

  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();
    if (_formData['password'] != _formData['rpassword']) {
      dialogueBox(context, 'password and confirm password should be equal');
    } else {
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _formData['cemail'].toString(),
              password: _formData['password'].toString(),
            );

        if (userCredential.user != null) {
          setState(() {
            isLoading = true;
          });
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db = FirebaseFirestore
              .instance
              .collection('users')
              .doc(v);

          final user = UserModel(
            name: _formData['name'].toString(),
            phone: _formData['phone'].toString(),
            childEmail: _formData['cemail'].toString(),
            guardianEmail: _formData['gemail'].toString(),
            id: v,
            type: 'child',
          );
          final jsonData = user.toJson();
          await db.set(jsonData).whenComplete(() {
            goToPushReplacement(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          dialogueBox(context, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          dialogueBox(context, 'The account already exists for that email.');
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        dialogueBox(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "REGISTER AS CHILD",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: kColorRed,
                            ),
                          ),
                          Image.asset(
                            'assets/logo.png',
                            height: 100,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextField(
                              hintText: 'enter name',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.name,
                              prefix: Icon(Icons.person),
                              onsave: (name) {
                                _formData['name'] = name ?? "";
                              },
                              validate: (email) {
                                if (email!.isEmpty || email.length < 3) {
                                  return 'enter correct name';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'enter phone',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.phone,
                              prefix: Icon(Icons.phone),
                              onsave: (phone) {
                                _formData['phone'] = phone ?? "";
                              },
                              validate: (email) {
                                if (email!.isEmpty || email.length < 10) {
                                  return 'enter correct phone';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'enter email',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.person),
                              onsave: (email) {
                                _formData['cemail'] = email ?? "";
                              },
                              validate: (email) {
                                if (email!.isEmpty ||
                                    email.length < 3 ||
                                    !email.contains("@")) {
                                  return 'enter correct email';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'enter guardian email',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.person),
                              onsave: (gemail) {
                                _formData['gemail'] = gemail ?? "";
                              },
                              validate: (email) {
                                if (email!.isEmpty ||
                                    email.length < 3 ||
                                    !email.contains("@")) {
                                  return 'enter correct email';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'enter password',
                              isPassword: isPasswordShown,
                              prefix: Icon(Icons.vpn_key_rounded),
                              validate: (password) {
                                if (password!.isEmpty || password.length < 7) {
                                  return 'enter correct password';
                                }
                                return null;
                              },
                              onsave: (password) {
                                _formData['password'] = password ?? "";
                              },
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordShown = !isPasswordShown;
                                  });
                                },
                                icon: isPasswordShown
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility),
                              ),
                            ),
                            CustomTextField(
                              hintText: 'Confirm Password',
                              isPassword: isRetypePasswordShown,
                              prefix: Icon(Icons.vpn_key_rounded),
                              validate: (password) {
                                if (password!.isEmpty || password.length < 7) {
                                  return 'enter correct password';
                                }
                                return null;
                              },
                              onsave: (password) {
                                _formData['rpassword'] = password ?? "";
                              },
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isRetypePasswordShown =
                                        !isRetypePasswordShown;
                                  });
                                },
                                icon: isRetypePasswordShown
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility),
                              ),
                            ),
                            PrimaryButton(
                              title: 'REGISTER',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _onSubmit();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SecondaryButton(
                      title: 'Login with your account',
                      onPressed: () {
                        goToPushReplacement(context, LoginScreen());
                      },
                    ),
                  ],
                ),
              ),
              if (isLoading) progressIndicator(context),
            ],
          ),
        ),
      ),
    );
  }
}
