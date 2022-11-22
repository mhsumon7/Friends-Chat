import 'package:flutter/material.dart';

class OthersMessageCard extends StatelessWidget {
  String message;
  OthersMessageCard({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Color(0xffF0F0F0),
            ),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 95),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              child: Text(
                message,
                style: TextStyle(
                  color: Color(0xff4E5152),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: 5,
          // ),
          // Text(
          //   'Yesterday, 11:25',
          //   style: TextStyle(
          //     color: Color(0xff4E5152),
          //   ),
          // ),
        ],
      ),
    );
  }
}
