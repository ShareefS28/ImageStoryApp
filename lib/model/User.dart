import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as pathpack;

class UserModel{
  String? id;
  String? name;
  int? age;
  String? gender;
  String? profileimage;

  UserModel({
    this.id,
    this.name,
    this.age,
    this.gender,
    this.profileimage,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'profileimage': profileimage,
  };

  factory UserModel.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return UserModel(
      id: document.id,
      name: data["name"],
      age: data["age"],
      gender: data["gender"],
      profileimage: data["profileimage"],
    );
  }

}

class UserImageModel{

  final FirebaseStorage storage = FirebaseStorage.instance;
  String? url;

  Future<void> uploadFile(File image, String _authnames) async {
    File file;
    file = File(image.path);
    final uploaderef = storage.ref().child('${_authnames}/profileimage/${pathpack.basename(image.path)}');
    try {
      await uploaderef.putFile(file);
      url = await uploaderef.getDownloadURL();
    } on FirebaseException catch(e){
      print("Error at 'User.dart' : "+e.toString());
    };
  }
}