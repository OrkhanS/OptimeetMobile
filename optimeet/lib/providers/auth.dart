import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
import '../models/api.dart';

class Auth with ChangeNotifier {
  String _token;
  String tokenOfUser;
  DateTime _expiryDate;
  String _userId;
  Map user = {};
  bool isLoadingUser = true;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  set token(String tokenlox) {
    _token = tokenlox;
  }

  String get userId {
    return _userId;
  }

  Map get userdetail {
    return user;
  }

  bool get isNotLoading {
    return isLoadingUser;
  }

  Future fetchAndSetUserDetails() async {
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('userData')) {
    //   return false;
    // }
    // final extractedUserData =
    //     json.decode(prefs.getString('userData')) as Map<String, Object>;

    // const url = "";
    // try {
    //   final response = await http.get(
    //   url,
    //   headers: {
    //     HttpHeaders.CONTENT_TYPE: "application/json",
    //     "Authorization": "Token " + extractedUserData['token'],
    //   },
    // ).then((response) {
    //   final dataOrders = json.decode(response.body) as Map<String, dynamic>;
    //   user = dataOrders;
    //   isLoadingUser = false;
    //   notifyListeners();
    // });
    // } catch (e) {
    //   return;
    // }
  }
  
Future<void> signup(String email, String password, String lang1,
      String lang2, String gender) async {
        //String deviceID
    if(lang2 == ""){
      lang2="false";
    }
    const url = Api.userslistAndSignUp;
    try {
      final response = await http.post(url,
          headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
          body: json.encode({
                'email': email,
            'password': password,
            'password2': password,
            'language1': lang1,
            'language2': lang2,
            'gender': gender,
            'deviceToken': "",
          }));
      final responseData = json.decode(response.body);
      print("Token: $responseData");
      _token = responseData["token"];
      tokenOfUser = responseData["token"];
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': token,
          'lang1': lang1,
          'lang2': lang2
        
//          'userId': _userId,
//          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    //return _authenticate(email, password, 'verifyPassword');
  }

  Future<void> login(String email, String password
//      , String deviceID todo fix
      ) async {
    const url = Api.login;
    try {
      final response = await http.post(url,
          headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
          body: json.encode({
            "username": email,
            "password": password,
            "deviceToken": '', //todo orxan
          }));

      final responseData = json.decode(response.body);
      _token = responseData["token"];
      tokenOfUser = responseData["token"];
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
     
      final userData = json.encode(
        {
          'token': _token,
          'lang1': responseData["language1"],
          'lang2:': responseData["language2"]
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    }
 

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
//    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
//
//    if (expiryDate.isBefore(DateTime.now())) {
//      return false;
//    }
    _token = extractedUserData['token'];
//    _userId = extractedUserData['userId'];
//    _expiryDate = expiryDate;
    notifyListeners();
//    _autoLogout();
    return true;
  }

  Future logout(context) async {
    
    // const url = Api.login;
    // http.patch(url,
    //     headers: {
    //       HttpHeaders.CONTENT_TYPE: "application/json",
    //       "Authorization": "Token " + tokenOfUser,
    //     },
    //     body: json.encode({"token": tokenOfUser}));

    tokenOfUser = _token = null;
    Navigator.of(context).pop();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

}
