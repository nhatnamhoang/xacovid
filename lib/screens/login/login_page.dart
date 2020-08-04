import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infowindow/base/base_event.dart';
import 'package:infowindow/base/base_widget.dart';
import 'package:infowindow/base/helperBlocs/internet_bloc.dart';
import 'package:infowindow/data/remote/user_service.dart';
import 'package:infowindow/data/repo/user_repo.dart';
import 'package:infowindow/screens/home/home_bloc.dart';
import 'package:infowindow/screens/login/login_bloc.dart';
import 'package:infowindow/shared/widget/bloc_listener.dart';
import 'package:infowindow/utils/snacbar.dart';
import 'package:infowindow/utils/toast.dart';
import 'package:infowindow/widget/loading_signin_ui.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      di: [
        Provider.value(
          value: UserService(),
        ),
        ProxyProvider<UserService, UserRepo>(
          update: (context, userService, previous) =>
              UserRepo(userService: userService),
        ),
      ],
      bloc: [],
      child: LoginContainer(),
    );
  }
}



class LoginContainer extends StatefulWidget {
  @override
  _LoginContainerState createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  handleEvent(BaseEvent event) {}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SignInBloc.getInstance(
        userRepo: Provider.of(context),
      ),
      child: Consumer<SignInBloc>(
        builder: (context, bloc, child) => BlocListener<SignInBloc>(
          listener: handleEvent,
          child: LoginWidget(bloc),
        ),
      ),
    );
  }
}


class LoginWidget extends StatefulWidget {
  SignInBloc signInBloc;
  LoginWidget(this.signInBloc);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signInStart = false;
  String brandName;
  String initialCountry = 'VN';
  final TextEditingController phoneController = TextEditingController();

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }


    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void handleGoogleLogin() async {
    var sb = widget.signInBloc;
   // final InternetBloc ib = Provider.of<InternetBloc>(context);
    //await ib.checkInternet();
    setState(() {
      signInStart = true;
      brandName = 'google';
    });

    await sb.signInWithGoogle().then((_) {
      if (sb.hasError == true) {
        openToast1(context, 'Something is wrong. Please try again.');
        setState(() {
          signInStart = false;
        });
      } else {
        sb.checkUserExists().then((value) {
          if (sb.userExists == true) {
            sb.getUserData(sb.uid).then((value) => sb.saveDataToSP().then(
                    (value) => sb.setSignIn().then(
                        (value) => print(value))));
          } else {
            sb.getJoiningDate().then((value) => sb.saveDataToSP().then(
                    (value) => sb.saveToFirebase().then((value) => sb
                    .setSignIn()
                    .then((value) =>
                    print(value)))));
          }
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf9f9f9),
        body: signInStart == false ? welcomeUI() : loadingUI(brandName));
  }

  Widget welcomeUI() {
    Size size = MediaQuery.of(context).size;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      color:  Color(0xFFf9f9f9),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: slideList.length,
                    itemBuilder: (ctx, i) => SlideItem(i),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (int i = 0; i < slideList.length; i++)
                              if (i == _currentPage)
                                SlideDots(true)
                              else
                                SlideDots(false)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: new Container(
                          margin: EdgeInsets.only(right: 8.0),
                          alignment: Alignment.center,
                          child: new FlatButton(
                            color: Color(0Xff3B5998),
                            onPressed: () {
                              print("R");
                            },
                            child: new Container(
                              child: new Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  new FlatButton(
                                    // onPressed: () => handleFacebbokLogin(),
                                    padding: EdgeInsets.only(
                                      top: 20.0,
                                      bottom: 20.0,
                                    ),
                                    child: new Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          FontAwesomeIcons.facebook,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        SizedBox(width: 10,),
                                        Text(
                                          "FACEBOOK",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 0.8,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: new FlatButton(
                            color: Color(0Xffdb3236),
                            onPressed: () => {},
                            child: new Container(
                              child: new Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  new FlatButton(
                                    onPressed: () => handleGoogleLogin(),
                                    padding: EdgeInsets.only(
                                      top: 20.0,
                                      bottom: 20.0,
                                    ),
                                    child: new Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          FontAwesomeIcons.google,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        SizedBox(width: 10,),
                                        Text(
                                          "GOOGLE ",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 0.8,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  width: size.width * 0.5,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "hoặc",
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFFD9D9D9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: new Container(
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new FlatButton(
                            color: Colors.green,
                            padding: EdgeInsets.only(
                              top: 20.0,
                              bottom: 20.0,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: new Container(
                              child: Text(
                                "Vào app ngay",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold, fontSize: 17 ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/images/slider1.jpg',
  ),
  Slide(
    imageUrl: 'assets/images/slider2.png',
  ),
  Slide(
    imageUrl: 'assets/images/slider3.png',
  ),
];

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 800,
          height: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(slideList[index].imageUrl),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }
}

class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}