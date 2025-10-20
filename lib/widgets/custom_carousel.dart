import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/utils/quotes.dart';
import 'package:women_safety_app/widgets/safe_webview.dart';

class CustomCarousel extends StatelessWidget {
  const CustomCarousel({super.key});

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.of(context).push(MaterialPageRoute(builder: (conetxt) => route));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: List.generate(
          imageSliders.length,
          (index) => Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: () {
                navigateToRoute(
                  context,
                  SafeWebview(url: imageSlidersLink[index]),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(imageSliders[index]),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [blackOpacity, transparent],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8),
                      child: Text(
                        articleTitle[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
