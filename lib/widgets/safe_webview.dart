import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SafeWebview extends StatefulWidget {
  final String url;
  const SafeWebview({super.key, required this.url});

  @override
  State<SafeWebview> createState() => _SafeWebviewState();
}

class _SafeWebviewState extends State<SafeWebview> {
  late final WebViewController controller;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebSites for Womens", style: TextStyle(fontSize: 20)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: controller),
    );
  }
}
