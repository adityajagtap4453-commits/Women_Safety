import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_app/utils/lifesafe_info.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> openMap(String location) async {
    final query = Uri.encodeComponent(location);
    final googleUrl = Uri.parse("https://www.google.com/maps/search/$query");

    if (!await launchUrl(
      googleUrl,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $googleUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: lifesafeInfo.length,
        itemBuilder: (context, index) {
          return lifeSafeContainer(onMapFunction: openMap, cardIndex: index);
        },
      ),
    );
  }

  Widget lifeSafeContainer({
    required Function onMapFunction,
    required int cardIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              onMapFunction(lifesafeInfo[cardIndex]['nearBy']!);
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    lifesafeInfo[cardIndex]['imagePath']!,
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text(lifesafeInfo[cardIndex]['text']!),
        ],
      ),
    );
  }
}
