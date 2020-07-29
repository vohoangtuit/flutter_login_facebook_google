import 'package:flutter/material.dart';
import 'package:login_facebook_google/customs_widget/button.dart';
import 'package:login_facebook_google/customs_widget/text_style.dart';
import 'package:login_facebook_google/utils/constance.dart';
import 'package:login_facebook_google/utils/shared_preference.dart';

class ProFileScreen extends StatefulWidget {
  @override
  _ProFileScreenState createState() => _ProFileScreenState();
}

class _ProFileScreenState extends State<ProFileScreen> {
 String name="";
 String email="";
 String avatar="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),centerTitle: true,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: avatar.isEmpty?Text('....'):
              Container(height: 200,width: 200,decoration: BoxDecoration(shape: BoxShape.circle,image: DecorationImage(fit: BoxFit.fill,image: NetworkImage(avatar))),),
            ),
            SizedBox(height: 20,),
            Text('Name: $name',style: textBlueDefault(),),
            SizedBox(height: 20,),
            Text('Email: $email',style: textBlueDefault(),),
            SizedBox(height: 40,),
            NormalButton(title:'Logout' ,onPressed: (){
              _handleLogout();
            },),

          ],
        ),
      ),

    );
  }
  @override
  void initState() {
    super.initState();
    _getInfoLocal();
  }
  _getInfoLocal()async{
   await SharedPre.getStringKey(SharedPre.sharedPreFullName).then((value) => {
   setState(() {
     name =value;
   })
   });
    await SharedPre.getStringKey(SharedPre.sharedPreEmail).then((value) => {
      setState(() {
        email =value;
      })
    });
    await SharedPre.getStringKey(SharedPre.sharedPreAvatar).then((value) => {
      if(value.isNotEmpty){
        setState(() {
          avatar =value;
          print("avatar "+avatar);
        })
      }else{
        print("avatar is null ")
      }

    });

  }
  _handleLogout()async{
    await SharedPre.clearData();
    Navigator.pushReplacementNamed(context, Constance().KEY_LOGIN_SCREEN);
  }
}
