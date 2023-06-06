import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:exif/exif.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_story_app/model/PostCreate/CreatePostModel.dart';

class CreatePost extends StatefulWidget {

  final String? albumsId;
  CreatePost({super.key, this.albumsId});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  final _formKeyAlbums = GlobalKey<FormState>();
  bool _isConnected = true;
  
  Map<dynamic, DateTime> _pairImageTime = {};
  Map<String, DateTime> _pairImageTimeToString = {};
  int _numImages = 20;
  int _currentIndex = 1;
  DateTime currentTime = DateTime.now();
  String? dateTimeString;
  List<int> indexofTime = [4,7];
  List<String> items_category = <String>['None', 'Fun', 'Cozy&Relax', 'Reminiscene'];
  String? dropdownCategory;
  String CreateOrUpdate = '';
  bool enableText = true;
  bool isUploaded = false;

  TextEditingController numImages = TextEditingController(); 
  TextEditingController albumNames = TextEditingController();
  CarouselController carouselController = CarouselController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore docUser = FirebaseFirestore.instance;
  final StorageCreatePost storagePost = StorageCreatePost();

  DocumentSnapshot<Map<String, dynamic>>? eachData;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _checkEdit();
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

  Future<void> _checkEdit() async {
    if(widget.albumsId != null){
      eachData = await docUser.collection('Users').doc("${_auth.currentUser?.email}").get();
      final docRef = await docUser.collection('Users').doc('${_auth.currentUser?.email}').collection('story').doc(widget.albumsId).get();
      final docData = CreatePostModelPull.fromSnapshot(docRef, _auth.currentUser!.uid);
      setState(() {
        CreateOrUpdate = 'Update';
        albumNames.text = docData.albumsNames.toString();
        dropdownCategory = docData.Category;
        docData.ImagesFile = Map.fromEntries(docData.ImagesFile.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
        docData.ImagesFile.forEach((key, value) {
          _pairImageTimeToString[key] = value.toDate();
          _pairImageTime[key] = value.toDate();
        });
      });
    }
    else{
      eachData = await docUser.collection('Users').doc("${_auth.currentUser?.email}").get();
      setState(() {
        dropdownCategory = items_category.first;
        CreateOrUpdate = 'Create';
      });
    }
  }


  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
  }

  void _pickImage() async {
    if (_pairImageTime.length < _numImages){
      List<XFile> image = await ImagePicker().pickMultiImage(maxWidth: 900,maxHeight: 900,imageQuality: 80,);
      if(image.isNotEmpty && (image.length <= (_numImages-_pairImageTimeToString.length))){
        for(int i=0; i < image.length; i++){
          Uint8List fileBytes = File(image[i].path).readAsBytesSync();
          Map<String, IfdTag> data = await readExifFromBytes(fileBytes);
          IfdTag dateTimeTag = data["Image DateTime"]!;   // data["Image DateTime"]! EXIF data no miliseconds
          dateTimeString = dateTimeTag.toString();
          for(var j=0; j<indexofTime.length; j++){
            dateTimeString = replaceCharAt(dateTimeString.toString(), indexofTime[j], "-"); // YYYY:MM:DD hh:mm:ss to YYYY-MM-DD hh:mm:ss;
          }
          setState(() {
            _pairImageTime[File(image[i].path)] = DateTime.parse(dateTimeString!);
          });
        }
      }
      else if(image.isNotEmpty && image.length > _numImages-_pairImageTimeToString.length){
        showDialog(
          context: context,
          builder: (context) {
            return alertExceedtwenty(context, 'You can only pick up to '+(_numImages-_pairImageTimeToString.length).toString()+' images');  
          }
        );
      }
    }
    else{
      showDialog(
        context: context,
        builder: (context) {
          return alertExceedtwenty(context, 'Max 20 images');  
        }
      );
    }
  }

  void _singleImage() async {
    if(_pairImageTime.length < _numImages){
      XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.gallery,maxWidth: 900,maxHeight: 900,);
      if (singleImage != null && _pairImageTime.length < 20) {
        Uint8List fileBytes = File(singleImage.path).readAsBytesSync();
        Map<String, IfdTag> data = await readExifFromBytes(fileBytes);
        IfdTag dateTimeTag = data["Image DateTime"]!;
        dateTimeString = dateTimeTag.toString();
        for(var j=0; j<indexofTime.length; j++){
          dateTimeString = replaceCharAt(dateTimeString.toString(), indexofTime[j], "-");
        }
        setState(() {
          _pairImageTime[File(singleImage.path)] = DateTime.parse(dateTimeString!);
        });
      }
      else{
        showDialog(
          context: context,
          builder: (context) {
            return alertExceedtwenty(context, 'You can only pick up to '+_numImages.toString()+' images');  
        }
        );
      }
    }
  }

  Future<void> _pressButtonCreate(String? albumsId) async {
    if(albumNames.text.isNotEmpty){
      if (_pairImageTime.isNotEmpty) { 
        if (_formKeyAlbums.currentState!.validate()){
          setState(() {isUploaded = true;});
          if(isUploaded == true){
            showDialog(
              context: context, 
              barrierDismissible: false,
              builder: (context){
                return WillPopScope(
                  onWillPop: () async => false,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amberAccent,
                      backgroundColor: Colors.blueGrey,
                  ),),
                );
              });
          }
          for(int i=0; i<_pairImageTime.length; i++){
            if(widget.albumsId == null){
                await storagePost.uploadFile(_pairImageTime.keys.elementAt(i), _pairImageTime.values.elementAt(i), _auth.currentUser!.email.toString(), '${_auth.currentUser?.email}'+" "+currentTime.toString());
                _pairImageTimeToString[storagePost.url!] = storagePost.timestamp!; 
            }
            else{
              try{
                await storagePost.uploadFile(_pairImageTime.keys.elementAt(i), _pairImageTime.values.elementAt(i), _auth.currentUser!.email.toString(), widget.albumsId.toString());
                _pairImageTimeToString[storagePost.url!] = storagePost.timestamp!; 
              }catch(e){
                _pairImageTimeToString[_pairImageTime.keys.elementAt(i)] = _pairImageTime.values.elementAt(i); 
              }
            }
          }
          setState(() {isUploaded = false; Navigator.pop(context);});
          final CreatePost = CreatePostModel(
            uid: _auth.currentUser!.uid,
            createby: eachData!["name"].toString(),
            albumsnames: albumNames.text,
            category: dropdownCategory,
            timecreate: currentTime,
            image: _pairImageTimeToString,
          );
          if(albumsId == null){
            createAlbums(CreatePost).then((value) {
              Fluttertoast.showToast(msg: "Create Success", gravity: ToastGravity.TOP,);
            });
          }
          else{
            updateAlbums(CreatePost).then((value) {
              Fluttertoast.showToast(msg: "Update Success", gravity: ToastGravity.TOP,);
            });
          }
          Navigator.pop(context, true);
        } 
      }
      else{
        showDialog(
          context: context,
          builder: (context) {
            return alertExceedtwenty(context, 'Please Choose Images');  
          }
        );
      }
    }
    else{
      showDialog(
        context: context,
        builder: (context) {
          return alertExceedtwenty(context, 'Please Enter Albums Names');  
        }
      );
    }
  }
  
  Future createAlbums(CreatePostModel post) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}').collection('story').doc('${_auth.currentUser?.email}'+" "+currentTime.toString());
    final docDataPost = FirebaseFirestore.instance.collection('allStory').doc('${_auth.currentUser?.email}'+" "+currentTime.toString());
    final json = post.toJson();
    await docUser.set(json, SetOptions(merge: false));
    await docDataPost.set(json, SetOptions(merge: false));
  }

  Future updateAlbums(CreatePostModel post) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc('${_auth.currentUser?.email}').collection('story').doc('${widget.albumsId}');
    final docDataPost = FirebaseFirestore.instance.collection('allStory').doc('${widget.albumsId}');
    final json = post.toJson();
    await docUser.set(json, SetOptions(merge: false));
    await docDataPost.set(json, SetOptions(merge: false));
  }

  Widget SelectedPickImageButton(){
    return  ElevatedButton(
              onPressed: (() {
                _pickImage();
              }),
              child: Text('Pick Image'),
            );
  }

  Widget AddButtonImage(int index) {
    if(_pairImageTime.keys.toList().asMap().containsKey(index)) {
      if(_pairImageTime.length > 1) {
        try{
          _pairImageTime = Map.fromEntries(_pairImageTime.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
        } catch(e) {
          _pairImageTime = Map.fromEntries(_pairImageTime.entries.toList()..sort((a, b) => a.key.lastModifiedSync().compareTo(b.key.lastModifiedSync())));
        }
      }
      // _pairImageTime.removeWhere((key, value) => key == _pairImageTime.keys.elementAt(index),); // Remove Method
      try{
        return Image.network(_pairImageTime.keys.elementAt(index), loadingBuilder: (context, child, loadingProgress) {
                              if(loadingProgress == null) return child;
                                return  Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                            strokeWidth: 3, 
                                            color: Colors.amberAccent,
                                            backgroundColor: Colors.blueGrey,),
                                        );
                                      },
                              errorBuilder: (context, error, stackTrace) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.amberAccent,backgroundColor: Colors.blueGrey,)
                                  )
                                );
                              },
                            );
      }catch(e){
        return Image.file(_pairImageTime.keys.elementAt(index));
      }
    }
    else{
      return Container(
        decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey.shade100,),),
        child: Align(
              alignment: Alignment.center,
              child: IconButton(icon: const Icon(Icons.add_circle_outline,size: 30,),
                onPressed: (() {
                  // _singleImage();
                  _pickImage();
                }),
              )
            ),
        );
    }
  }

  Widget Carousel_Slider_image() {
    return  Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Center(
                child: CarouselSlider.builder(
                  carouselController: carouselController,
                  options: CarouselOptions(
                    height: 400,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {_currentIndex = index+1;setState(() {});},
                  ),
                  itemCount: _numImages,
                  itemBuilder:  (context, index, realIndex){
                    // return AddButtonImage(index);
                    return AddButtonImage(index);
                  },
                ),
              ),
            );
  }

  Widget Enter_Albums_Names(){
    return  SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Form(
                  key: _formKeyAlbums,
                  child: Align(
                    alignment: Alignment.center,
                    child: TextFormField(
                      enabled: enableText,
                      validator: MultiValidator([
                          RequiredValidator(errorText: 'Please Enter Album Name'),
                      ]),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: albumNames,
                      // keyboardType: TextInputType.text,
                      obscureText: false,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.black.withOpacity(0.8),),
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Album Names",
                        filled: true,
                        fillColor: Color(0xFFFFF2F2),
                        // counterText: '',
                      ),
                      maxLength: 30,
                    )
                  ),
                ),
              ),
            );
  }

  Widget Category_DropDown(){
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,  
        children: [

          // Text to choose
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Text(
              "Choose Category",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Drop Down Box
          SizedBox(
            height: 55,
            width: 180,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(width: 3, color: Color(0xFF3C84AB))
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(width: 3, color: Color(0xFF3C84AB))
                ),
                filled: true,
                fillColor: Color(0xFFDEFCF9),
              ),
              dropdownColor: Color(0xFFDEFCF9),
              value: dropdownCategory,
              onChanged: (String? value) {
                setState(() {
                  dropdownCategory = value!;
                });
              } , 
              items: items_category.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 15),));
              }).toList()
            ),
          ),
        ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF75A2EA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:const Color(0xFF75A2EA),
        title: const Text("CreatePost"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          }
        ),
        actions: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: _isConnected ? Text('$CreateOrUpdate') : Text(''),
              onPressed: () async {    
                _pressButtonCreate(widget.albumsId);      
              },
            ),
          )
        ],
      ),
      body: _isConnected ? SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[  
              
              // Carousel Slider Image Picker
              Carousel_Slider_image(),
        
              // Carousel Image Slider Index
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    "$_currentIndex/$_numImages",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
        
              // Enter the Album Names
              Enter_Albums_Names(),
        
              // Category_dropdown
              Category_DropDown(),

              // SelectedPickImageButton
              SelectedPickImageButton(),

            ],
          ),
        )
      ) 
      : const Center(
        child: Text('No internet connection.'),
      ),
    );
  }
}


// Test Widget not in class
Widget alertExceedtwenty(BuildContext context, String inputText){
  return AlertDialog(
          title: const Text('Error'),
          content: Text(inputText),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(10.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            )
          ],
        );
}

Widget InputRangeBox(TextEditingController numImages, int _numImages){
  return  Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),  // 20,20,20,0
            child: SizedBox(
              width: 200,
              height: 50,
              child: TextField(
                controller: numImages,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.red.withOpacity(0.8),),
                keyboardType: TextInputType.number,
                // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Number of Images(range 1-20)',
                  labelStyle: const TextStyle(
                    color: Colors.black
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: _numImages.toString(),
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,),
                                  borderRadius: BorderRadius.circular(50.0)
                  ),
                  focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50.0)
                  ),
                ),
              ),
            ),
          );
}