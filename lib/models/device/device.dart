class Device {
  String id;
  String name;
  String macAddress;
  String serialNo;
  String version;
  String ip;
  String subnetMask;
  int gatewayId;
  String port;
  String url;
  bool selected = false;
  bool error = false;
  String status;
  String function;
  String controllable;
  List<String> links;

  Device({
    this.id,
    this.name,
    this.macAddress,
    this.serialNo,
    this.version,
    this.ip,
    this.subnetMask,
    this.gatewayId,
    this.port,
    this.url,
    this.error,
    this.selected,
    this.status,
    this.function,
    this.controllable,
    this.links,
  });

  Device.fromJson(Map<String, dynamic> json) {
    try{
      id = json['Id'];
      name = json['Name'];
      macAddress = json['macAddress'];
      serialNo = json['serialNo'];
      version = json['version'];
      ip = json['ip'];
      subnetMask = json['subnetMask'];
      port = json['Port'];
      url = json['url'];
      status = json['Status'];
      function = json['Function'];
      controllable = json['Controllable'];
      links = [];
      for (final link in json['Links']) {
        for (final url in link["url"]) {
          if (url["value"] != null) links.add(url["value"].replaceAll("}", ""));
        }
      }
    }catch(e){
      print(e);
    }

  }

  Device.fromDB(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      macAddress = json['macAddress'];
      serialNo = json['serialNo'];
      version = json['version'];
      ip = json['ip'];
      subnetMask = json['subnetMask'];
      gatewayId = json['gatewayId'];
      port = json['port'];
      url = json['url'];
      status = json['status'];
      function = json['function'];
      controllable = json['controllable'];
      links = List<String>.from(json['links'] ?? []);
    }catch(e){
      print(e);
    }

  }

  Map<String, dynamic> toJson() {
    try{
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      data['name'] = this.name;
      data['macAddress'] = this.macAddress;
      data['serialNo'] = this.serialNo;
      data['version'] = this.version;
      data['ip'] = this.ip;
      data['subnetMask'] = this.subnetMask;
      data['gatewayId'] = this.gatewayId;
      data['port'] = this.port;
      data['url'] = this.url;
      data['status'] = this.status;
      data['function'] = this.function;
      data['controllable'] = this.controllable;
      data['links'] = this.links;
      return data;
    }catch(e){
      print(e);
    }

  }

  @override
  bool operator ==(Object other) =>
      other is Device && name == other.name && gatewayId == other.gatewayId;
}
