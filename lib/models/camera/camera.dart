import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class Camera {
  String id;
  String name;
  int gatewayId;
  int position;
  String status;
  String function;
  String controllable;
  GlobalKey globalKey;
  VlcPlayerController controller;
  List<String> links;

  Camera({
    this.id,
    this.name,
    this.gatewayId,
    this.position,
    this.status,
    this.function,
    this.controllable,
    this.links,
  }) {
    globalKey = GlobalKey();
  }

  Camera.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gatewayId = json['gatewayId'];
    position = json['position'];
    status = json['status'];
    function = json['function'];
    controllable = json['controllable'];
    links = List<String>.from(json['links'] ?? []);
    globalKey = GlobalKey();
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gatewayId'] = this.gatewayId;
    data['position'] = this.position;
    data['status'] = this.status;
    data['function'] = this.function;
    data['controllable'] = this.controllable;
    data['links'] = this.links;
    return data;
  }

  Map<String, dynamic> toMapWithId() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gatewayId'] = this.gatewayId;
    data['position'] = this.position;
    data['status'] = this.status;
    data['function'] = this.function;
    data['controllable'] = this.controllable;
    data['links'] = this.links;
    return data;
  }

  @override
  bool operator ==(other) {
    return id == other.id && gatewayId == other.gatewayId;
  }

  Camera.clone(Camera source)
      : this.id = source.id,
        this.name = source.name,
        this.gatewayId = source.gatewayId,
        this.position = source.position,
        this.status = source.status,
        this.function = source.function,
        this.controllable = source.controllable,
        this.links = source.links;
}
