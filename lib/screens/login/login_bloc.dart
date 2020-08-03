import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:infowindow/base/base_bloc.dart';
import 'package:infowindow/base/base_event.dart';
import 'package:infowindow/data/repo/user_repo.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignInBloc extends BaseBloc with ChangeNotifier{

  static SignInBloc _instance;
  UserRepo _userRepo;

  static SignInBloc getInstance({
    @required UserRepo userRepo,
  }) {
    if (_instance == null) {
      _instance = SignInBloc._internal(
        userRepo: userRepo,
      );
    }
    return _instance;
  }

  SignInBloc._internal({
    @required UserRepo userRepo,
  })  : _userRepo = userRepo;


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();
  var scaffoldKey = new GlobalKey<ScaffoldState>();


  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  set isSignedIn (newVal) => _isSignedIn = newVal;

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError (newError) => _hasError = newError;

  String _phone;
  String get phone => _phone;
  set phone(newCode) => _phone = newCode;

  String _errorCode;
  String get errorCode => _errorCode;
  set errorCode(newCode) => _errorCode = newCode;

  bool _userExists = false;
  bool get userExists => _userExists;
  set setUserExist(bool value) => _userExists = value;

  String _name;
  String get name => _name;
  set setName(newName) => _name = newName;

  String _uid;
  String get uid =>_uid;
  set setUid(newUid) => _uid = newUid;

  String _email;
  String get email => _email;
  set setEmail(newEmail) => _email = newEmail;

  String _imageUrl;
  String get imageUrl => _imageUrl;
  set setImageUrl(newImageUrl) => _imageUrl = newImageUrl;


  String _car;
  String get car => _car;
  set setCar(String car) => _car = car;

  String _nickName;
  String get nickName => _nickName;
  set setNickName(String nickName) => _nickName = nickName;

  String _joiningDate;
  String get joiningDate => _joiningDate;
  set setJoiningDate(newDate) => _joiningDate = newDate;


  Future setPhone(String phone)  {
    _phone = phone;
    notifyListeners();
  }


  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googlSignIn.signIn().catchError((error) => print('error : $error'));
    if(googleUser != null){
      try{
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        FirebaseUser userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;

        this._name = userDetails.displayName;
        this._email = userDetails.email;
        this._imageUrl = userDetails.photoUrl;
        this._uid = userDetails.uid;

        hasError = false;
        notifyListeners();
      }

      catch(e){
        _hasError = true;
        _errorCode = e.code;
        notifyListeners();
      }
    } else{
      _hasError = true;
      notifyListeners();
    }
  }



//  Future logInwithFacebook() async {
//    FirebaseUser currentUser;
//    // fbLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
//    // if you remove above comment then facebook login will take username and pasword for login in Webview
//
//    final FacebookLoginResult facebookLoginResult =  await fbLogin.logIn(['email', 'public_profile']).catchError((error) => print('error: $error'));
//    if(facebookLoginResult.status == FacebookLoginStatus.cancelledByUser){
//      _hasError = true;
//      _errorCode = 'cancel';
//      notifyListeners();
//    } else if(facebookLoginResult.status == FacebookLoginStatus.error){
//      _hasError = true;
//      notifyListeners();
//    } else{
//      try {
//        if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
//          FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
//          final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: facebookAccessToken.token);
//          final FirebaseUser user = (await _firebaseAuth.signInWithCredential(credential)).user;
//          assert(user.email != null);
//          assert(user.displayName != null);
//          assert(!user.isAnonymous);
//          assert(await user.getIdToken() != null);
//          currentUser = await _firebaseAuth.currentUser();
//          assert(user.uid == currentUser.uid);
//
//          this._name = user.displayName;
//          this._email = user.email;
//          this._imageUrl = user.photoUrl;
//          this._uid = user.uid;
//
//
//          _hasError = false;
//          notifyListeners();
//        }
//      } catch (e) {
//        _hasError = true;
//        _errorCode = e.code;
//        notifyListeners();
//      }
//    }
//  }


  Future checkUserExists () async {
    await Firestore.instance.collection('users').getDocuments().then((QuerySnapshot snap) {
      List values = snap.documents;
      List uids =[];
      values.forEach((element) {
        uids.add(element['uid']);
      });
      if(uids.contains(_uid)) {
        _userExists = true;
        print('User exists');

      } else{
        _userExists = false;
        print('new User');
      }
      notifyListeners();


    });
  }



  Future saveToFirebase() async {
    final DocumentReference ref = Firestore.instance.collection('users').document(uid);
    await ref.setData({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'joining date': _joiningDate,
      'loved blogs' : [],
      'loved places' : [],
      'bookmarked blogs' : [],
      'bookmarked places' : []
    });

  }

  handleSignIn(String phone, String pass) async {
    try {
      QuerySnapshot snap = await Firestore.instance.collection('users')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: pass).getDocuments();
      var x = snap.documents;
      if(x.length > 0) {
        return x[0].data;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }



  Future getJoiningDate ()async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd-MM-yyyy').format(now);
    _joiningDate = _date;
    notifyListeners();
  }


  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', _name);
    await sharedPreferences.setString('email', _email);
    await sharedPreferences.setString('image url', _imageUrl);
    await sharedPreferences.setString('uid', _uid);
    await sharedPreferences.setString('car', _car);
    await sharedPreferences.setString('nickName', _nickName);
  }


  Future setNewUser (name, imageUrl, id, email, car, nickName ) async {
    _name = name;
    _imageUrl = imageUrl;
    _uid = id;
    _email = email;
    _car = car;
    _nickName = nickName;
    notifyListeners();
  }


  Future getUserData (uid) async{
    await Firestore.instance.collection('users').document(uid).get().then((DocumentSnapshot snap) {
      this._uid = snap.data['uid'];
      this._name = snap.data['name'];
      this._email = snap.data['email'];
      this._imageUrl = snap.data['image url'];
      this._joiningDate = snap.data['joining date'];
    });
    notifyListeners();

  }


  Future setSignIn ()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('sign in', true);
    notifyListeners();
  }

  void checkSignIn () async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('sign in')?? false;
    notifyListeners();
  }

  @override
  void dispatchEvent(BaseEvent event) {
    // TODO: implement dispatchEvent
  }

}