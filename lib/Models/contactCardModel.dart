class ContactCardModel {
  String? name;
  String? profilePictureURL;
  String? status;
  bool isSelected = false;
  String? uid;

  ContactCardModel({
    required this.name,
    required this.profilePictureURL,
    required this.status,
    this.isSelected = false,
    this.uid,
  });
}
