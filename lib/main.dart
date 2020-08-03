import 'package:flutter/material.dart';
import 'package:infowindow/screens/home/home_page.dart';
import 'package:infowindow/screens/login/login_page.dart';
import 'package:infowindow/screens/splash/splash.dart';
import 'package:infowindow/shared/app_color.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XACOVID',
      theme: ThemeData(
        primarySwatch: AppColor.yellow,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => SplashPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
