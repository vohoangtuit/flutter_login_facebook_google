import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:login_facebook_google/customs_widget/button.dart';
import 'package:login_facebook_google/utils/constance.dart';
import 'dart:convert' as JSON;

import 'package:login_facebook_google/utils/shared_preference.dart';
class LoginScreen extends StatefulWidget {
  // todo: https://stackoverflow.com/questions/54557479/flutter-and-google-sign-in-plugin-platformexceptionsign-in-failed-com-google
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final facebookLogin = FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
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
            NormalButton(title:'Login with Facebook' ,onPressed: (){
              _loginWithFacebook();
            },),
            SizedBox(height: 30,),
            NormalButton(title:'Login with Google' ,onPressed: (){
              //_handleSignInGoogle();
              handleSignIn();
            },),

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
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${token}');
    final profile = JSON.jsonDecode(graphResponse.body);
    print("profile "+profile.toString());
    SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
    SharedPre.saveString(SharedPre.sharedPreFullName, profile['name']);
    SharedPre.saveString(SharedPre.sharedPreEmail, profile['email']);
    SharedPre.saveString(SharedPre.sharedPreAvatar, profile['picture']['data']['url']);
    Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
   // {
    // name: Võ Hoàng Duy,
    // first_name: Duy,
    // last_name: Võ, email:
    // thanhduoc2504@gmail.com,
    // picture: {
              // data: {height: 50, is_silhouette: false,
              // url: https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=2801695870075695&height=50&width=50&ext=1598582158&hash=AeQBDVywdvmEiyI1, width: 50}}, id: 2801695870075695}
  }

  Future<void> handleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    AuthResult result = (await _auth.signInWithCredential(credential));

    FirebaseUser _user = result.user;

    if(_user!=null){
      print("_user email: " + _user.email);
      SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
      SharedPre.saveString(SharedPre.sharedPreFullName, _user.displayName);
      SharedPre.saveString(SharedPre.sharedPreEmail,_user.email);
      SharedPre.saveString(SharedPre.sharedPreAvatar,_user.photoUrl);
      Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
    }

  }

_loginGoogle()async{

  try{
    await _googleSignIn.signIn();
    setState(() {
      //_isLoggedIn = true;
      print("_googleSignIn "+_googleSignIn.toString());
    });
  } catch (err){
    print(" Error :"+err.toString());
  }
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
