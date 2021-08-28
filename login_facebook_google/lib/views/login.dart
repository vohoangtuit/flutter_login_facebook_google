import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
  // todo google
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email','https://www.googleapis.com/auth/contacts.readonly']);
  GoogleSignInAccount? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // todo facebook
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _innitFacebook();
    _initGoogle();
  }
  _initGoogle(){
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {

      }
    });
    _googleSignIn.signInSilently();
  }


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
              _loginFB();
            },),
            SizedBox(height: 30,),
            NormalButton(title:'Login with Google' ,onPressed: (){
              _loginGoogle();
            },),

          ],
        ),
      ),

    );
  }
  Future<void> _innitFacebook() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    if (accessToken != null) {
      print('accessToken $accessToken');
      FacebookAuth.instance.logOut();// disconnect user
      // // now you can call to  FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData();
      // // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      // _accessToken = accessToken;
      // setState(() {
      //   _userData = userData;
      // });
    }else{
      print('accessToken null');
    }
  }
  Future<void> _loginFB() async {

    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile

    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
    //  _printCredentials();
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _userData = userData;
      print('_userData ${_userData}');
      print('token ${_accessToken!.token}');
    //  print('token ${_accessToken.}');

      _getFBProfile(_accessToken!.token);
    } else {
      print(result.status);
      print(result.message);
    }

  }

  _getFBProfile(String token)async{
   // final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${token}');
    final graphResponse = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${token}'));
    final profile = JSON.jsonDecode(graphResponse.body);
    print("profile "+profile.toString());
    SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
    SharedPre.saveString(SharedPre.sharedPreFullName, profile['name']);
    SharedPre.saveString(SharedPre.sharedPreEmail, profile['email']);
    SharedPre.saveString(SharedPre.sharedPreAvatar, profile['picture']['data']['url']);
    Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
  }


  Future<void> _loginGoogle()async{
    // FirebaseAuth.instance.authStateChanges().listen((event) {
    //   print(event.email);
    // });

    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
   //   GoogleSignInAccount googleSignInAccount = await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
      GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential authResult =
      await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      print('user $user');
      if(user!=null){
        print("_user email: " + user.email!);
        SharedPre.saveBool(SharedPre.sharedPreIsLogin, true);
        SharedPre.saveString(SharedPre.sharedPreFullName, user.displayName!);
        SharedPre.saveString(SharedPre.sharedPreEmail,user.email!);
        SharedPre.saveString(SharedPre.sharedPreAvatar,user.photoURL!);
        Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
      }
    } catch (error) {
      print(error);
    }
  }


}
