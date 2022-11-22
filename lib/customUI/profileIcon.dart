import 'package:flutter/material.dart';
import '../Models/contactCardModel.dart';

class ProfileIcon extends StatefulWidget {
  late ContactCardModel contacts;
  ProfileIcon({required this.contacts, Key? key}) : super(key: key);

  @override
  _ProfileIconState createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 8,
        right: 10,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: widget.contacts.profilePictureURL != null
                    ? NetworkImage(widget.contacts.profilePictureURL!)
                        as ImageProvider
                    : AssetImage('images/myImage.jpeg'),
              ),
              CircleAvatar(
                radius: 11,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(widget.contacts.name!.length <= 8
              ? widget.contacts.name!
              : '${widget.contacts.name!.substring(0, 5)}...'),
        ],
      ),
    );
  }
}
