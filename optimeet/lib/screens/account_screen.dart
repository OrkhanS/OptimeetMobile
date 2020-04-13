import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart';
import '../providers/auth.dart';
import 'package:share/share.dart';
import 'customer_support.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/accountscreen';
  var token, orderstripsProvider, auth;
  AccountScreen({this.token, this.orderstripsProvider, this.auth});
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      body: auth.isAuth
          ? AccountPage(
              token: token,
              auth: auth,
              provider: orderstripsProvider,
            )
          : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
                  // authResultSnapshot.connectionState == ConnectionState.waiting
                  //     ? SplashScreen()
                  //     : 
                      AuthScreen(),
            ),
    );
  }
}

class AccountPage extends StatefulWidget {
  var token, provider, auth;
  AccountPage({this.token, this.provider, this.auth});
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map _user = {};
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  // Future fetchAndSetUserDetails() async {
  //   // var token = Provider.of<Auth>(context, listen: false).token;
  //   var token = widget.token;

  //   const url = "http://briddgy.herokuapp.com/api/users/me/";
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       HttpHeaders.CONTENT_TYPE: "application/json",
  //       "Authorization": "Token " + token,
  //     },
  //   );

  //   if (this.mounted) {
  //     setState(() {
  //       final dataOrders = json.decode(response.body) as Map<String, dynamic>;
  //       _user = dataOrders;
  //       isLoading = false;
  //     });
  //   }
  //   return _user;
  // }

  @override
  Widget build(BuildContext context) {
    widget.auth.fetchAndSetUserDetails();

    List<ListTile> choices = <ListTile>[
      ListTile(
        leading: Icon(
          Icons.exit_to_app,
//          color: Theme.of(context).primaryColor,
        ),
        title: Text("Logout"),
        onTap: () {
          Provider.of<Auth>(context, listen: false).logout(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text("Settings"),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Account",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
//        actions: <Widget>[
//          PopupMenuButton<ListTile>(
//            icon: Icon(
//              Icons.menu,
//              color: Colors.grey[600],
//            ),
//            //onSelected: choiceAction,
//            itemBuilder: (BuildContext context) {
//              return choices.map((ListTile choice) {
//                return PopupMenuItem<ListTile>(
//                  value: choice,
//                  child: choice,
//                );
//              }).toList();
//            },
//          )
//        ],
      ),
      body: widget.auth.isNotLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(                    
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,

                              backgroundImage: NetworkImage(
                                  // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                  "https://toppng.com/uploads/preview/person-icon-white-icon-11553393970jgwtmsc59i.png"), //Todo: UserPic
//                  child: Image.network(
//                    'https://images-na.ssl-images-amazon.com/images/I/81NIli1PuqL._AC_SL1500_.jpg',
//                    fit: BoxFit.cover,
//                    loadingBuilder: (BuildContext context, Widget child,
//                        ImageChunkEvent loadingProgress) {
//                      if (loadingProgress == null) return child;
//                      return Center(
//                        child: CircularProgressIndicator(
//                          value: loadingProgress.expectedTotalBytes != null
//                              ? loadingProgress.cumulativeBytesLoaded /
//                                  loadingProgress.expectedTotalBytes
//                              : null,
//                        ),
//                      );
//                    },
//                  ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                "Anonymous User" 
                                     ,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
//                                color: Theme.of(context).primaryColor,
                                color: Colors.grey[200],
                              ),
                              child: Icon(
                                Icons.security,
                                color: Colors.grey[600],
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                    ),
                
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                        //   ListTile(
                        //     leading: Icon(MdiIcons.mailboxOpenOutline),
                        //     title: Text(
                        //       "My Items",
                        //       style: TextStyle(
                        //         fontSize: 17,
                        //         color: Colors.grey[600],
                        //       ),
                        //     ),
                        //     trailing: Container(
                        //         decoration: BoxDecoration(
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(15)),
                        //           color: Colors.grey[200],
                        //         ),
                        //         child: Icon(Icons.navigate_next)),
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (__) => MyItems(
                        //                   token: widget.token,
                        //                   orderstripsProvider: widget.provider,
                        //                 )),
                        //       );
                        //     },
                        //   ),
                        //   ListTile(
                        //     leading: Icon(MdiIcons.mapMarkerPath),
                        //     title: Text(
                        //       "My Trips",
                        //       style: TextStyle(
                        //         fontSize: 17,
                        //         color: Colors.grey[600],
                        //       ),
                        //     ),
                        //     trailing: Container(
                        //         decoration: BoxDecoration(
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(15)),
                        //           color: Colors.grey[200],
                        //         ),
                        //         child: Icon(Icons.navigate_next)),
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (__) => MyTrips(
                        //                   token: widget.token,
                        //                   orderstripsProvider: widget.provider,
                        //                 )),
                        //       );
                        //     },
                        //   ),
                        //   ListTile(
                        //     leading: Icon(MdiIcons.scriptTextOutline),
                        //     title: Text(
                        //       "Accepted Deals",
                        //       style: TextStyle(
                        //         fontSize: 17,
                        //         color: Colors.grey[600],
                        //       ),
                        //     ),
                        //     trailing: Container(
                        //         decoration: BoxDecoration(
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(15)),
                        //           color: Colors.grey[200],
                        //         ),
                        //         child: Icon(Icons.navigate_next)),
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (__) => Contracts(
                        //                   token: widget.token,
                        //                 )),
                        //       );
                        //     },
                        //   ),
                        // 
                        ],
                      ),
                    ),
                    Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.accountMultiplePlus),
                            title: Text(
                              "Invite Friends",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                            onTap: () {
                              Share.share(
                                  "Join to the Briddgy Family https://briddgy.com");
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.faceAgent),
                            title: Text(
                              "Customer Support",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (__) => CustomerSupport()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.star_border),
                            title: Text(
                              "Rate/Leave suggestion", //Todo: App Rating
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.logoutVariant),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
//                          title: Text(''),
                                  content: Text(
                                    "Are you sure you want to Log out?",
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('No.'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes, let me out!',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          )),
                                      onPressed: () {
                                        Provider.of<Auth>(context,
                                                listen: false)
                                            .logout(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.grey[200],
                                ),
                                child: Icon(Icons.navigate_next)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
