import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_selector_formfield/image_selector_formfield.dart';

import 'package:provider/provider.dart';

class ReportUser extends StatefulWidget {
  var user, message;
  ReportUser({this.user, this.message});
  @override
  _ReportUserState createState() => _ReportUserState();
}

class ImageInputAdapter {
  /// Initialize from either a URL or a file, but not both.
  ImageInputAdapter({this.file, this.url})
      : assert(file != null || url != null),
        assert(file != null && url == null),
        assert(file == null && url != null);

  /// An image file
  final File file;

  /// A direct link to the remote image
  final String url;

  /// Render the image from a file or from a remote source.
  Widget widgetize() {
    if (file != null) {
      return Image.file(file);
    } else {
      return FadeInImage(
        image: NetworkImage(url),
        placeholder: AssetImage("assets/images/placeholder.png"),
        fit: BoxFit.contain,
      );
    }
  }
}

class _ReportUserState extends State<ReportUser> {
  String _startDate = "Date";
  String title;
  String from, to, description;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();

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
          "Report", //Todo: item name
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
                    "Report " +
                        widget.user[0]["first_name"] +
                        " " +
                        widget.user[0]["last_name"],
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
                  labelText: 'Tell us more:',
                  icon: Icon(Icons.report),
                ),
                keyboardType: TextInputType.text,
                onChanged: (String val) {},
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 75.0, top: 30, bottom: 20),
                      child: Text("Add Screenshots"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:20.0, top: 20),
                  child: ImageSelectorFormField(
                    cropStyle: CropStyle.rectangle,
                    icon: Icon(
                      Icons.add_photo_alternate,
                    ),
                    borderRadius: 50,
                    boxConstraints: BoxConstraints(maxHeight: 50, maxWidth: 100),
                    // backgroundColor: Colors.blueGrey,
                    // errorTextStyle: TextStyle(color: Colors.red),
                    onSaved: (img) {
                      print("ON SAVED EJECUTADO");
                    },
                    validator: (img) {
                      print("validator EJECUTADO");
                      return "Error Text";
                    },
                    // cropRatioX: 5,
                    // cropRatioY: 5,
                  ),
                )
              ],
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
                        "Report",
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
