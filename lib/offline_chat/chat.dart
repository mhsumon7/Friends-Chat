import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class Chat extends StatefulWidget {
  Device connected_device;
  NearbyService nearbyService;
  var chat_state;

  Chat({required this.connected_device, required this.nearbyService});

  @override
  State<StatefulWidget> createState() => _Chat();
}

class _Chat extends State<Chat> {
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  List<ChatMessage> messages = [];
  final myController = TextEditingController();
  void addMessgeToList(ChatMessage obj) {
    setState(() {
      messages.insert(0, obj);
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    receivedDataSubscription.cancel();
  }

  void init() {
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
      var obj =
          ChatMessage(messageContent: data["message"], messageType: "receiver");
      addMessgeToList(obj);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        this.widget.connected_device.deviceName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text(
                        "connected",
                        style: TextStyle(color: Colors.amber, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 12,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].messageType == "receiver"
                            ? Colors.grey.shade200
                            : Colors.green[300]),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        messages[index].messageContent,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 10, bottom: 10, top: 10, right: 18),
                    height: 100,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextField(
                            minLines: 1,
                            maxLines: 5,
                            enableSuggestions: true,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                                hintTextDirection: TextDirection.ltr,
                                hintText: "Type your message here ...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12))),
                            controller: myController,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            if (this.widget.connected_device.state ==
                                SessionState.notConnected) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("disconnected"),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            this.widget.nearbyService.sendMessage(
                                this.widget.connected_device.deviceId,
                                myController.text);
                            var obj = ChatMessage(
                                messageContent: myController.text,
                                messageType: "sender");

                            addMessgeToList(obj);
                            myController.text = "";
                          },
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 23,
                            textDirection: TextDirection.ltr,
                          ),
                          backgroundColor: Colors.blue,
                          elevation: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}
