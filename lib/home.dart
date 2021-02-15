import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'router.dart' as router;
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade800,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FabCircularMenu(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                size: 35,
              ),
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                router.HOME,
                //arguments: ScreenArguments(this.name, this.pageName,
                // this.codeFilePath, this.codeGithubPath),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 35,
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                router.UPLOAD_IMAGE_FIR_STORAGE,
                //arguments: ScreenArguments(this.name, this.pageName,
                // this.codeFilePath, this.codeGithubPath),
              ).then((value) => setState(() {})),
            ),
            IconButton(
              icon: Icon(
                Icons.photo_album,
                size: 35,
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                router.LIST_IMAGES,
                //arguments: ScreenArguments(this.name, this.pageName,
                // this.codeFilePath, this.codeGithubPath),
              ),
            ),
          ],
          fabSize: 60,
          ringDiameter: 250,
          ringWidth: 45,
          ringColor: Colors.white70,
          fabColor: Colors.white,
          fabOpenIcon: Icon(
            Icons.crop_square_rounded,
            color: Colors.blue[600],
            size: 50.0,
          ),
        ),
        body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    int _selectedIdx;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            Colors.blue[800],
            Colors.blue[700],
            Colors.blue[600],
            Colors.blue[400],
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Liste documents"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {});
              }),
        ),
        //Ensure to have a scrollable view, to avoid renderflex overflow
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(children: <Widget>[
            Expanded(
              child: FutureBuilder(
                future: getDocuments(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            contentPadding: EdgeInsets.all(8.0),
                            title:
                                Text(snapshot.data.docs[index].data()["name"]),
                            leading: Icon(Icons.picture_as_pdf),
                            selected: index == _selectedIdx,
                          );
                        });
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return Text("No data");
                  }
                  return CircularProgressIndicator();
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<QuerySnapshot> getDocuments() {
    return FirebaseFirestore.instance
        .collection("images")
        .orderBy('timestamp', descending: true)
        .get();
  }
}
