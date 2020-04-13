import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_selector_formfield/image_selector_formfield.dart';
import 'package:optimeet/main.dart';
import 'package:optimeet/screens/account_screen.dart';
import 'package:provider/provider.dart';

class CustomerSupport extends StatefulWidget {
  var user, message;
  CustomerSupport({this.user, this.message});
  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport> {
  String _startDate = "Date";
  String title;
  String from, to, description;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          "Support", //Todo: item name
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, top: 20, bottom: 20),
                  child: Text(
                    "Fill the forms",
                    style: TextStyle(
                        fontSize: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  icon: Icon(Icons.report),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String val) {},
              ),
            ),
             Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tell us about your issue..',
                  icon: Icon(Icons.report),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String val) {},
              ),
            ),
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
                        "Submit",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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
