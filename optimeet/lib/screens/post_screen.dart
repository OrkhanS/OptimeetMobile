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
  PostScreen({this.token, this.auth, this.room,this.posts});

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
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  @override
  void initState() {
    // if (widget.widget.posts.myorders.isEmpty) {
    //   widget.widget.posts.fetchAndSetOrders();
    // }

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
      if (nextOrderURL.toString() != "null" && nextOrderURL.toString() != "FristCall") {
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
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          body: GestureDetector(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * .83,
                child: Column(
                  children: <Widget>[
                    
                    Expanded(
                      child: widget.posts.notLoadingOrders
                          ? Center(child: CircularProgressIndicator())
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
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
                                  return InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (__) => new ItemScreen(
                                      //       id: _orders[i]["id"],
                                      //       owner: _orders[i]["owner"],
                                      //       title: _orders[i]["title"],
                                      //       destination: _orders[i]["destination"],
                                      //       source: _orders[i]["source"]["city_ascii"],
                                      //       weight: _orders[i]["weight"],
                                      //       price: _orders[i]["price"],
                                      //       date: _orders[i]["date"],
                                      //       description: _orders[i]["description"],
                                      //       image: _orders[i]["orderimage"],
                                      //       token: widget.token,
                                      //       room: widget.room,
                                      //       auth: widget.auth,
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      height: 130,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Card(
                                        elevation: 4,
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                child: Image(
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                            : null,
                                                      ),
                                                    );
                                                  },

                                                  image: NetworkImage(
                                                      // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                                      "https://picsum.photos/250?image=9"), //Todo,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text(
//                                                    _orders[i]["title"].toString().length > 20
//                                                        ? _orders[i]["title"].toString().substring(0, 20) + "..."
//                                                        :
                                                      _orders[i]["title"].toString(), //Todo: title
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Icon(
                                                        MdiIcons.mapMarkerMultipleOutline,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      SizedBox(
                                                        width: 200,
                                                        child: Text(
                                                          _orders[i]["source"]["city_ascii"] + "  >  " + _orders[i]["destination"]["city_ascii"],
                                                          //Todo: Source -> Destination
                                                          maxLines: 1,
                                                          style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
//                                        mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            MdiIcons.calendarRange,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                          Text(
                                                            _orders[i]["date"].toString(),
                                                            //Todo: date
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.attach_money,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                          SizedBox(
                                                            width: 50,
                                                            child: Text(
                                                              _orders[i]["price"].toString(),
                                                              //Todo: date
                                                              maxLines: 1,
                                                              style: TextStyle(color: Colors.grey[600]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: _orders.length,
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
          ),
        );
      },
    );
  }
}
