import "package:flutter/material.dart";

class SliverAppbarComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'test',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(50.0),
                child: Image.asset('assets/images/AC Solutions Logo black.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
