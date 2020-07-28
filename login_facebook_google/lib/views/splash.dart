import 'package:flutter/material.dart';
import 'package:login_facebook_google/utils/constance.dart';
import 'package:login_facebook_google/utils/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: (Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Loading........',style: TextStyle(color: Colors.white, fontSize: 20),)],
        ),
      )),
    );
  }
  @override
  void initState() {
    super.initState();
    checkLogin();
  }
  checkLogin()async{
    await SharedPre.getBoolKey(SharedPre.sharedPreIsLogin).then((value){
      print("value "+value.toString());
      Future.delayed(Duration(seconds: 3),()async{
        if(value!=null){
          if(value){
            Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
          }else{
            Navigator.pushReplacementNamed(context, Constance().KEY_PROFILE_SCREEN);
          }
        }else{
          Navigator.pushReplacementNamed(context, Constance().KEY_LOGIN_SCREEN);
        }
      }
      );
    });

  }
}
