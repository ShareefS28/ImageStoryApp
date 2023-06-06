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