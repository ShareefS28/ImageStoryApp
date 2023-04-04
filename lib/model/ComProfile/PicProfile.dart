import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageProfile extends StatefulWidget {
  const ImageProfile({Key? key}) : super(key: key);

  @override
  State<ImageProfile> createState() => _ImageProfileState();
}

class _ImageProfileState extends State<ImageProfile> {

  double widthsize = 120;
  double heightsize = 150;

  File? image;

  Future PickImage(ImageSource source) async{
    try{
      final image = await ImagePicker().pickImage(source: source);
      if(image == null) return; 
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    }on PlatformException catch (e){
      print('failed to pick image: ${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 120,
      height: 150,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: image != null ? Image.file(image!,fit: BoxFit.cover,) : Image.asset('assets/images/user_avatar.png'),
          ),
          InkWell(
            child: Align(
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
    );
  } 




  //Widget Function BottomSheet
  Widget bottomsheet(){
    return Container(
      height: 200,
      color: Colors.amber,
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
                children: [
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
                children: [
                  Icon(Icons.camera_alt_outlined,),
                  Text('Pick Camera',),
                ],
              ),
            ),
            onPressed: () => PickImage(ImageSource.camera),
          ),
        ],),
      ),
    );
  }
//End class  
}





















  // Widget build(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.only(top: 50),
  //     width: widthsize,
  //     height: heightsize,
  //     child: Stack(
  //       children: [
  //         Container(
  //           width: widthsize,
  //           height: heightsize,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //           ),
  //           child: CircleAvatar(
  //             backgroundColor: Colors.transparent,
  //             child: image != null ? Image.file(image!,fit: BoxFit.cover,) : Image.asset('assets/images/user_avatar.png'),
  //           ),
  //         ),



            // ElevatedButton(
            //   child: Wrap(
            //     children: <Widget>[
            //       // Icon(Icons.image_outlined, size: 24),
            //       // Text('Pick Camera')
            //     ],),






      // child: Column(
      //   children: [
      //     Image.asset(
      //       'assets/images/user_avatar.png'
      //     ),
      //   ]
      // ),






// Widget imageprofile(){
//    return Container(
//     width: 120,
//     height: 150,
//     clipBehavior: Clip.antiAlias,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//     ),
//     child: Image.asset(
//       'assets/images/user_avatar.png'
//     ),
//   );
// }







// Widget imageprofile(){
//    return Container(
//     width: 120,
//     height: 150,
//     //clipBehavior: Clip.antiAlias,
//     child: CircleAvatar(
//       backgroundColor: Colors.transparent,
//       radius: 30,
//       child: CircleAvatar(
//         radius: 50,
//         backgroundImage:  AssetImage(
//         'assets/images/user_avatar.png'),
//         ),
//       ),
//   );
// }



// Padding(
//             padding: EdgeInsetsDirectional.fromSTEB(0, , 0, 0),
//             child: IconButton(
//               icon: Icon(
//                 Icons.camera_alt_rounded,
//                 size: 30,
//               ),
//               onPressed: (){

//               },
//             ),
//           ),




  // return Container(
  //     width: 120,
  //     height: 150,
  //     clipBehavior: Clip.antiAlias,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //     ),
  //     child: Column(
  //       children: [
  //         Image.asset(
  //           'assets/images/user_avatar.png'
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.camera_alt_rounded,),
  //           onPressed: (){
              
  //           },),
  //       ]
  //     ),
  //   );
  // }
      



// @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 120,
//       height: 150,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//       ),
//       child: Column(
//         children: [
//           Image.asset(
//             'assets/images/user_avatar.png'
//           ),
//           IconButton(
//             icon: Icon(Icons.camera_alt_rounded,),
//             onPressed: (){
              
//             },
//           ),
//         ]
//       ),
//     );
//   }