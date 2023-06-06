import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_story_app/model/PostCreate/CreatePost.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_story_app/model/HomePage/HomeDetail.dart';
import 'package:image_story_app/screens/CompleteProfile.dart';
import 'package:image_story_app/model/FeedPage/DataUserModel.dart';

class ProfileFeed extends StatefulWidget {
  const ProfileFeed({Key? key}) : super(key: key);

  @override
  State<ProfileFeed> createState() => _ProfileFeedState();
}

class _ProfileFeedState extends State<ProfileFeed> {
  
  bool _isConnected = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore docUser = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final storyContoller = ScrollController();
  CarouselController carouselController = CarouselController();

  var username = '';
  var image = '';
  int _numImages = 20;
  bool isUploaded = false;
  late QuerySnapshot<Map<String, dynamic>> docRef;
  List<int> _currentIndex = [];
  List<UserData> docData = [];
  bool hasMore = true;

  @override
  void initState(){
    super.initState();
    initConnectivity();
    getUser();
    getImage();
    fetchData(false);
    storyContoller.addListener(() {
      if( storyContoller.position.maxScrollExtent ==   storyContoller.position.pixels){
        fetchData(true);
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose(){
    storyContoller.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
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

  Widget viewImage() {
    return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(color: Color(0xFFEEEEEE), thickness: 1.0,),
            padding: const EdgeInsets.all(3),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: docData.length+1,
            itemBuilder: (context, index) {
              if(index < docData.length){
                // data["Image DateTime"]! EXIF data no miliseconds
                final albumsName = docData[index].AlbumsNames;
                final imagesFileAlbums = Map.fromEntries(docData[index].ImagesFile.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
                return  Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF434242),
                        blurRadius: 6.5,
                        offset: Offset(0, 3.0),
                      )
                    ]
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF75A2EA),
                      border: Border.all(width: 1.0,color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                      child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(4, 8, 4, 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Arrow Left
                                        // Align(
                                        //   alignment: Alignment.centerLeft,
                                        //   child: IconButton(
                                        //     onPressed: () {
                                        //       // Use the controller to change the current page
                                        //       carouselController.previousPage(duration: const Duration(milliseconds: 100));
                                        //     },
                                        //     icon: Icon(Icons.arrow_back),
                                        //   ),
                                        // ),
                                        // Show Image
                                        ClipRRect(
                                          // borderRadius: BorderRadius.circular(15.0),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: MediaQuery.of(context).size.width*0.9, // 350 is suitable
                                            width: MediaQuery.of(context).size.width*0.9,  // 350 is suitable
                                            child:CarouselSlider.builder(
                                            carouselController: carouselController,
                                            options: CarouselOptions(
                                              initialPage: 0,
                                              height: 350,
                                              scrollPhysics: const BouncingScrollPhysics(),
                                              viewportFraction: 1.0,
                                              enableInfiniteScroll: false,
                                              enlargeCenterPage: true,
                                              scrollDirection: Axis.horizontal,
                                              onPageChanged: (indexn, reason) {
                                                _currentIndex[index] = indexn+1; 
                                                setState(() { });
                                              },
                                            ),
                                            itemCount: imagesFileAlbums.length,
                                            itemBuilder: (context, indexCarousel, realIndex){
                                              return Image.network("${imagesFileAlbums.keys.elementAt(indexCarousel)}",
                                                        loadingBuilder: (context, child, loadingProgress) {
                                                          if(loadingProgress == null) return child;
                                                          return Center(
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
                                              },
                                            ),
                                          ),
                                        ),
                                        // Arrow Right
                                        // Align(
                                        //   alignment: Alignment.centerRight,
                                        //   child: IconButton(
                                        //     onPressed: () {
                                        //       // Use the controller to change the current page
                                        //       carouselController.nextPage(duration: const Duration(milliseconds: 100));
                                        //     },
                                        //     icon: const Icon(Icons.arrow_forward),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    // Carousel Image Slider Index
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Align(
                                        alignment: AlignmentDirectional.center,
                                        child: Text(
                                          "${_currentIndex[index]}/${imagesFileAlbums.length}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                
                                      // Show albums names
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Alubums Names
                                          Flexible(
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                child: Text(
                                                  '$albumsName',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: const TextStyle(fontSize: 20 , fontWeight: FontWeight.bold, color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Button for Edit Story
                                          SizedBox(
                                            width: 90,
                                            height: 25,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Color(0xFF434242)),
                                                foregroundColor: MaterialStateProperty.all(Colors.white),
                                                shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                        side: const BorderSide(
                                                        color: Color(0xFFF3EFE0),
                                                        width: 1.5,
                                                    ),
                                                  ),
                                                )
                                              ),
                                              child: const Text('Edit', style: TextStyle(fontSize: 15, color: Colors.white),),
                                              onPressed: () async{
                                                showCustomDialog(index);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),      
                        ),
                    );
              }
              else{
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: hasMore ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.amberAccent,backgroundColor: Colors.blueGrey,) : const Text("No More Data to Load!"),
                  )
                );
              }
            },
          );
  }

  Widget tapbarTopaction(){
    return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
              child: InkWell(
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white
                ),
                onTap:() async {
                  // add create image story
                  final refreshAfterPage = await Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => CreatePost()));
                  if(refreshAfterPage == null){
                    refresh();
                  } 
                  else if (refreshAfterPage){
                    refresh();
                  }
                  else{
                    refresh();
                  }
                },
              ),  
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
              child: InkWell(
                child: const Icon(
                  Icons.logout_outlined,
                  size: 30,
                  color: Colors.white),
                  onTap: (){
                    _auth.signOut().then((value) {
                    Navigator.pushReplacement(context, 
                    MaterialPageRoute(builder: (context){
                      return HomePageDetail();
                    }));
                  }
                );
              },
            ),
          ),
        ],
      );
}

  Widget editProfileButton(){
    return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 18, 15, 20),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color(0xFF434242)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                          color: Color(0xFFF3EFE0),
                          width: 1.5,
                      ),
                    ),
                  )
                ),
                child: Text('Edit Profile'.toUpperCase()),
                onPressed: () async {
                  final refreshAfterPage = await Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => const CompleteProfile()),);
                  if(refreshAfterPage == null){
                    refresh();
                  }
                  else if(refreshAfterPage){
                    refresh();
                  }
                  else{
                    refresh();
                  }
                },
              )
            )
          );
  }

  Widget tabbarTopName(){
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: const [
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        child: Icon(
          Icons.person_rounded,
          size: 30,
          color: Colors.white
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        child: Text(
          "My Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white) // change Text to "Profile"
        )
      ),
    ],);
  }

  Widget profileImage(var image,  var username){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 15, 1),
            child: Container(
              width: 120,
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.network("${image}", fit:BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
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
                  return Image.network("https://firebasestorage.googleapis.com/v0/b/imagestoryapp.appspot.com/o/ImageStart%2Fuser_avatar.png?alt=media&token=0ec1a06f-1032-4b9b-baec-a5a54e4cc82e");
                },
              ) 
            ),
          ),
    
          Flexible(
            child: Align( 
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 15, 0),
                child: Text(
                  'My Name Is: '+username,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              )
            ),
          ],
        ),
      );
  }

  void showCustomDialog(int index){
    showDialog(
      barrierDismissible: true,
      context: context, 
      builder: (context){
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child:  Text('Select An Options',
                  style: TextStyle(fontSize: 20),),
              ),

              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                       style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFF434242)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                color: Color(0xFFF3EFE0),
                                width: 1.5,
                            ),
                          ),
                        )
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 10, color: Colors.white),),
                      onPressed: () async {
                        Navigator.pop(context);
                        final refreshAfterPage = await Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => CreatePost(albumsId: docData[index].albumsId,)),);
                        if(refreshAfterPage == null){
                          refresh();
                        }
                        else if(refreshAfterPage){
                          refresh();
                        }
                        else{
                          refresh();
                        }
                      },
                    ),
                    
                    const SizedBox(width: 50,),

                    ElevatedButton(
                      style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFFEB455F)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                           RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                               side: const BorderSide(
                               color: Color(0xFFF3EFE0),
                               width: 1.5,
                            ),
                          ),
                        )
                      ),
                      child: const Text('Delete', style: TextStyle(fontSize: 10, color: Colors.white),),
                      onPressed: () async {
                        showDialog(
                          context: context, 
                          builder: (context){
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                    child:  Text('Are you sure to delete this Albums ?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),),
                                  ),

                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Color(0xFF1F8A70)),
                                            foregroundColor: MaterialStateProperty.all(Colors.white),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                    side: const BorderSide(
                                                    color: Color(0xFFF3EFE0),
                                                    width: 1.5,
                                                ),
                                              ),
                                            )
                                          ),
                                          child: const Text('Yes', style: TextStyle(fontSize: 10, color: Colors.white),),
                                          onPressed: () async {
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
                                            for(var item in docData[index].ImagesFile.keys){
                                              await storage.refFromURL(item).delete();
                                            }
                                            await docUser.collection('allStory').doc(docData[index].albumsId).delete();
                                            await docUser.collection('Users').doc('${_auth.currentUser?.email}').collection('story').doc(docData[index].albumsId)
                                            .delete().then((value) {
                                            setState(() {isUploaded = false; Navigator.pop(context);});
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              return refresh();
                                            });
                                          },
                                        ),

                                        const SizedBox(width: 10,),

                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Color(0xFF434242)),
                                            foregroundColor: MaterialStateProperty.all(Colors.white),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                    side: const BorderSide(
                                                    color: Color(0xFFF3EFE0),
                                                    width: 1.5,
                                                ),
                                              ),
                                            )
                                          ),
                                          child: const Text('No', style: TextStyle(fontSize: 10, color: Colors.white),),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ]
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      },
                    ),
                  ],
                ),
              ),
            ]),
        );
      }
    );
  }

  Future<void> fetchData(bool next) async {
    int limitload = 5;
    List<int> tempIndex = [];

    void hasMoreto(){
      if(docRef.docs.isEmpty) {
        setState(() {
          hasMore = false;
        });
      }
    }

    if(!next){
      docRef = await docUser.collection('Users').doc('${_auth.currentUser?.email}').collection('story').orderBy('CreateAt', descending: true).limit(limitload).get();
      hasMoreto();
    }
    else{
      if(docRef.docs.isNotEmpty){
        final lastVisible = docRef.docs[docRef.docs.length-1];
        docRef = await docUser.collection('Users').doc('${_auth.currentUser?.email}').collection('story').orderBy('CreateAt', descending: true).startAfterDocument(lastVisible).limit(limitload).get();
        hasMoreto();
      }
    }
    setState(() {
      docData.addAll(docRef.docs.map((e) => UserData.fromSnapshot(e)).toList());
      if(!next){
        _currentIndex = List.generate(docData.length, (index) => 1); 
      }
      else if(next && docRef.docs.isNotEmpty){
        tempIndex = List.generate(docRef.docs.length, (index) => 1);
        _currentIndex.addAll(tempIndex);
      }
    });
  }

  Future getUser() async {
    String? _name;
    final document = await docUser.collection('Users').doc('${_auth.currentUser?.email}').get()
    .then((value) {
      setState(() {
        _name = value['name'].toString();
        username = '${_name}';
      });
      }
    );
  }

  Future getImage() async{
    String? image_url;
    final document = await docUser.collection('Users').doc('${_auth.currentUser?.email}').get()
    .then((value) {
      setState(() {
        image_url = value['profileimage'].toString();
        image = '${image_url}';
      });
      }
    );
  }

  Future refresh() async {
    setState(() {
      docData.clear();
      image = '';
      username = '';
    });
    fetchData(false);
    getUser();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return const Center(
        child: Text('No internet connection.'),
      );
    }
    else{
      return Scaffold(
        backgroundColor: const Color(0xFF75A2EA),
        body: SafeArea(
          child: RefreshIndicator(
            strokeWidth: 3, 
            backgroundColor: Colors.blueGrey,
            color: Colors.amberAccent,
            onRefresh: () async {
              return refresh();
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Tabbar
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    child: Material(
                      elevation: 4.0,
                      // borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: Container(
                        height: 45.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF75A2EA),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            tabbarTopName(),
                            tapbarTopaction(),
                        ],
                                      ),
                      ),
                    ),
                ),
          
                // Main Page
                Expanded(
                  child: SingleChildScrollView(
                    controller: storyContoller,
                    physics: const ScrollPhysics(),
                    // physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(3),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        profileImage(image, username),
                        editProfileButton(),  
                        viewImage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}