import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:optimeet/screens/chat_window.dart';
import 'package:optimeet/screens/report_user_screen.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:flutter/material.dart';
import 'chat_window.dart';
import 'package:web_socket_channel/io.dart';
import 'package:optimeet/providers/messages.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:badges/badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  final StreamController<String> streamController =
      StreamController<String>.broadcast();
  IOWebSocketChannel _channel;

  ObserverList<Function> _listeners = new ObserverList<Function>();
  var provider, token, auth;
  ChatsScreen({this.provider, this.token, this.auth});
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  String imageUrl;
  Map _details = {};
  List<dynamic> _messagess = [];
  bool _isOn = false;
  bool _islogged = true;
  bool _isloading = true;
  Map _messages = {};
  Map _mesaj = {};
  bool isMessagesLoaded = false;
  Future<int> roomLength;
  List _rooms = [];
  String myid;
  bool _isfetchingnew = false;
  String nextMessagesURL = "FirstCall";

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    if (widget.provider.chats.isEmpty) {
      widget.provider.fetchAndSetRooms(widget.auth);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    myid = widget.provider.userDetails["id"].toString();
    // getAvatarUrl(String a) {
    //   String helper = 'https://briddgy.herokuapp.com/media/';
    //   imageUrl =
    //       'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg';
    //   if (a != null) {
    //     imageUrl = 'https://briddgy.herokuapp.com/media/' + a.toString() + "/";
    //   }

    //   return imageUrl;
    // }

    List<MaterialColor> colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.lightBlue,
    ];

    Future _loadData() async {
      if (nextMessagesURL.toString() != "null") {
        String url = nextMessagesURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + widget.token,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _rooms.addAll(dataOrders["results"]);
            nextMessagesURL = dataOrders["next"];
          });
        } catch (e) {
          print("Some Error");
        }
        setState(() {
//        items.addAll( ['item 1']);
//        print('items: '+ items.toString());
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    return Consumer<Messages>(
      builder: (context, provider, child) {
        if (widget.provider.chats.length != 0) {
          _rooms = widget.provider.chatDetails["results"];
          if (nextMessagesURL == "FirstCall") {
            nextMessagesURL = widget.provider.chatDetails["next"];
          }
          //messageLoader = false;
        } else {
          //messageLoader = true;
        }
        return Scaffold(
           floatingActionButton: FloatingActionButton(
            
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
            tooltip: "Match",
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (__) => AddItemScreen(
              //             token: widget.token,
              //           )),
              // );
            },
          ),
        
          appBar: AppBar(
            // actions: <Widget>[
            //   RaisedButton(
            //     textColor: Colors.black,
            //     onPressed: () {
            //       print("salam");
            //     },
            //     child: Text("Rematch", style: TextStyle(color: Colors.black),),
            //     // shape:
            //     //     CircleBorder(side: BorderSide(color: Colors.transparent)),
            //   ),
            
            // ],
            actions: <Widget>[

    Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: () {},
        child: Icon(
          
            Icons.more_vert,
          color: Colors.black,

        ),
      )
    ),
  ],
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Chats",
                style: TextStyle(
                    color: (Theme.of(context).primaryColor),
                    fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          body: Container(
            child: widget.provider.userNotLogged == true ||
                    widget.provider.chats == null
                ? Center(child: Text('No Chats'))
                : widget.provider.chatsNotLoaded == true
                    ? Center(child: CircularProgressIndicator())
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!_isfetchingnew &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                            // start loading data
                            setState(() {
                              _isfetchingnew = true;
                              print("load order");
                            });
                            _loadData();
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                itemCount: _rooms.length,
                                itemBuilder: (context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      Divider(
                                        height: 12.0,
                                      ),
                                      Menu(
                                        child: Container(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              // Todo
                                              // Warning
                                              // Warning
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                    radius: 24.0,
                                                    child: FadeInImage(
                                                      image: NetworkImage(
                                                          'https://toppng.com/uploads/preview/person-icon-white-icon-11553393970jgwtmsc59i.png'),
                                                      placeholder: NetworkImage(
                                                          'https://toppng.com/uploads/preview/person-icon-white-icon-11553393970jgwtmsc59i.png'),
                                                    )),
                                                title: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      _rooms[index]["members"][1]
                                                                          ["user"]
                                                                      ["id"]
                                                                  .toString() !=
                                                              myid
                                                          ? _rooms[index]["members"][1]["user"]["first_name"]
                                                                  .toString() +
                                                              " " +
                                                              _rooms[index]["members"][1]["user"]["last_name"]
                                                                  .toString()
                                                          : _rooms[index]["members"][0]["user"]["first_name"]
                                                                  .toString() +
                                                              " " +
                                                              _rooms[index]["members"][0]
                                                                          ["user"]
                                                                      ["last_name"]
                                                                  .toString(),
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    SizedBox(
                                                      width: 16.0,
                                                    ),
                                                    // Text(
                                                    //   _rooms[index]["date_modified"]
                                                    //       .toString()
                                                    //       .substring(0, 10),
                                                    //   style: TextStyle(fontSize: 15.0),
                                                    // ),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Last Message:" + "  ",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                      // _messages[index]["results"][0]["text"]
                                                      //   .toString().substring(0,15)
                                                    ),
                                                    Text(
                                                      // timeago.format(DateTime.parse(_rooms[index]["date_modified"].toString().substring(0, 10) + " " + _rooms[index]["date_modified"].toString().substring(11, 26))).toString().substring(0, 1) == "3" ||
                                                      //         timeago.format(DateTime.parse(_rooms[index]["date_modified"].toString().substring(0, 10) + " " + _rooms[index]["date_modified"].toString().substring(11, 26))).toString().substring(0, 1) ==
                                                      //             "2"
                                                      //     ? "Recently"
                                                      //     :
                                                      timeago
                                                          .format(DateTime.parse(_rooms[
                                                                          index]
                                                                      [
                                                                      "date_modified"]
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10) +
                                                              " " +
                                                              _rooms[index][
                                                                      "date_modified"]
                                                                  .toString()
                                                                  .substring(
                                                                      11, 26)))
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    )
                                                  ],
                                                ),
                                                trailing: widget
                                                                .provider
                                                                .newMessages[
                                                                    _rooms[index]
                                                                        ["id"]]
                                                                .toString() !=
                                                            "0" &&
                                                        widget
                                                                .provider
                                                                .newMessages[
                                                                    _rooms[index]
                                                                        ["id"]]
                                                                .toString() !=
                                                            "null"
                                                    ? Badge(
                                                        badgeContent: Text(widget
                                                            .provider
                                                            .newMessages[
                                                                _rooms[index]
                                                                    ["id"]]
                                                            .toString()),
                                                        child: Icon(Icons
                                                            .arrow_forward_ios),
                                                      )
                                                    : Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 14.0,
                                                      ),
                                                onTap: () {
                                                  widget.provider.readMessages(
                                                      _rooms[index]["id"]);
                                                  Provider.of<Messages>(context)
                                                          .newMessage[
                                                      _rooms[index]["id"]] = 0;
                                                  widget.provider
                                                      .fetchAndSetMessages(
                                                          index);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (__) => ChatWindow(
                                                            provider:
                                                                widget.provider,
                                                            room: _rooms[index]
                                                                ["id"],
                                                            user: _rooms[index]["members"][1]["user"]
                                                                            [
                                                                            "id"]
                                                                        .toString() !=
                                                                    myid
                                                                ? _rooms[index]
                                                                        ["members"]
                                                                    [1]["user"]
                                                                : _rooms[index]
                                                                        ["members"]
                                                                    [0]["user"],
                                                            token: widget.token)),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        items: [
                                         
                                          MenuItem("Info", () {
                                            Alert(
                                              context: context,
                                              type: AlertType.info,
                                              title:
                                                  "Conversation started on:  " +
                                                      _rooms[index]
                                                              ["date_created"]
                                                          .toString()
                                                          .substring(0, 10) +
                                                      "\n",
                                              buttons: [
                                                DialogButton(
                                                  child: Text(
                                                    "Back",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  color: Color.fromRGBO(
                                                      0, 179, 134, 1.0),
                                                ),
                                                DialogButton(
                                                  child: Text(
                                                    "Report",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () => {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //       builder: (__) =>
                                                    //       //  ReportUser(
                                                    //       //       user: _rooms[index]["members"],
                                                    //       //       message: null,
                                                    //       //     )
                                                    //           ),
                                                    // ),
                                                  },
                                                  color: Color.fromRGBO(
                                                      0, 179, 134, 1.0),
                                                )
                                              ],
                                              content: Text(
                                                  "To keep our community more secure and as mentioned in our Privacy&Policy, you cannot remove chats.\n"),
                                            ).show();
                                          }),
                                        ],
                                        decoration: MenuDecoration(),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: _isfetchingnew ? 50.0 : 0.0,
                              color: Colors.transparent,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}
