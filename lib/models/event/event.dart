class Event {
  String id;
  String startTime;
  String fileName;
  String videoViewUrl;
  String imageViewUrl;
  String videoDownloadUrl;
  String endTime;

  Event({
    this.id,
    this.startTime,
    this.fileName,
    this.videoViewUrl,
    this.imageViewUrl,
    this.videoDownloadUrl,
    this.endTime,
  });

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startTime = json['startTime'];
    fileName = json['fileName'];
    videoViewUrl = json['videoViewUrl'];
    imageViewUrl = json['imageViewUrl'];
    videoDownloadUrl = json['videoDownloadUrl'];
    endTime = json['endTime'];
  }
}
