class Notification {
  int id;
  String title;
  DateTime time;
  String description;
  String device;
  String eventType;
  String eventLevel;
  String mediaLink;
  bool favorite;

  Notification(
      {this.id,
      this.title,
      this.time,
      this.eventType,
      this.description,
      this.device,
      this.eventLevel,
      this.mediaLink,
      this.favorite});

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    time = json['time'];
    eventType = json['eventType'];
    description = json['description'];
    device = json['device'];
    eventLevel = json['eventLevel'];
    mediaLink = json['mediaLink'];
    favorite = json['favorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['time'] = this.time;
    data['eventType'] = this.eventType;
    data['description'] = this.description;
    data['device'] = this.device;
    data['eventLevel'] = this.eventLevel;
    data['mediaLink'] = this.mediaLink;
    data['favorite'] = this.favorite;
    return data;
  }
}
