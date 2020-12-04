import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseUser _user;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Auth UI Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getMessage(),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: RaisedButton(
                  child: Text(_user != null ? 'Logout' : 'Login'),
                  onPressed: _onActionTapped,
                ),
              ),
              _getErrorText(),
              _user != null
                  ? FlatButton(
                      child: Text('Delete'),
                      textColor: Colors.red,
                      onPressed: () => _deleteUser(),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMessage() {
    if (_user != null) {
      return Text(
        'Logged in user is: ${_user.displayName ?? ''}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else {
      return Text(
        'Tap the below button to Login',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    }
  }

  Widget _getErrorText() {
    if (_error?.isNotEmpty == true) {
      return Text(
        _error,
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 16,
        ),
      );
    } else {
      return Container();
    }
  }

  void _deleteUser() async {
    final result = await FirebaseAuthUi.instance().delete();
    if (result) {
      setState(() {
        _user = null;
      });
    }
  }

  void _onActionTapped() {
    if (_user == null) {
      // User is null, initiate auth
      FirebaseAuthUi.instance().launchAuth([
        AuthProvider.email(),
        AuthProvider.google(),
      ]).then((firebaseUser) {
        setState(() {
          _error = "";
          _user = firebaseUser;
        });
      }).catchError((error) {
        if (error is PlatformException) {
          setState(() {
            if (error.code == FirebaseAuthUi.kUserCancelledError) {
              _error = "User cancelled login";
            } else {
              _error = error.message ?? "Unknown error!";
            }
          });
        }
      });
    } else {
      // User is already logged in, logout!
      _logout();
    }
  }

  void _logout() async {
    await FirebaseAuthUi.instance().logout();
    setState(() {
      _user = null;
    });
  }
}
