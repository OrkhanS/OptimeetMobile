import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:optimeet/providers/posts.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/orders/add_item';
  
  var token;
  AddItemScreen({ this.token});
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String _value = "English";
  String title;
  String from, to, description;
  String weight, price;
  String _selectedCity;
  List _suggested = [];
  List _cities = [];
  bool isLoading = true;
  String token;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
   Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    token = extractedUserData['token'];
  }


  @override
  void initState() {
    if (widget.token == null || widget.token == "null") {
      getToken();
    }else{
      token = widget.token;
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Add Post",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
                  child: Text(
                    "Add Post",
                    style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
        

            Column(children: <Widget>[
              
              Container(
              width: deviceWidth * 0.8,
              child: new ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: new TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Description:',
                        icon: Icon(Icons.description),
                      ),
                      onChanged: (String val) {
                        description = val;
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top:25),
              width: deviceWidth*0.4,
              child:  ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                child: DropdownButton(
                            hint: Text("English"),
                            items: [
                              DropdownMenuItem(
                                value: "Azerbaijani",
                                child: Text(
                                  "Azərbaycanca",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "English",
                                child: Text(
                                  "English",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Russian",
                                child: Text(
                                  "Pусский",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Turkish",
                                child: Text(
                                  "Türkçe",
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              _value = value;
                            },
                          ),
              ),
               
            ),

           
            ],),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,

                  elevation: 2,
//                            color: Theme.of(context).primaryColor,
                  child: Container(
                    width: deviceWidth * 0.7,
                    child: Center(
                      child: Text(
                        "Add Item",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {    
                    if (token == null){
                      getToken().whenComplete(() =>Provider.of<Posts>(context, listen: false).addPosts(widget.token, description, _value));
                    }else{
                      Provider.of<Posts>(context, listen: false).addPosts(widget.token, description, _value);
                    }
                    
                    Navigator.pop(context);
                    Flushbar(
                      title: "Item added",
                      message: "You can see all of your items in My Items section of Account",
                      aroundPadding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      duration: Duration(seconds: 5),
                    )..show(context);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
