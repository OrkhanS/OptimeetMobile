import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/api.dart';

class Posts with ChangeNotifier {
  List _posts = [];
  List _myposts = [];
  bool isLoadingOrders = true;
  bool isLoading;
  bool isLoadingMyOrders = true;
  String token;
  Map allTripsDetails = {};
  Map allOrdersDetails = {};
  Map allMyOrderDetails = {};
  Map allMyTripsDetails = {};

  bool get notLoadingOrders {
    return isLoadingOrders;
  }

  bool get notLoadedMyorders {
    return isLoadingMyOrders;
  }

  bool get notLoaded {
    return isLoading;
  }

  List get orders {
    return _posts;
  }

  List get myPosts {
    return _myposts;
  }

  Map get detailsOrder {
    return allOrdersDetails;
  }

  Map get detailsMyOrder {
    return allMyOrderDetails;
  }

  set orders(List temporders) {
    _posts = temporders;
    notifyListeners();
  }

  set myorders(List temporders) {
    _myposts = temporders;
    notifyListeners();
  }

  Future fetchAndSetPosts() async {
    String url = Api.postListAndPost; 
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
        },
      ).then((onValue) {
        final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
        orders = dataOrders["results"];
        allOrdersDetails = dataOrders;
        isLoadingOrders = false;
      });
    } else {
      final extractedUserData =
          json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];

      String lang1 = extractedUserData['lang1'];
      String lang2 = extractedUserData['lang2'];
      if (lang1 != "" && lang1 != null) {
        url = url + "?lang=" + lang1;
        if (lang2 != "false" && lang2 != null) {
          url = url + "&lang=" + lang2;
        }
      }

      if (token == null) {
        http.get(
          url,
          headers: {
            HttpHeaders.CONTENT_TYPE: "application/json",
          },
        ).then((onValue) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          orders = dataOrders["results"];
          allOrdersDetails = dataOrders;
          isLoadingOrders = false;
        });
      } else {
        http.get(
          url,
          headers: {
            HttpHeaders.CONTENT_TYPE: "application/json",
            "Authorization": "Token " + token,
          },
        ).then((onValue) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          orders = dataOrders["results"];
          allOrdersDetails = dataOrders;
          isLoadingOrders = false;
        });
      }
    }
    return _posts;
  }

  Future addPosts(token, description, language) async {

  const url = Api.postListAndPost;
  http.post(url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
      body: json.encode({
        "content": description,
        "lang": language,
      }));
  }

  Future fetchAndSetMyPosts(myToken) async {
    var token = myToken;
    String url = Api.myposts; 
    http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((onValue) {
      final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
      myorders = dataOrders["results"];
      allMyOrderDetails = dataOrders;
      isLoadingMyOrders = false;
    });
  }
}
