import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optimeet/screens/FirebaseMessaging.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

// import 'FirebaseMessaging.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size; //todo : Media Query size
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height * .88,
          margin: MediaQuery.of(context).padding,
          width: deviceSize.width,
          child: AuthCard(),
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String deviceToken;
  // _getToken() {
  //   _firebaseMessaging.getToken().then((device) {
  //     deviceToken=device;
  //   print(deviceToken);

  //   });
  //   print(deviceToken);
  // }
 
  @override
  void initState(){
    super.initState();
   // _getToken();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
  
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password'], "");
            // await Provider.of<Auth>(context, listen: false)
            // .login(_authData['email'], _authData['password'], deviceToken);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'],
            _authData['password'],
            _authData['firstname'],
            _authData['lastname'],
            deviceToken);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                _authMode == AuthMode.Login ? 'Log In' : 'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
//                    color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
//                padding: EdgeInsets.symmetric(horizontal: 15),
                width: deviceSize.width * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.alternate_email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    } else
                      return null; //Todo
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
              ),
              if (_authMode == AuthMode.Signup)
                Container(
                  width: deviceSize.width * 0.8,
                  child: TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      icon: Icon(Icons.person_outline),
                    ),
                    //validator: _authMode == AuthMode.Signup ? (value) {} : null,
                    onSaved: (value) {
                      _authData['firstname'] = value;
                    },
                  ),
                ),
              if (_authMode == AuthMode.Signup)
                Container(
                  width: deviceSize.width * 0.8,
                  child: TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(
                      labelText: 'Surname',
                      icon: Icon(MdiIcons.accountTie),
                    ),
                    //validator: _authMode == AuthMode.Signup ? (value) {} : null,
                    onSaved: (value) {
                      _authData['lastname'] = value;
                    },
                  ),
                ),
              Container(
                width: deviceSize.width * 0.8,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.vpn_key),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    } else
                      return null; //Todo
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
              ),
              if (_authMode == AuthMode.Signup)
                Container(
                  width: deviceSize.width * 0.8,
                  child: TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(
                      labelText: 'Repeat Password',
                      icon: Icon(Icons.repeat),
                    ),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            } else
                              return null; //Todo
                          }
                        : null,
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//                Expanded(
//                  child: new Container(
//                      margin: const EdgeInsets.only(left: 10.0, right: 20.0),
//                      child: Divider(
//                        color: Colors.black,
//                        height: 36,
//                      )),
//                ),
                    Text(
                      "Or",
                      style: TextStyle(color: Colors.grey[500], fontSize: 20),
                    ),
//                Expanded(
//                  child: new Container(
//                      margin: const EdgeInsets.only(left: 20.0, right: 10.0),
//                      child: Divider(
//                        color: Colors.black,
//                        height: 36,
//                      )),
//                ),
                  ]),
              SizedBox(
                height: 10,
              ),
              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     _facebook(),
              //     SizedBox(
              //       width: 15,
              //     ),
              //     _google(),
              //   ],
              // ),
              
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    RaisedButton(
                      child: Text(
                        _authMode == AuthMode.Login ? 'LOG IN' : 'SIGN UP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: 
                      _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: deviceSize.width * 0.3, vertical: 15.0),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
               
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _authMode == AuthMode.Login
                        ? "Don't Have an account?"
                        : 'Already a member?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  InkWell(
                    child: Text(
                      '${_authMode == AuthMode.Login ? ' Sign up' : ' Log in'} ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor),
                    ),
                    onTap: _switchAuthMode,
                  ),
                ],
              ),
              if (_authMode == AuthMode.Login)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Forgot',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    InkWell(
                      child: Text(
                        ' password ?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor),
                      ),
                      onTap: _switchAuthMode, //Todo
                    ),
                  ],
                ),
              if (_authMode == AuthMode.Signup)
                SizedBox(
                  height: 20,
                ),
              if (_authMode == AuthMode.Signup)
                Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: deviceSize.width * 0.6,
                        child: Text(
                          "By creating an account, you agree to our ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Text(
                            ' Privacy Policy ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                                fontSize: 13),
                          ),
                          onTap: _switchAuthMode, //Todo
                        ),
                        Text(
                          "and",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        InkWell(
                          child: Text(
                            ' Terms of use ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                                fontSize: 13),
                          ),
                          onTap: _switchAuthMode, //Todo
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _google() {
//   return OutlineButton(
//     splashColor: Colors.grey,
//     onPressed: () {},
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     highlightElevation: 0,
//     borderSide: BorderSide(color: Colors.grey),
//     child: Padding(
//       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Image(
//               image: AssetImage("assets/photos/google_logo.png"), height: 25.0),
//           Padding(
//             padding: const EdgeInsets.only(left: 20, right: 20),
//             child: Text(
//               'Google',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.grey,
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

// Widget _facebook() {
//   return OutlineButton(
//     splashColor: Colors.grey,
//     onPressed: () {},
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     highlightElevation: 0,
//     borderSide: BorderSide(color: Colors.grey),
//     child: Padding(
//       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Image(
//               image: AssetImage("assets/photos/facebook_logo.png"),
//               height: 25.0),
//           Padding(
//             padding: const EdgeInsets.only(left: 10),
//             child: Text(
//               'Facebook',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.grey,
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
