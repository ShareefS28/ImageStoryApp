import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData{
  String? CreateBy;
  String? albumsId;
  String? AlbumsNames;
  String? Category;
  DateTime? CreateAt;
  Map<String, dynamic> ImagesFile;

  UserData({
    this.CreateBy,
    this.albumsId,
    this.AlbumsNames,
    this.Category,
    this.CreateAt,
    required this.ImagesFile,
  });

  factory UserData.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document,) {
    final data = document.data();
    return  UserData(
      albumsId: document.id,
      CreateBy: document["CreateBy"],
      AlbumsNames: data["AlbumsNames"],
      Category: data["Category"],
      CreateAt: data["CreateAt"].toDate(),
      ImagesFile: data["ImagesFile"], 
    );
  }

}
  

class FeedData{
  String? CreateBy;
  String? albumsId;
  String? AlbumsNames;
  String? Category;
  DateTime? CreateAt;
  Map<String, dynamic> ImagesFile;

  FeedData({
    this.CreateBy,
    this.albumsId,
    this.AlbumsNames,
    this.Category,
    this.CreateAt,
    required this.ImagesFile,
  });

  factory FeedData.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return  FeedData(
      albumsId: document.id,
      CreateBy: data["CreateBy"],
      AlbumsNames: data["AlbumsNames"],
      Category: data["Category"],
      CreateAt: data["CreateAt"].toDate(),
      ImagesFile: data["ImagesFile"], 
    );
  }

}