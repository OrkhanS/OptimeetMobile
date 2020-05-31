import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optimeet/providers/posts.dart';
import 'package:optimeet/screens/notification_screen.dart';
import 'package:optimeet/screens/post_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optimeet/providers/messages.dart';
import 'package:optimeet/providers/auth.dart';


//import 'package:optisend/screens/add_item_screen.dart';
import './screens/account_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'models/api.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  IOWebSocketChannel _channel;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<dynamic> _rooms;
  bool _isOn = false;
  bool _loggedIn = true;
  List<dynamic> _messages = [];
  List<dynamic> _mesaj = [];
  int _currentIndex = 0;
  PageController _pageController;
  bool _enabled = true;
  int _status = 0;
  IOWebSocketChannel _channelRoom;
  String tokenforROOM;
  List<DateTime> _events = [];
  Map valueMessages = {};
  bool socketConnected = false;
  var neWMessage;

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
    getToken();
    _pageController = PageController(initialPage: 0);
  }

  // _configureFirebaseListerners(newmessage) {
  //   _firebaseMessaging.configure(
  //     // onMessage: (Map<String, dynamic> message) async {
  //     //   neWMessage.addMessages = message;
  //     // },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       neWMessage.addMessages = message;
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       neWMessage.addMessages = message;
  //     },
  //   );
  // }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
  }

  // Future onSelectNotification(String payload) async => await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ChatsScreen()),
  //     );

  initCommunication(auth, newmessage) async {
    if (socketConnected == false) {
      socketConnected = true;
      reset();
      try {
        var f, d;
        auth.removeListener(f);
        newmessage.removeListener(d);
        neWMessage = newmessage;
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('userData')) {
          return false;
        }
        final extractedUserData =
            json.decode(prefs.getString('userData')) as Map<String, Object>;

        auth.token = extractedUserData['token'];

        if (extractedUserData['token'] != null) {
          widget._channel = new IOWebSocketChannel.connect(
              Api.socketConnectAlert +
                  extractedUserData['token']);
          widget._channel.stream.listen(_onReceptionOfMessageFromServer);
          print("Alert Connected");
        }
      } catch (e) {
        print("Error Occured");
        reset();
      }
    } else {
      return;
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (widget._channel != null) {
      if (widget._channel.sink != null) {
        widget._channel.sink.close();
        _isOn = false;
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback) {
    widget._listeners.add(callback);
  }

  removeListener(Function callback) {
    widget._listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message) {
    valueMessages = json.decode(message);
    neWMessage.addMessages = valueMessages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget navbar(newmessage) {
    return BottomNavigationBar(
      elevation: 4,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.grey[400],
      unselectedFontSize: 9,
      selectedFontSize: 11,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Text('Home'),
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.home),
        ),

        
        BottomNavigationBarItem(
          title: Text('Chats'),
          icon: newmessage.arethereNewMessage == true
              ? Badge(
                  child: Icon(MdiIcons.forumOutline),
                )
              : Icon(MdiIcons.forumOutline),
          activeIcon: Icon(MdiIcons.forum),
        ),
        
        BottomNavigationBarItem(
          title: Text('Account'),
          icon: Icon(MdiIcons.accountSettingsOutline),
          activeIcon: Icon(MdiIcons.accountSettings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          builder: (_) => Messages(),
        ),
        ChangeNotifierProvider(
          builder: (_) => Posts(),
        ),
      ],
      child: Consumer3<Auth, Messages, Posts>(builder: (
        ctx,
        auth,
        newmessage,
        posts,
        _,
      ) {
        newmessage.fetchAndSetRooms(auth);
        initCommunication(auth, newmessage);
        //_configureFirebaseListerners(newmessage);
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blue[900],
            accentColor: Colors.indigoAccent,
            fontFamily: 'Lato',
          ),
          home: Scaffold(
            body: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: <Widget>[
                  PostScreen(posts:posts, token: tokenforROOM,),
                  ChatsScreen(
                      provider: newmessage, auth: auth, token: tokenforROOM),
                  AccountScreen(
                      token: tokenforROOM,
                      auth: auth,),
                ],
              ),
            ),
            bottomNavigationBar: navbar(newmessage),
          ),
          routes: {
            ChatWindow.routeName: (ctx) => ChatWindow(),
            AccountScreen.routeName: (ctx) => AccountScreen(
                token: tokenforROOM),
          },
        );
      }),
    );
  }
}
