import 'dart:io';

import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  String message;
  OwnMessageCard({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Color(0xff2275ff),
            ),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 95),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
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
