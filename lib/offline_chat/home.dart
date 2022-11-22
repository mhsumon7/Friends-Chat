import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final List<MenuData> menu = [
    MenuData(
      icon: Icons.bluetooth,
      title: "SEND",
    ),
    MenuData(
      icon: Icons.bluetooth_connected,
      title: "RECIVE",
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 6,
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: menu.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 2.5,
                  crossAxisCount: 1,
                  crossAxisSpacing: 0.5,
                  mainAxisSpacing: 1.0),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.blue,
                  elevation: 20,
                  margin: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.blue),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, menu[index].title.toLowerCase()),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          menu[index].icon,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          menu[index].title == "SEND" ? "SEND" : "RECIVE",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MenuData {
  late IconData icon;
  late String title;
  MenuData({
    required this.icon,
    required this.title,
  });
}
