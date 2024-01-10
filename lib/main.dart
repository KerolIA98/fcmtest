import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseApi().initNotifications();

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   debugPrint('Got a message whilst in the foreground!');
  //   debugPrint('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     debugPrint(
  //         'Message also contained a notification: ${message.notification}');
  //   }
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'FCM Demo Page'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? token;

  void _incrementCounter() => setState(
        () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('this does nothing'),
            duration: Duration(seconds: 1),
          ),
        ),
      );

  @override
  void initState() {
    // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
    // await getPermission();

    super.initState();
  }

  Future<void> getPermission() async {
    // You may set the permission requests to "provisional" which allows the user to choose what type
    // of notifications they would like to receive once the user receives a notification.
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);

    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    debugPrint(
        'Got user permission: ${notificationSettings.authorizationStatus}');
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS apnsToken is available, make FCM plugin API requests...
      debugPrint('The apnsToken: $apnsToken');
    }
    token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      // token is available, make FCM plugin API requests...
      debugPrint('The token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              url_launcher.launchUrl(
                Uri.parse(
                  'https://docs.google.com/document/d/1z_6uLwK5JddibHLlC4KM98cS09TU1gSLNNiJ425d1X0/edit',
                ),
              );
            },
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await getPermission();
                // if got permission then get token then show token
                token = await FirebaseMessaging.instance.getToken();
                setState(() {});
                // snackbar to show token
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Token available'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Get Permission'),
            ),
            // if token variable is not null then show token
            Visibility(
              visible: token != null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  'Token:\n\n$token',
                  onTap: token != null
                      ? () {
                          Clipboard.setData(ClipboardData(text: token!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Token copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
            // ElevatedButton(
            //     onPressed: () async {
            //       await FirebaseMessaging.instance.subscribeToTopic('myTopic');
            //     },
            //     child: const Text('Subscribe To Topic')),
            // ElevatedButton(
            //     onPressed: () async {
            //       await FirebaseMessaging.instance
            //           .unsubscribeFromTopic('myTopic');
            //     },
            //     child: const Text('un Subscribe To Topic')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
