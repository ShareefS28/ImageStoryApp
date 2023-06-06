import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as pathpack;

class CreatePostModel{
  String? uid;
  String? sendTo;
  String? createby;
  String? albumsnames;
  String? category;
  DateTime? timecreate;
  Map<String, DateTime> image;

  CreatePostModel({
    this.uid,
    this.createby,
    this.albumsnames,
    this.category,
    this.timecreate,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
    "UID" : uid,
    "CreateBy" : createby,
    "AlbumsNames" : albumsnames,
    "Category" : category,
    "CreateAt" : timecreate,
    "ImagesFile" : image, 
  };
}

class CreatePostModelPull{
  String? uid;
  String? CreateBy;
  String? albumsId;
  String? albumsNames;
  String? Category;
  DateTime? CreateAt;
  Map<dynamic, dynamic> ImagesFile;

  CreatePostModelPull({
    this.uid,
    this.CreateBy,
    this.albumsId,
    this.albumsNames,
    this.Category,
    this.CreateAt,
    required this.ImagesFile,
  });

  factory CreatePostModelPull.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, String uid) {
    return CreatePostModelPull(
      uid: uid,
      albumsId: document.id,
      CreateBy: document["CreateBy"],
      albumsNames: document["AlbumsNames"],
      Category: document["Category"],
      CreateAt: document["CreateAt"].toDate(),
      ImagesFile: document["ImagesFile"], 
    );
  }
}

class StorageCreatePost{

  final FirebaseStorage storage = FirebaseStorage.instance;
  String? url;
  DateTime? timestamp;

  Future<void> uploadFile(File filepath, DateTime filetime, String _authnames, String storynames) async {
    File file;
    file = File(filepath.path);
    final uploaderef = await storage.ref().child('$_authnames/story/$storynames/${pathpack.basename(file.path)}');
    try {
      await uploaderef.putFile(file);
      url = await uploaderef.getDownloadURL();
      timestamp = filetime;
    } on FirebaseException catch(e){
      print("Error at 'CreatePostModel.dart' : "+e.toString());
    };
  }
}