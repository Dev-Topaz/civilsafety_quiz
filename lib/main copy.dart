import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _webViewController;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String filePath = 'assets/web/test.html';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Example Usage of asset_webview'),
      ),
      // body: WebView(
      //   initialUrl: 'https://deepakkadarivel.github.io/DnDWithTouch/',
      //   javascriptMode: JavascriptMode.unrestricted,
      //   onWebViewCreated: (WebViewController webViewController) {
      //     _controller.complete(webViewController);
      //   },
      //   onProgress: (int progress) {
      //     print("WebView is loading (progress : $progress%)");
      //   },
      //   // javascriptChannels: <JavascriptChannel>{
      //   //   _toasterJavascriptChannel(context),
      //   // },
      //   navigationDelegate: (NavigationRequest request) {
      //     if (request.url.startsWith('https://www.youtube.com/')) {
      //       print('blocking navigation to $request}');
      //       return NavigationDecision.prevent;
      //     }
      //     print('allowing navigation to $request');
      //     return NavigationDecision.navigate;
      //   },
      //   onPageStarted: (String url) {
      //     print('Page started loading: $url');
      //   },
      //   onPageFinished: (String url) {
      //     print('Page finished loading: $url');
      //   },
      //   gestureNavigationEnabled: true,
      //   gestureRecognizers: Set()
      //     ..add(Factory<VerticalDragGestureRecognizer>(
      //         () => VerticalDragGestureRecognizer())),
      // ),
      body: WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          _loadHtmlFromAssets();
        },
        gestureRecognizers: Set()
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     _webViewController.evaluateJavascript('add(10, 10)');
      //   },
      // ),
    ));
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
