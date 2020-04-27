import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  Map user = {};
  bool isLoadingUser = true;

  bool get isAuth {
    return token != null;
  }

  String get token1 {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        token != null) {
      return token;
    }
    return null;
  }

  set token1(String tokenlox) {
    token = tokenlox;
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
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    const url = "http://briddgy.com/api/users/me/";
    try {
      final response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + extractedUserData['token'],
      },
    ).then((response) {
      final dataOrders = json.decode(response.body) as Map<String, dynamic>;
      user = dataOrders;
      isLoadingUser = false;
      notifyListeners();
    });
    } catch (e) {
      return;
    }
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
//    final url =
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyC13spCwP_f_SalxEbkB-wjedoF8iYENlQ';
    const url = "http://briddgy.com/api/auth/";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
//      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }
  

  Future<void> signup(String email, String password, String lang1,
      String lang2, String gender, String deviceID) async {
    if(lang2 == ""){
      lang2="false";
    }
    const url = "http://briddgy.com/api/users/";
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'email': email,
            'password': password,
            'password2': password,
            'language1': lang1,
            'language2': lang2,
            'gender': gender,
            'deviceToken': deviceID,
//            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
//      final responseData = response.body;
      print("Token: $responseData");
     if (responseData['error'] != null) {
       throw HttpException(responseData['error']['message']);
     }
      token = responseData["token"];

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

  Future<void> login(String email, String password, String deviceID) async {
    const url = "http://briddgy.com/api/auth/";
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'username': email,
            'password': password,
            'deviceToken': deviceID,
          },
        ),
      );
      final responseData = json.decode(response.body);
//      final responseData = response.body;
      print("Token: $responseData");
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      token = responseData["token"];
//      _token = responseData['idToken'];
//      _userId = responseData['localId'];
//      _expiryDate = DateTime.now().add(
//        Duration(
//          seconds: int.parse(
//            responseData['expiresIn'],
//          ),
//        ),
//      );
//      _autoLogout();
      notifyListeners();
      const url1 = "http://briddgy.com/api/users/me/";
    try {
      final response = await http.get(
        url1,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
        },
      );
      final responseData1 = json.decode(response.body);
//      final responseData = response.body;
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      final prefs = await SharedPreferences.getInstance();

      final userData = json.encode(
        {
          'token':token,
          'lang1': responseData1["language1"],
          'lang2:': responseData1["language2"]
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    //return _authenticate(email, password, 'verifyPassword');
  }catch (error) {
      throw error;
    }
  }
  
  
  
  
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
//    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
//
//    if (expiryDate.isBefore(DateTime.now())) {
//      return false;
//    }
    token = extractedUserData['token'];
//    _userId = extractedUserData['userId'];
//    _expiryDate = expiryDate;
    notifyListeners();
//    _autoLogout();
    return true;
  }

  Future<void> logout(context) async {
    print(token);
    const url = "http://briddgy.herokuapp.com/api/auth/";
    http.patch(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
        body: json.encode({"token": token}));

    token = null;
//    _userId = null;
//    _expiryDate = null;
//    if (_authTimer != null) {
//      _authTimer.cancel();
//      _authTimer = null;
//    }
    Navigator.of(context).pop();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

//  void _autoLogout() {
//    if (_authTimer != null) {
//      _authTimer.cancel();
//    }
//    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
//    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
//  }
}
