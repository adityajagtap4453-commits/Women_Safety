import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/widgets/custom_textfield.dart';
import 'package:women_safety_app/widgets/primary_button.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  bool isSaving = false;
  double? ratings = 1.0;

  // Show Review Dialog
  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "Review Your Place",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  hintText: 'Enter Location',
                  controller: locationC,
                ),
                SizedBox(height: 10),
                CustomTextField(controller: viewsC, hintText: 'Enter Comments'),
                SizedBox(height: 15),
                RatingBar.builder(
                  initialRating: ratings!,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: primaryColor),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratings = rating;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            PrimaryButton(
              title: "SAVE",
              onPressed: () {
                saveReview();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Save review to Firestore
  saveReview() async {
    if (locationC.text.isEmpty || viewsC.text.isEmpty) {
      showSnackBar(context: context, msg: "Please fill all fields");
      return;
    }

    setState(() {
      isSaving = true;
    });

    await FirebaseFirestore.instance.collection('reviews').add({
      'location': locationC.text,
      'views': viewsC.text,
      'ratings': ratings,
    });

    setState(() {
      isSaving = false;
      locationC.clear();
      viewsC.clear();
      ratings = 1.0;
      showSnackBar(context: context, msg: 'Review uploaded successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink,
        title: Text("Reviews", style: TextStyle(color: Colors.white)),
      ),
      body: isSaving
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No reviews yet.",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                          Divider(thickness: 1),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          color: grey100,
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  "Location: ${data['location']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Comments: ${data['views']}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                RatingBarIndicator(
                                  rating: (data['ratings']?.toDouble() ?? 0),
                                  itemBuilder: (context, index) =>
                                      Icon(Icons.star, color: primaryColor),
                                  itemCount: 5,
                                  itemSize: 24.0,
                                  direction: Axis.horizontal,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pink,
        onPressed: () => showAlert(context),
        child: Icon(Icons.add, color: white, size: 30),
      ),
    );
  }
}
