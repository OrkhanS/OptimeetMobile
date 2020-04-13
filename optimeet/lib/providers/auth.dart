import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  Map user = {};
  bool isLoadingUser = true;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
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
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    const url = "http://briddgy.herokuapp.com/api/users/me/";
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
    const url = "http://briddgy.herokuapp.com/api/auth/";
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
      _token = responseData['idToken'];
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
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password, String firstname,
      String lastname, String deviceID) async {
    //return _authenticate(email, password, 'signupNewUser');

    const url = "http://briddgy.herokuapp.com/api/users/";
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'email': email,
            'password': password,
            'password2': password,
            'first_name': firstname,
            'last_name': lastname,
            'deviceToken': deviceID,
//            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
//      final responseData = response.body;
      print("Token: $responseData");
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      _token = responseData;
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
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
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
    const url = "http://briddgy.herokuapp.com/api/auth/";
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
        body: json.encode(
          {
            'username': email,
            'password': password,
            'deviceToken': deviceID,
//            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
//      final responseData = response.body;
      print("Token: $responseData");
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      _token = responseData;
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
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
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
    _token = extractedUserData['token'];
//    _userId = extractedUserData['userId'];
//    _expiryDate = expiryDate;
    notifyListeners();
//    _autoLogout();
    return true;
  }

  Future<void> logout(context) async {
    print(_token);
    const url = "http://briddgy.herokuapp.com/api/auth/";
    http.patch(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
        body: json.encode({"token": _token}));

    _token = null;
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
