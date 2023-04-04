import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_story_app/screens/CompleteProfile.dart';
import 'package:image_story_app/screens/FeedDetail.dart';
import 'package:image_story_app/model/ForgetPassword/Forgotpass.dart';

class HomePageDetail extends StatefulWidget {
  HomePageDetail({Key? key}) : super(key: key);

  @override
  State<HomePageDetail> createState() => _HomePageDetailState();
}

class _HomePageDetailState extends State<HomePageDetail>{

  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordCreateController = TextEditingController();
  bool passwordCreateVisibility = true;
  TextEditingController passwordConfirmController = TextEditingController();
  bool passwordConfirmVisibility = true;
  TextEditingController emailAddressLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();
  bool passwordLoginVisibility = true;
  
  late String password;

  @override
  void initState() {
    super.initState();
  }

  final List<Tab> myTab = <Tab>[
    const Tab(text: "Login",),
    const Tab(text: "Register"),
  ];
  
  final _formKeyregis = GlobalKey<FormState>();
  final _formKeylogin = GlobalKey<FormState>();

  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<dynamic> _isCollectionExits() async {
    var _query = await FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}').get();
    if (_query.exists) {
      // Collection exits
       Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) {
          return FeedDetail();
          }
        ),
      );
    } 
    else if(!_query.exists){
      // Collection not exits
      Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) {
          return CompleteProfile();
          }
        ),
      );
    } 
    else{
      print("Errorrrrrrrrrrrr at HomeDetail.dart in _isCollectionExits");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF75A2EA),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  color: Color(0xFF75A2EA),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 70, 0, 0),
                        child: Column(children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  // width: 200,
                                  // height: 130,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                            child: DefaultTabController(
                              length: myTab.length,
                              initialIndex: 0,
                              child: Column(
                                children: [
                                  TabBar(
                                    indicatorColor: Colors.black,
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.grey[200],
                                    indicatorWeight: 3,
                                    tabs: myTab
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        // Page Login
                                        // EmailLogin
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                            child: Form(
                                              key: _formKeylogin,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                                      child: TextFormField(
                                                        validator: EmailValidator(errorText: 'Incorrect Form'),
                                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                                        keyboardType: TextInputType.emailAddress,
                                                        controller: emailAddressLoginController,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                          hintText: 'Email Address',
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: const BorderSide(
                                                              color: Color(0x00000000),
                                                              width: 1,
                                                            ),
                                                            borderRadius: BorderRadius.circular(8.0),
                                                          ),
                                                          focusedBorder: const OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Color(0x00000000),
                                                              width: 1,
                                                              ),
                                                          ),
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                                                        ),
                                                        style: TextStyle(color: Colors.black.withOpacity(0.6),),
                                                      ),),
                                                      //passwordLogin
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                                        child: TextFormField(
                                                          validator: RequiredValidator(errorText: 'Please Enter a Password'),
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          controller: passwordLoginController,
                                                          obscureText: passwordLoginVisibility,
                                                          decoration: InputDecoration(
                                                            hintText: "Password",
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                                ), 
                                                                borderRadius: BorderRadius.circular(8),                                                  
                                                                ),
                                                                focusedBorder: const OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color: Color(0x00000000),
                                                                    width: 1),
                                                                    ),
                                                                    filled: true,
                                                                    fillColor: Colors.white,
                                                                    contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                                                                    // passwordView
                                                                    suffixIcon: InkWell(
                                                                      onTap: () => setState(
                                                                        () => passwordLoginVisibility = !passwordLoginVisibility,
                                                                      ),
                                                                      focusNode: FocusNode(skipTraversal: true),
                                                                      child: Icon(
                                                                        passwordLoginVisibility ?Icons.visibility_off_outlined: Icons.visibility_outlined,
                                                                        color: Colors.grey[400],
                                                                        size: 20,
                                                                      ),
                                                                    ),
                                                                    ),
                                                                    style: TextStyle(color: Colors.black.withOpacity(0.6),
                                                                    ),
                                                        ),),
                                                      //buttonLogin
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                                                        child: SizedBox(
                                                          width: 230,
                                                          height: 60,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(Colors.red[400]),
                                                              foregroundColor: MaterialStateProperty.all(Colors.white),
                                                              shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  side: const BorderSide(
                                                                    color: Colors.blue,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Text('Login'.toUpperCase()),
                                                            onPressed: () async{
                                                              if(_formKeylogin.currentState!.validate()){
                                                                _formKeylogin.currentState!.save();
                                                                try{
                                                                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                                                                    email: emailAddressLoginController.text, 
                                                                    password: passwordLoginController.text).then((value){
                                                                    _isCollectionExits();
                                                                  }
                                                                );
                                                                _formKeylogin.currentState!.reset();
                                                                }on FirebaseAuthException catch(e){
                                                                  String message;
                                                                  if(e.code == "network-request-failed"){
                                                                    message = 'A Network Error';
                                                                  }
                                                                  else{
                                                                    message = e.code;
                                                                  }
                                                                  Fluttertoast.showToast(
                                                                    msg: message,
                                                                    gravity: ToastGravity.TOP,);
                                                                  }
                                                                };
                                                              },
                                                            ),
                                                          )
                                                        ),
                                                        
                                                      //fogetPassWordButton
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                                                        child: SizedBox(
                                                          width: 180,
                                                          height: 40,
                                                          child: TextButton(
                                                            child: Text('Forgot Password?'),
                                                            style: TextButton.styleFrom(
                                                              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                              primary: Colors.black
                                                            ),
                                                            onPressed: () {
                                                              Navigator.push(context, 
                                                                MaterialPageRoute(builder: (context) => ForgotPasswordWidget()));
                                                            },),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ),),
                                          //Page Register
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                              child: Form(
                                                key: _formKeyregis,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      //Emailregis
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                                        child: TextFormField(
                                                          keyboardType: TextInputType.emailAddress,
                                                          validator: MultiValidator([
                                                            RequiredValidator(errorText: 'Please Enter an Email'),
                                                            EmailValidator(errorText: 'InCorrect Form'),]),
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          controller: emailAddressController,
                                                          obscureText: false,
                                                          decoration: InputDecoration(
                                                            hintText: 'Email Address',
                                                            enabledBorder: OutlineInputBorder( 
                                                              borderSide: const BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            focusedBorder: const OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                                ),
                                                              ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                                                          ),
                                                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                                        ),),
                                                      //RegisterPassword
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                                        child: TextFormField(
                                                          validator: RequiredValidator(errorText: 'Please Enter a Password'),
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          onChanged: (value) => password = value,
                                                          controller: passwordCreateController,
                                                          obscureText: passwordCreateVisibility,
                                                          decoration: InputDecoration(
                                                            hintText: 'Enter Your Password',
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            focusedBorder: const OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                                ),
                                                              ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                                                            //passwordView
                                                            suffixIcon: InkWell(
                                                              onTap: () => setState(
                                                                () => passwordCreateVisibility = !passwordCreateVisibility,),
                                                                child: Icon(passwordCreateVisibility ?Icons.visibility_off_outlined :Icons.visibility_outlined,
                                                                color: Colors.grey[400],
                                                                size: 20,
                                                                ),
                                                                focusNode: FocusNode(skipTraversal: true),
                                                              ),
                                                          ),
                                                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                                          ),),
                                                      //ConfirmRegisterPassword
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                                        child: TextFormField(
                                                          controller: passwordConfirmController,
                                                          validator: (value) => MatchValidator(errorText: 'Passwords not match').validateMatch(value!, password),
                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                          obscureText: passwordConfirmVisibility,
                                                          decoration: InputDecoration(
                                                            hintText: 'Confirm Your Password',
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                              ),
                                                            borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            focusedBorder: const OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Color(0x00000000),
                                                                width: 1,
                                                                )
                                                              ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
                                                            //passwordView
                                                            suffixIcon: InkWell(
                                                              onTap: () => setState(
                                                                () => passwordConfirmVisibility = !passwordConfirmVisibility,),
                                                                child: Icon(passwordConfirmVisibility ?Icons.visibility_off_outlined :Icons.visibility_outlined,
                                                                color: Colors.grey[400],
                                                                size: 20,
                                                                ),
                                                                focusNode: FocusNode(skipTraversal: true),
                                                              )
                                                            ),
                                                            style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                                        ),),
                                                      //ButtonRegister
                                                      Padding(
                                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                                                        child: SizedBox(
                                                          width: 230,
                                                          height: 60,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(Colors.green[400]),
                                                              foregroundColor: MaterialStateProperty.all(Colors.white),
                                                              shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  side: const BorderSide(
                                                                    color: Colors.blue),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Text('Register'.toUpperCase()),
                                                            onPressed: () async {
                                                              if(_formKeyregis.currentState!.validate()){
                                                                _formKeyregis.currentState!.save();
                                                                try{
                                                                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                                                    email: emailAddressController.text.trim(),
                                                                    password: passwordConfirmController.text.trim(),
                                                                  ).then((value){
                                                                    _isCollectionExits();
                                                                    Fluttertoast.showToast(
                                                                      msg: "Create Success",
                                                                      gravity: ToastGravity.TOP,
                                                                      );
                                                                    _formKeyregis.currentState!.reset();
                                                                    }
                                                                  );
                                                                } on FirebaseAuthException catch (e) {
                                                                  String message;
                                                                  if(e.code == 'email-already-in-use'){
                                                                    message = 'Already Had This Email';
                                                                  }
                                                                  else if(e.code == 'weak-password'){
                                                                    message = 'password atlease 6 character or digit';
                                                                  }else if(e.code == "network-request-failed"){
                                                                    message = 'A Network Error';
                                                                  }
                                                                  else{
                                                                    message = e.message!;
                                                                  }
                                                                  Fluttertoast.showToast(
                                                                    msg: message,
                                                                    gravity: ToastGravity.TOP,
                                                                    );
                                                                };
                                                              } 
                                                            },
                                                          ),
                                                      ),),
                                                    ],
                                                  ),
                                            ),),
                                      ],)
                                  ),
                                ],
                              ),
                            ),
                        ))
                      ]),
                    ),//
                ),
              ],
            )
          ],
            ),
        ),
      ));
  }
}




//  StreamBuilder<User?>(
//     stream: _auth.authStateChanges(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting){
//         return Center(child: CircularProgressIndicator(),);
//       }
//     },
//   );



    // if (_query.docs.isNotEmpty) {
    //   // Collection exits
    //   return StreamBuilder<User?>(
    //       stream: _auth.authStateChanges(),
    //       builder: (context, snapshot){
    //         if (snapshot.connectionState == ConnectionState.waiting){
    //           return Center(child: CircularProgressIndicator());
    //         }
    //         else if (snapshot.hasData){
    //           // Collection exits
    //           return FeedDetail();
    //         }
    //         else{
    //           return Center(child: Text("Something went wrong!"),);
    //         }
    //       }
    //     );
    // } else {
    //   // Collection not exits
    //   return StreamBuilder<User?>(
    //       stream: _auth.authStateChanges(),
    //       builder: (context, snapshot){
    //         if (snapshot.connectionState == ConnectionState.waiting){
    //           return Center(child: CircularProgressIndicator());
    //         }
    //         else if (snapshot.hasData){
    //           // Collection not exits
    //           return CompleteProfile();
    //         }
    //         else{
    //           return Center(child: Text("Something went wrong!"),);
    //         }
    //       }
    //   );
    // }