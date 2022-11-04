class Chat {
  UserData? userData;
  List<ChatData>? chatData;

  Chat({this.userData, this.chatData});

  Chat.fromJson(Map<String, dynamic> json) {
    userData =
        json['userData'] != null ? UserData.fromJson(json['userData']) : null;
    if (json['chatData'] != null) {
      chatData = <ChatData>[];
      json['chatData'].forEach((v) {
        chatData!.add(ChatData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    if (chatData != null) {
      data['chatData'] = chatData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserData {
  String? displayName;
  String? photo;
  String? username;
  String? email;
  String? country;
  String? city;

  UserData(
      {this.displayName,
      this.photo,
      this.username,
      this.email,
      this.country,
      this.city});

  UserData.fromJson(Map<String, dynamic> json) {
    displayName = json['display_name'];
    photo = json['photo'];
    username = json['username'];
    email = json['email'];
    country = json['country'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['display_name'] = displayName;
    data['photo'] = photo;
    data['username'] = username;
    data['email'] = email;
    data['country'] = country;
    data['city'] = city;
    return data;
  }
}

class ChatData {
  int? id;
  dynamic messageFrom;
  dynamic messageTo;
  String? message;
  dynamic isReaded;
  String? createdAt;
  String? updatedAt;

  ChatData(
      {this.id,
      this.messageFrom,
      this.messageTo,
      this.message,
      this.isReaded,
      this.createdAt,
      this.updatedAt});

  ChatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageFrom = json['messageFrom'];
    messageTo = json['messageTo'];
    message = json['message'];
    isReaded = json['isReaded'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['messageFrom'] = messageFrom;
    data['messageTo'] = messageTo;
    data['message'] = message;
    data['isReaded'] = isReaded;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
