import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: false,
  );

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      if (kDebugMode) {
        print("Download progress: $progress%");
      }
      if (status == 3 /* DownloadTaskStatus.complete */) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Download $id completed!"),
        ));
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri("https://proof.ovh.net/files/10Mb.dat")));
        break;
      case 1:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri(
                    "https://emirkanmaz.github.io/webpagetest/download")));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InAppWebView Download"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Download file 1'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Download file 2'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri("https://flutter.dev")),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },
              onDownloadStartRequest: (controller, downloadStartRequest) async {
                await downloadFile(
                  downloadStartRequest.url.toString(),
                  downloadStartRequest.suggestedFilename,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadFile(String url, [String? filename]) async {
    try {
      final dio = Dio();
      final response = await dio.download(
        url,
        (await getTemporaryDirectory()).path + "/" + (filename ?? "downloaded_file"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Download completed!"),
        ));

        // Open the downloaded file
        OpenFile.open(response.data.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to download file"),
        ));
      }
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error downloading file"),
      ));
    }
  }
}
