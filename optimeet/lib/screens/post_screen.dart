import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optimeet/providers/posts.dart';
import 'package:provider/provider.dart';

import 'add_post_screen.dart';

class PostScreen extends StatefulWidget {
  static const routeName = '/orders';
  var posts;
  var token, room, auth;
  PostScreen({this.token, this.auth, this.room, this.posts});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  // String _startDate = "Starting from";
  // String _endDate = "Untill";
  // String _time = "Not set";
  // String _searchBarFrom = "Anywhere";
  // String _searchBarTo = "Anywhere";
  // String _searchBarWeight = "Any";
  DateTime startDate = DateTime.now();
  String imageUrl;
  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String from, to;
  String _value = "Sort By";
  String weight, price;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List _cities = [];
  List _orders = [];
  int lines;
  //lines[widget.posts.orders.length];
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  @override
  void initState() {
    if (widget.posts.myorders.isEmpty) {
      widget.posts.fetchAndSetPosts();
    }
    // lines[widget.posts.orders.length] = [4];
    lines = 4;

    super.initState();
  }

  String urlFilter = "";
  String _myActivity;
  String _myActivityResult;

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivityResult = _myActivity;
      });
    }
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future _loadData() async {
      if (nextOrderURL.toString() != "null" &&
          nextOrderURL.toString() != "FristCall") {
        String url = nextOrderURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + widget.token,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _orders.addAll(dataOrders["results"]);
            nextOrderURL = dataOrders["next"];
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

    //print(widget.orderstripsProvider.orders);
    return Consumer<Posts>(
      builder: (context, posts, child) {
        if (widget.posts.orders.length != 0) {
          _orders = widget.posts.orders;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = widget.posts.detailsOrder["next"];
          }
          //messageLoader = false;
        } else {
          //messageLoader = true;
        }

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (__) => AddItemScreen(
                          token: widget.token,
                        )),
              );
            },
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Posts",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.blue[50],
              height: MediaQuery.of(context).size.height * .83,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child:
                        // widget.posts.notLoadingOrders
                        //     ? Center(child: CircularProgressIndicator())
                        //     :
                        NotificationListener<ScrollNotification>(
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
                      child: ListView.builder(
                        itemBuilder: (context, int i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: .0),
                            child: Card(
                              elevation: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  // border: Border.all(),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                width: 200,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20,top: 10,
                                          ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "View count: 31", //todo orxanchal
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            "Content ipspfpsf pofsdi fdContent ipspfpsf pofsdi fdspofsif so klfaskfa  ipspfpsf pofsdi fdspofsif so fuds fusd nfo kofwe fwpel nt ipspfpsf pofsdi fdspofsif so fuds fusd nfo one tro Content ipspfpsf pofsdi fdspofsif so klfaskfa  ipspfpsf pofsdi fdspofsif so fuds fusd nfo kofwe fwpel nt ipspfpsf pofsdi fdspofsif so fuds fusd nfo one tro Content ipspfpsf pofsdi fdspofsif so klfaskfa  ipspfpsf pofsdi fdspofsif so fuds fusd nfo kofwe fwpel nt ipspfpsf pofsdi fdspofsif so fuds fusd nfo one tro skfa  ipspfpsf pofsdi fdspofsif so fuds fusd nfo kofwe fwpel nt ipspfpsf pofsdi fdspofsif so fuds fusd nfo one tro ",
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            maxLines: lines,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (lines == 4)
                                              lines = 50;
                                            else
                                              lines = 4;
                                            print("lox");
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.genderMale,
                                            color: Colors.lightBlue,
                                          ), //todo orxan
                                          Text(
                                            "Anonymous",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 1,
                                            ),
                                          ),
                                          FlatButton(
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  MdiIcons.chat,
                                                  color: Colors.lightBlue,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  "Message",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.lightBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: 5,
                      ),
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
