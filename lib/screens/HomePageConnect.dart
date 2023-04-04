import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../model/HomePage/HomeDetail.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context,snapshot){
        if(snapshot.hasError){
          return Scaffold(appBar: AppBar(title: Text('error'),),
          body: Center(
            child: Text('${snapshot.error}'),)
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
          return HomePageDetail();
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),),
        );
      }
    );
  }
}