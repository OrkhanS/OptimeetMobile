import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = "https://briddgy.herokuapp.com/api/cities/?search=" + pattern;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _suggested = dataOrders["results"];
          isLoading = false;
        },
      );
    });
    _cities = [];
    for (var i = 0; i < _suggested.length; i++) {
      _cities.add(_suggested[i]["city_ascii"].toString() + ", " + _suggested[i]["country"].toString() + ", " + _suggested[i]["id"].toString());
    }
    return _cities;
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
          "Add Item", //Todo: item name
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
                    //var token = Provider.of<Auth>(context, listen: false).token;
                    var token = widget.token;
                    const url = "http://briddgy.herokuapp.com/api/orders/";
                    http.post(url,
                        headers: {
                          HttpHeaders.CONTENT_TYPE: "application/json",
                          "Authorization": "Token " + token,
                        },
                        body: json.encode({
                          "title": title,
                          "dimensions": 0,
                          "source": from,
                          "destination": to,
                          "date": DateTime.now().toString().substring(0, 10),
                          "address": "ads",
                          "weight": weight,
                          "price": price,
                          "trip": null,
                          "description": description
                        }));
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
