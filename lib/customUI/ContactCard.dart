import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/contactCardModel.dart';

class ContactCard extends StatelessWidget {
  late ContactCardModel contactCardModel;
  ContactCard({required this.contactCardModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    NetworkImage(contactCardModel.profilePictureURL!),
              ),
              if (contactCardModel.isSelected == true)
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
          title: Text(
            contactCardModel.name!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          subtitle: Text(
            contactCardModel.status!,
            style: TextStyle(color: Colors.blue),
          ),
          trailing: Icon(
            CupertinoIcons.person_add_solid,
            color: Color(0xff4E5152),
            size: 25,
          ),
        ),
        Divider(
          thickness: 0.5,
        ),
      ],
    );
  }
}
