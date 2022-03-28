class Event{
  String imageEvent;
  String eventName;
  String content;
  String dateTimeUpdated;
  String dateTimeCreated;
  int id;
  int level;
  bool detected;
  String type;
  bool selected;

  Event({
    this.id,
    this.imageEvent,
    this.content,
    this.eventName,
    this.dateTimeUpdated,
    this.dateTimeCreated,
    this.detected,
    this.level,
    this.type,
    this.selected
  });

  factory Event.fromJson(dynamic json){
    return Event(
      id: json['id'] as int,
      imageEvent: '',
      content: json['vmsCameraId'] as String,
      eventName: json['text'] as String,
      dateTimeCreated: json['createdAt'] as String,
      dateTimeUpdated: json['updatedAt'] as String,
      detected: json['detected'] as bool,
      level: json['level'] as int,
      type: json['type'] as String,
      selected: false
    );
  }

  static List<Event> eventList(List eventList){
    return eventList.map((data){
      return Event.fromJson(data);
    }).toList();
  }
}