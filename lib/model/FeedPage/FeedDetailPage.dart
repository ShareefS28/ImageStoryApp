import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_story_app/model/FeedPage/DataUserModel.dart';
import 'package:image_story_app/model/User.dart';
import 'package:image_story_app/model/PostCreate/CreatePost.dart';


class Feedpage extends StatefulWidget {
  const Feedpage({Key? key}) : super(key: key);

  @override
  State<Feedpage> createState() => _FeedpageState();
}

class _FeedpageState extends State<Feedpage> {

  bool _isConnected = true;
  
  TextEditingController _searchquery = TextEditingController();
  final FirebaseFirestore docUser = FirebaseFirestore.instance;
  CarouselController carouselController = CarouselController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storyContoller = ScrollController();
  final listviewController = ScrollController();


  late QuerySnapshot<Map<String, dynamic>> eachData;
  late QuerySnapshot<Map<String, dynamic>> docRef;
  List<int> _currentIndex = [];
  List<FeedData> docData = [];
  List<UserModel> docId = [];
  int lazyLoadnum = 0; 
  bool hasMore = true;

  bool checkbox1 = false;
  bool checkbox2 = false;
  Map<String, bool> boxstate = {'None':false, 'Fun':false, 'Cozy&Relax':false, 'Reminiscene':false,};
  List<String> _queryboxstate = [];
  List<String> _previousquery = [];

  @override
  void initState(){
    super.initState();
    initConnectivity();
    fetchData(false);
    storyContoller.addListener(() {
      if(storyContoller.position.maxScrollExtent == storyContoller.position.pixels){
        fetchData(true);
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted)return;
    super.setState(fn);
  }

  @override
  void dispose(){
    storyContoller.dispose();
    super.dispose();
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
    if(_queryboxstate.isEmpty){
      if(!next){
        docRef = await docUser.collection("allStory").orderBy("CreateAt", descending: true).limit(limitload).get();
        hasMoreto();
      }
      else{
        if(docRef.docs.isNotEmpty){
          final lastVisible = docRef.docs[docRef.docs.length-1]; // Or final lastVisible = docRef.docs.last;
          docRef = await docUser.collection('allStory').orderBy('CreateAt', descending: true).startAfterDocument(lastVisible).limit(limitload).get();
          hasMoreto();
        } 
      }
    }
    else{
      if(!next){
        docRef = await docUser.collection("allStory").where("Category", whereIn: _queryboxstate).orderBy("CreateAt", descending: true).limit(limitload).get();
        hasMoreto();
      }  
      else{
        if(docRef.docs.isNotEmpty){
          final lastVisible = docRef.docs[docRef.docs.length-1]; // Or final lastVisible = docRef.docs.last;
          docRef = await docUser.collection("allStory").where("Category", whereIn: _queryboxstate).orderBy("CreateAt", descending: true).startAfterDocument(lastVisible).limit(limitload).get();
          hasMoreto();
        } 
      }
    }
    setState(() {
      docData.addAll(docRef.docs.map((doc) => FeedData.fromSnapshot(doc)).toList());
      if(!next){
        _currentIndex = List.generate(docData.length, (index) => 1);
      }
      else if(next && docRef.docs.isNotEmpty){
        tempIndex = List.generate(docRef.docs.length, (index) => 1);
        _currentIndex.addAll(tempIndex);
      }
    });
  }

  Future refresh() async {
    setState(() {
      docData.clear();
    });
    await fetchData(false);
  }

  Widget buildCheckbox(){
    return StatefulBuilder(builder: (context, mynewState) {
      return SizedBox(
        height: MediaQuery.of(context).size.height*0.35,
        child: Center(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            shrinkWrap: true,
            itemCount: boxstate.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                activeColor: const Color(0xFF434242),
                title: Text(
                  boxstate.keys.elementAt(index),
                  style: const TextStyle(fontSize: 18),
                ),
                value: boxstate.values.elementAt(index), 
                onChanged: (value) {
                  mynewState(() {
                    boxstate[boxstate.keys.elementAt(index)] = value!;
                    if(boxstate[boxstate.keys.elementAt(index)] == true){
                      _queryboxstate.add(boxstate.keys.elementAt(index));
                    }
                    else{
                      _queryboxstate.remove(boxstate.keys.elementAt(index));
                    }
                  },);
                },
              );
            },),
        ),
      );
    });
  }

  Widget topAppbar(){
    return Material(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: Container(
          width: double.infinity,
          height: 45.0,
          decoration: BoxDecoration(
            color: const Color(0xFF75A2EA),
            border: Border.all(color: Colors.white), 
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: const [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Icon(
                      Icons.home,
                      size: 30,
                      color: Colors.white
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Text(
                      "Feed",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white) // change Text to "Profile"
                    )
                  ),
                ],),
                           
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  //AddbuttonIcon
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(13, 0, 5, 0),
                      child: InkWell(
                        child: const Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () async {
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
                  //CategoryIcon
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 10, 0),
                    child: InkWell(
                      child: const Icon(
                        Icons.category_outlined,
                        size: 30,
                        color: Colors.white,
                        ),
                      onTap: () async {
                        // Bottom Sheet Category
                        _previousquery = List<String>.from(_queryboxstate);
                        await showModalBottomSheet(
                          backgroundColor: Colors.grey[100],
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )
                          ),
                          builder: (context) {
                            return GestureDetector(
                              child: buildCheckbox(),
                              onTap: () {
                                Navigator.of(context).pop(_queryboxstate);
                              },
                            );
                          },
                        );
                        if(!const ListEquality().equals(_previousquery, _queryboxstate)){
                          refresh();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget viewImage() {
    return ListView.separated(
            controller: listviewController,
            separatorBuilder: (BuildContext context, int index) => const Divider(color: Color(0xFFEEEEEE), thickness: 1.0,),
            padding: const EdgeInsets.all(3),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: docData.length+1,
            itemBuilder: (context, index) {
              // data["Image DateTime"]! EXIF data no miliseconds
              if(index < docData.length){       
                final albumsName = docData[index].AlbumsNames;
                final imagesFileAlbums = Map.fromEntries(docData[index].ImagesFile.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
                final whoseCreated = docData[index].CreateBy;
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
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
     
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  '${albumsName}',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: const TextStyle(fontSize: 20 , fontWeight: FontWeight.bold, color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          Flexible(
                                            child: Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  'Created By: ${whoseCreated}',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                  maxLines: 1,
                                                  style: const TextStyle(fontSize: 15 , fontWeight: FontWeight.bold, color: Colors.black),
                                                ),
                                              ),
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
                    child: hasMore ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.amberAccent,backgroundColor: Colors.blueGrey) : const Text("No More Data to Load!"),
                  )
                );
              }
            },
          );
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
          backgroundColor: Color(0xFF75A2EA),
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
                topAppbar(),
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
