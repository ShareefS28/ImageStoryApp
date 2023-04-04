import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_story_app/screens/FeedDetail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_story_app/model/User.dart';


class CompleteProfile extends StatefulWidget {

  const CompleteProfile({Key? key}) : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  bool _isConnected = true;

  String radioButtonItem = 'Male';
  int id = 1;

  final _formKey = GlobalKey<FormState>();
  final UserImageModel imagePick = UserImageModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore docUser = FirebaseFirestore.instance;
  TextEditingController yourNameController = TextEditingController();
  TextEditingController yourAgeController = TextEditingController();

  double widthsize = 120;
  double heightsize = 150;

  File? image;
  var username = '';
  var imagename = '';
  var age = '';
  var gender = '';

  @override
  void initState() {
    super.initState();
    initConnectivity();
    fetchUser();
  }

  Future<void> initConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = (connectivityResult != ConnectivityResult.none);
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(mounted){
        setState(() {
          _isConnected = (result != ConnectivityResult.none);
        });
      }
    });
  }

  Future<void> fetchUser() async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}').get()
      .then((value) {
        setState(() {
          username = value['name'].toString();
          age = value['age'].toString();
          gender = value['gender'].toString();
          yourNameController.text = username;
          yourAgeController.text = age;
          imagename = value['profileimage'].toString();
          if(gender == 'Male'){
            radioButtonItem = 'Male';
            id = 1;
          }
          else if(gender == 'Female'){
            radioButtonItem = 'Female';
            id = 2;
          }
          else if(gender == 'Other'){
            radioButtonItem = 'Other';
            id = 3;
          }
        });
        }
      );
    } catch (e) {
      print("Errorrrrrrrrrr at CompleteProfile.dart getUser()"+e.toString());
    }
  }

  Future PickImage(ImageSource source) async{
    XFile? singleImage = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if(singleImage != null){
      setState(() {
        this.image = File(singleImage.path);
      }); 
    }
    else{
      return;
    }
  }

  Future createUser(UserModel user) async{   
    final docUser = FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}');
    final json = user.toJson();
    await docUser.set(json);
  }

   Future updateUser(UserModel user) async{
    final docUserupdate = FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}');
    final json = user.toJson();
    await docUserupdate.update(json);
  }

  Future<dynamic> _isCollectionExits() async {
    final _query = await FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}').get();
    if (_query.exists) {
      //Collection exits
      Navigator.pop(context ,true);
    } else {
      // Collection not exits
      return false;
    }
  }

  Widget bottomsheet(){
    return Container(
      height: 200,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: SizedBox(
                width: 120,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.0,
                  children: const [
                    Icon(Icons.image_outlined,),
                    Text('Pick Gallery',)
                  ]),),
              onPressed: () => PickImage(ImageSource.gallery),
              ),
            ElevatedButton(
              child: SizedBox(
                width: 120,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.0,
                  children: const [
                    Icon(Icons.camera_alt_outlined,),
                    Text('Pick Camera',),
                  ],
                ),
              ),
              onPressed: () => PickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget inputForm(controllerName, labelname, hintname, Keyboardtypekey){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        keyboardType: Keyboardtypekey,
        controller: controllerName,
        obscureText: false,
        cursorColor: Colors.black,
        style: TextStyle(color: Colors.red.withOpacity(0.8),),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: labelname,
          labelStyle: const TextStyle(
            color: Colors.black),
            hintText: hintname,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,),
            borderRadius: BorderRadius.circular(50.0)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green.shade900,
              width: 1,
              ),
            borderRadius: BorderRadius.circular(50.0)
          ),
        ),
      ),
    );  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),),
        //appbar color
        backgroundColor: const Color(0xFF75A2EA),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () async {
            _isCollectionExits();
          },
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        //actions: [],
        centerTitle: false,
        elevation: 5,
      ),
      body: _isConnected ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*1,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 120,
                  height: 150,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,      
                        height: 150,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: image == null ? Image.network(imagename, fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset('assets/images/user_avatar.png');
                                                },)
                                                : Image.file(image!,fit: BoxFit.cover,)
                      ),
                      InkWell(  
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt_rounded,),),
                        onTap: () async {
                          await showModalBottomSheet<void>(
                            context: context, 
                            builder: (BuildContext context){
                              return bottomsheet();
                            },);
                        },
                      )
                    ],
                  ),
                ),

                Text(
                  'Upload Photo for us to easily identify you.',
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.bold),),
                //userdetail
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Enter Name
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                        child: TextFormField(
                          validator:(yourNameController) {
                            if(yourNameController == null || yourNameController.isEmpty){
                              return 'Please enter name';
                            }
                            return null;
                          },
                          controller: yourNameController,
                          obscureText: false,
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.red.withOpacity(0.8),),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Name',
                            labelStyle: const TextStyle(
                              color: Colors.black),
                            hintText: 'Enter Your Name',
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,),
                              borderRadius: BorderRadius.circular(50.0)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green.shade900,
                                width: 1,
                                ),
                              borderRadius: BorderRadius.circular(50.0)
                              ),
                            ),
                        ),
                      ),
                      //Enter Age
                      inputForm(yourAgeController, 'Age(Optional)', 'Enter Your Age', TextInputType.number),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Gender Identity',
                              style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                      //Radio Button
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 0),
                        child: Row(
                          //mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio(
                              activeColor: Colors.green,
                              value: 1, 
                              groupValue: id,
                              onChanged: (val){
                                setState(() {
                                  radioButtonItem = 'Male';
                                  id = 1;
                                });
                              },
                            ),
                            const Text(
                              'Male',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio(
                              activeColor: Colors.red,
                              value: 2, 
                              groupValue: id,
                              onChanged: (val){
                                setState(() {
                                  radioButtonItem = 'Female';
                                  id = 2;
                                });
                              },
                            ),
                            const Text(
                              'Female',
                              style: TextStyle(color: Colors.black),
                            ),
                            Radio(
                              activeColor: Colors.purple,
                              value: 3, 
                              groupValue: id,
                              onChanged: (val){
                                setState(() {
                                  radioButtonItem = 'Other';
                                  id = 3;
                                });
                              },
                            ),
                            const Text(
                              'Other',
                              style: TextStyle(color: Colors.black),
                            ),
                          ]
                        ),
                      ),
                  ],), 

                //button
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                  child: SizedBox(
                    width: 230,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Colors.blue),
                          ),
                        ),
                      ),
                      child: const Text('Save Change'),
                      onPressed: () async {
                        if(image != null){
                          await imagePick.uploadFile(image!, _auth.currentUser!.email.toString());
                          imagename = imagePick.url.toString();
                        }
                        final user = UserModel(
                          name: yourNameController.text,
                          age: int.tryParse(yourAgeController.text),
                          gender: radioButtonItem,
                          profileimage: imagename,
                        ); 
                        if (_formKey.currentState!.validate()){                      
                          try{
                            await updateUser(user);
                            Fluttertoast.showToast(
                              msg: "Update Success",
                              gravity: ToastGravity.TOP,
                            ).then((value) {
                              Navigator.pop(context, true);
                            });
                          }catch (e){
                            await createUser(user).then((value){ 
                              Fluttertoast.showToast(
                                msg: "Create Success",
                                gravity: ToastGravity.TOP,
                              );
                                Navigator.pushReplacement(context, 
                                  MaterialPageRoute(builder: (context){
                                    return const FeedDetail();
                                  }
                                )
                              );
                             }
                            );
                          }
                        } 
                      },
                    ),),
                  ),
              ],
            )
          ),
        ),
      ) 
      : const Center(
        child: Text('No internet connection.'),
      ),
    );
  }
}