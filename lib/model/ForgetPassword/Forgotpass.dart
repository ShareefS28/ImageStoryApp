import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordWidget extends StatefulWidget {
  ForgotPasswordWidget({Key ?key}) : super(key: key);

  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {

  TextEditingController emailAddressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF75A2EA),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
            size: 32,
          ),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // actions: [],
        centerTitle: false,
        elevation: 3,
      ),
      // backgroundColor: Colors.red,
      backgroundColor: Color(0xFF75A2EA),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      'Enter the email associated with your account and we will send you a verification code.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
              child: TextFormField(
                focusNode: myFocusNode,
                keyboardType: TextInputType.emailAddress,
                controller: emailAddressController,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(
                    color: myFocusNode.hasFocus ? Colors.orange : Colors.orange, letterSpacing: 1.3,
                  ),
                  hintText: 'Enter your email...',
                  hintStyle: TextStyle(color: Colors.purple
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  contentPadding:
                      EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                ),
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),                
            Padding(
               padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
               child: ElevatedButton(
                child: Text('Submit'),
                onPressed: () async {
                  try{
                    await _auth.sendPasswordResetEmail(email: emailAddressController.text).then((value) {
                      Fluttertoast.showToast(
                        msg: 'Email Request Has Send',
                        gravity: ToastGravity.TOP,
                      );
                      Navigator.pop(context);
                    });
                  } on FirebaseAuthException catch (e){
                    String message;
                    if(e.message == "Given String is empty or null"){
                      message = 'Email Address Was Empty';
                    }
                    else if(e.code == "network-request-failed"){
                      message = 'A Network Error';
                    }
                    else{
                      message = e.code;
                    }
                    Fluttertoast.showToast(
                      msg: message,
                      gravity: ToastGravity.TOP,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}