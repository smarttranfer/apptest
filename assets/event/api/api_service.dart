import 'dart:typed_data';
import 'package:boilerplate/ui/event/model/camera.dart';
import 'package:boilerplate/ui/event/model/modelName.dart';
import 'package:boilerplate/ui/event/tool/Image_Map.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:boilerplate/ui/event/model/event.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:intl/intl.dart';
import 'package:sembast/timestamp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  static Future<List<ModelName>> getModelNameCam() async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    List<ModelName> listModelName = [];
    String token = "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/monitors?' + token +"&detected=true";
    // print(url);
    Response response = await get(Uri.parse(url));
    for (var i in json.decode(response.body)) {
      listModelName.add(ModelName(mapNameEvent(i['type']), false, i["type"]));
    }
    return listModelName;
  }
  static Future<List<CameraEvent>> getNameCams() async {
    List<CameraEvent> listCam = [];
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token = "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/cameras?' + token +"&detected=true";
    Response response = await get(Uri.parse(url));
    for (var i in json.decode(response.body)) {
      listCam.add(CameraEvent(i['name'], false, i["vmsCameraId"]));
    }
    return listCam;
  }
  static Future<List<Event>> getListEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    List listNewEvent = [];
    String token = "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-newest?' + token +"&detected=true";
    print(url);
    Response response = await get(Uri.parse(url));
    for (var i in json.decode(response.body)) {
      listNewEvent.add(i);
    }
    return Event.eventList(listNewEvent);
  }
  static Future<List<Event>> loadMoreEvent(idEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    List listNewEvent = [];
    String token = "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-newest?' + token +"&detected=true"+"&lessthan="+idEvent;
    print(url);
    Response response = await get(Uri.parse(url));
    for (var i in json.decode(response.body)) {
      listNewEvent.add(i);
    }
    return Event.eventList(listNewEvent);
  }
  static Future<List<Event>> geNewEvent(idEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    List listNewEvent = [];
    String token = "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-newest?' + token +"&detected=true"+"&greaterthan="+idEvent;
    Response response = await get(Uri.parse(url));
    for (var i in json.decode(response.body)) {
      listNewEvent.add(i);
    }
    return Event.eventList(listNewEvent);
  }
  static  Future<String> getImageEvent(idEvent)async{
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token =
        "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-image/'+idEvent.toString()+'/snapshot?' + token;
    return url;
  }
  static Future<Uint8List> getVideoEvent(idEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token =
        "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-image/'+idEvent.toString()+'/video?' + token;
    Response response = await get(Uri.parse(url));
    return response.bodyBytes;
  }
  static Future<String> stringVideoEvent(idEvent)  async{
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token =
        "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-image/'+idEvent.toString()+'/video?' + token;
    return url;
  }
  static Future<String> getNameCamera(idCamera) async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token =
        "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/monitors/'+idCamera.toString()+'?' + token+"&mode=compact";
    Response response = await get(Uri.parse(url));
    String nameCam = jsonDecode(response.body)['Name'];
    return nameCam;
  }
  static Future<List> getNameCameras() async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    String token =
        "&token=${token_value}";
    String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/monitors/'+'?'+token+"&mode=compact";
    Response response = await get(Uri.parse(url));
    List listCam = [];
    for (var i in json.decode(response.body)) {
      listCam.add(i);
    }
    return listCam;
  }
  static Future<List<Event>> filterEvent(filters) async {
    final prefs = await SharedPreferences.getInstance();
    final String token_value = prefs.getString('vms.token');
    final String protocol_value = prefs.getString('vms.protocol');
    final String domain_value = prefs.getString('vms.domain');
    final String port_value = prefs.getString('vms.port');
    List listFilterEvent = [];
    String token = "&token=${token_value}";
    if(filters[0].Value.isEmpty==false || filters[1].Value.isEmpty==false || filters[2].Value.isEmpty==false){
      if(filters[1].Value.isEmpty==false){
        DateTime startDate = DateFormat('hh:mm-dd/MM/yyyy').parse(filters[1].Value[0]);
        DateTime endDate = DateFormat('hh:mm-dd/MM/yyyy').parse(filters[1].Value[1]);

        print(startDate);
        print(endDate);

        DateTime ozoneStartDate = DateTime.parse(startDate.toString().replaceAll(".000", "")+"+07:00");
        DateTime ozoneEndDate  = DateTime.parse(endDate.toString().replaceAll(".000", "")+"+07:00");

        Timestamp startStamp = Timestamp.fromDateTime(ozoneStartDate);
        Timestamp endStamp = Timestamp.fromDateTime(ozoneEndDate);

        String strStartDate = startStamp.seconds.toString();
        String strEndDate = endStamp.seconds.toString();
        String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-newest?' + token +"&detected=true" +"&from=${strStartDate}" +"&to=${strEndDate}";
        var body ={};
        if(filters[0].Value.isEmpty == false){
          body["types"] = filters[0].Value;
        }
        if(filters[2].Value.isEmpty == false){
          body["vmsCameraIds"] = filters[2].Value;
        }
        var request = Request('GET', Uri.parse(url));
        request.body = '''${jsonEncode(body)}''';
        print(url);
        print(request.body);
        StreamedResponse response = await request.send();
         String result = await response.stream.bytesToString();
        for (var i in json.decode(result)) {
          listFilterEvent.add(i);
        }
        return Event.eventList(listFilterEvent);

      }else if(filters[1].Value.isEmpty==true){
        String url = '${protocol_value}://${domain_value}:${port_value}/vms/api/ai/event-newest?' + token +"&detected=true";
        var  body = {};
        if(filters[0].Value.isEmpty == false){
          body["types"] = filters[0].Value;
        }
        if(filters[2].Value.isEmpty == false){
          body["vmsCameraIds"] = filters[2].Value;
        }
        print(jsonEncode(body));

        var request = Request('GET', Uri.parse(url));
        request.body = '''${jsonEncode(body)}''';
        StreamedResponse response = await request.send();
        String result = await response.stream.bytesToString();
        for (var i in json.decode(result)) {
          listFilterEvent.add(i);
        }
      }

      return Event.eventList(listFilterEvent);
    }else{
      print("Chưa chọn filter nào ");
      return Event.eventList(listFilterEvent);
    }
  }
}
