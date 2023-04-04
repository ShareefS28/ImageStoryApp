import 'package:flutter/material.dart';
import 'package:image_story_app/model/FeedPage/FeedDetailPage.dart';
import 'package:image_story_app/model/FeedPage/ProfileFeed.dart';

class FeedDetail extends StatefulWidget {
  const FeedDetail({Key? key}) : super(key: key);

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {

  @override
  void initState() {
    super.initState();
  }

  TextEditingController _searchquery = TextEditingController();

   final List<Tab> myTab = <Tab>[
    const Tab(icon: Icon(Icons.home),),
    const Tab(icon: Icon(Icons.person),),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTab.length,
      initialIndex: 0, 
      child: Scaffold(
        bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: Color(0xFF75A2EA),
            border: BorderDirectional(top: BorderSide(width: 1.0, color: Colors.white,))
          ),
          child: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[200],
            indicatorWeight: 3,
            tabs: myTab
          ),
        ),
        backgroundColor: Color(0xFF75A2EA),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Feedpage(),    
            ProfileFeed(),
          ],
      ),
    ),
  );
   
  }
}












// Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
//                       child: Container(
//                         width: double.infinity,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
//                                 child: Text(
//                                   'ProfilePageTest',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                         ),
//                       ),
//                     ),


// //HomeFeed
//                     Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
//                       child: Container(
//                         width: double.infinity,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 40.0,
//                                   child: TextFormField(
//                                     maxLines: 1,
//                                     //textAlignVertical: TextAlignVertical.bottom,
//                                     textInputAction: TextInputAction.search,
//                                     controller: _searchquery,
//                                     onFieldSubmitted: (_searchquery) {
//                                       print(_searchquery);
//                                     },
//                                     obscureText: false,
//                                     cursorColor: Colors.grey,
//                                     style: TextStyle(color: Colors.red.withOpacity(0.8),),
//                                     decoration: InputDecoration(
//                                       contentPadding: EdgeInsets.zero, //use this instead textAlignVertical
//                                       isDense: true,
//                                       hintText: 'Search',
//                                       enabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                           color: Colors.white,
//                                           width: 1,
//                                           ),
//                                         borderRadius: BorderRadius.circular(50.0),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                           color: Colors.white,
//                                           width: 1,
//                                           ),
//                                         borderRadius: BorderRadius.circular(50.0)
//                                         ),
//                                       prefixIcon: Container(
//                                         child: Icon(
//                                           Icons.search,
//                                           color: Colors.white,),
//                                         ),
//                                     ),
//                                   ),), 
//                                 ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   //AddbuttonIcon
//                                   Padding(
//                                     padding: EdgeInsetsDirectional.fromSTEB(13, 0, 5, 0),
//                                       child: InkWell(
//                                         child: Icon(
//                                           Icons.add_box_outlined,size: 30,
//                                           color: Colors.white,
//                                         ),
//                                         onTap: (){
//                                           //something here
//                                         },
//                                       ),
//                                     ),
//                                   //CategoryIcon
//                                   Padding(
//                                     padding: EdgeInsetsDirectional.fromSTEB(5, 0, 10, 0),
//                                     child: InkWell(
//                                       child: Icon(
//                                         Icons.category_outlined,
//                                         size: 30,
//                                         color: Colors.white,
//                                         ),
//                                       onTap: (){
//                                         //something here
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
