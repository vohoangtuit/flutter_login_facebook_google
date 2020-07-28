import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:login_facebook_google/utils/shared_preference.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final facebookLogin = FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with Facebook and Google'),
        centerTitle: true,
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 200, height: 45,child:
            RaisedButton(
              child: Text('Login with Facebook', style: TextStyle(color: Colors.white, fontSize: 18),),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              onPressed: (){
                _loginWithFacebook();
              },),
            ),
            SizedBox(height: 30,),
            SizedBox(width: 200, height: 45,child:
            RaisedButton(
              child: Text('Login with Google', style: TextStyle(color: Colors.white, fontSize: 18),),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0)),
              onPressed: (){
              },),
            ),
          ],
        ),
      ),

    );
  }
  _loginWithFacebook()async{
    final result = await facebookLogin.logIn(['email']);
    if(result!=null){
      switch(result.status){
        case FacebookLoginStatus.loggedIn:

          _sendTokenToServer(result.accessToken.token);
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('FacebookLoginStatus cancel');
          break;
        case FacebookLoginStatus.error:
          print('FacebookLoginStatus error');
          break;
      }
    }
  }
  _sendTokenToServer(String token){
    // todo
    print("FB Token $token");
    _getFBProfile(token);
  }
  _getFBProfile(String token)async{
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = JSON.jsonDecode(graphResponse.body);
    print("profile "+profile);
    SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
    SharedPre.saveString(SharedPre.sharedPreFullName, profile['name']);
    SharedPre.saveString(SharedPre.sharedPreEmail, profile['email']);
//    {
//      "name": "Iiro Krankka",
//    "first_name": "Iiro",
//    "last_name": "Krankka",
//    "email": "iiro.krankka\u0040gmail.com",
//    "id": "<user id here>"
//  }
  }

  Future<FirebaseUser> _handleSignInGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    if(user!=null){
      print("signed photoUrl " + user.photoUrl);
      SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
      SharedPre.saveString(SharedPre.sharedPreFullName, user.displayName);
      SharedPre.saveString(SharedPre.sharedPreEmail,user.email);
    }
    setState(() {
      // User đã login thì hiển thị đã login

    });
    return user;
  }
  Future _handleSignOutGoogle() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
//    setState(() {
//      // Hiển thị thông báo đã log out
//      _message = "You are not sign out";
//    });
  }

  Future _checkLoginGoolge() async {
    // Khi mở app lên thì check xem user đã login chưa
    final FirebaseUser user = await _auth.currentUser();
    if (user != null) {
//      setState(() {
//        _message = "You are signed in";
//      });
    }
  }

  Future _logoutFB() async {
    // SignOut khỏi Firebase Auth
    await _auth.signOut();
    // Logout facebook
    await facebookLogin.logOut();
    setState(() {
//      _isLoggedIn = false;
    });
  }

  Future _checkLogin() async {
    // Kiểm tra xem user đã đăng nhập hay chưa
    final user = await _auth.currentUser();
    if (user != null) {
      setState(() {
//        _message = "Logged in as ${user.displayName}";
//        _isLoggedIn = true;
      });
    }
  }
}
