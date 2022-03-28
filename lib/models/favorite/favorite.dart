import 'package:boilerplate/models/camera/camera.dart';

class Favorite {
  int id;
  String name;
  List<Camera> listCamera;

  Favorite({
    this.id,
    this.name,
    this.listCamera,
  });

  Favorite.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    listCamera = json['listCamera']
        .map((item) => Camera.fromMap(item))
        .toList()
        .cast<Camera>();
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['listCamera'] =
        this.listCamera?.map((item) => item.toMapWithId())?.toList();
    return data;
  }
}
