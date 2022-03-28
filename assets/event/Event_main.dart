import 'dart:core';
import 'package:boilerplate/ui/event/model/camera.dart';
import 'package:boilerplate/ui/event/tool/Image_Map.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/side_bar_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:boilerplate/ui/event/model/camerabranch.dart';
import 'package:boilerplate/ui/event/model/cameranode.dart';
import 'package:boilerplate/ui/event/model/event.dart';
import 'package:boilerplate/ui/event/model/filterValue.dart';
import 'package:boilerplate/ui/event/model/modelName.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:boilerplate/ui/event/api/api_service.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:loadmore/loadmore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class event_main extends StatefulWidget {
  @override
  _eventScreenState createState() => _eventScreenState();
}

class DataProvider extends ChangeNotifier {}

class _eventScreenState extends State<event_main> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Container(
              width: 50,
              child: FlatButton(
                onPressed: () {
                  _showModalBottom();
                },
                child: Image.asset(
                    'assets/icons/filter.png'),
              ),
            ),
          ],
          centerTitle: true,
          title: Text(
            "Danh sách sự kiện",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: IconAssets(name: "menu_left"),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }),
        ),
        drawer: SidebarMenu(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orange,))
            : RefreshIndicator(
          color: Colors.orange,
                onRefresh: () async {
                  await getEvents();
                },
                child: newEvents.isEmpty == false
                    ? Container(
                        child: filterListShow
                            ? LoadMore(
                                child: ListView.builder(
                                    itemCount: newEvents.length,
                                    itemBuilder: (context, index) {
                                      return eventTemplate(newEvents[index]);
                                    }),
                                onLoadMore: _loadMore,
                                isFinish: finishLoadMore,
                                whenEmptyLoad: true,
                                delegate: DefaultLoadMoreDelegate(),
                                textBuilder: DefaultLoadMoreTextBuilder.english,

                              )
                            : ListView.builder(
                                itemCount: newEvents.length,
                                itemBuilder: (context, index) {
                                  return eventTemplate(newEvents[index]);
                                }),
                      )
                    : ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                            child: Center(
                              child: Text(
                                "Không có dữ liệu sự kiện",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
              ));
  }

  bool filterListShow = true;
  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));
    _getMoreData();
    return true;
  }

  bool finishLoadMore = false;
  List _listCam = [];
  APIService api = APIService();
  bool _isLoading = true;
  List<Event> _events;
  List<Event> newEvents = [];
  List listUrlWidget = [];
  bool tagImageVideo = false;
  List<ModelName> modelnames;
  String imageModel(modelName) {
    String urlImage = "";
    if (modelName == "Cảnh báo xâm nhập" ||
        modelName == "Kết thúc cảnh báo xâm nhập") {
      urlImage = "assets/images/xamnhap.png";
    } else if (modelName == "Cánh báo cháy" ||
        modelName == "Kết thúc cảnh báo cháy") {
      urlImage = "assets/images/khoilua.png";
    } else if (modelName == "NHÂN DIỆN" || modelName == "KẾT THÚC NHẬN DIỆN") {
      urlImage = "assets/images/nhandien.png";
    } else if (modelName == "Cánh báo cháy" ||
        modelName == "Kết thúc cánh báo cháy") {
      urlImage = "assets/images/khoilua.png";
    } else if (modelName == "Nhận diện biển số") {
      urlImage = "assets/images/other.png";
    } else {
      urlImage = "assets/images/other.png";
    }
    return urlImage;
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  _getMoreData() async {
    List<Event> loadEvent =
        await APIService.loadMoreEvent(newEvents.last.id.toString());
    print(loadEvent.length);
    setState(() {
      List<Event> loadMoreEvents = [];
      if(loadEvent.length > 0){
        for (var i in loadEvent) {
          int index =
          _listCam.indexWhere((element) => element["Id"] == i.content);
          String camName = _listCam[index]["Name"];
          String eventNameConverted = mapNameEvent(i.type.toString());
          loadMoreEvents.add(Event(
              content: camName,
              dateTimeCreated: i.dateTimeCreated,
              dateTimeUpdated: i.dateTimeUpdated,
              detected: i.detected,
              eventName: i.eventName,
              id: i.id,
              imageEvent: "",
              level: i.level,
              type: eventNameConverted,
              selected: false));
        }
      }
      List<Event> moreEvent = [];
      if(loadEvent.length > 20){
        moreEvent = loadMoreEvents.take(20).toList();
      }
      if(moreEvent.length > 0){
        newEvents.addAll(moreEvent);
      }
      if(moreEvent.length == 0){
        setState(() {
          finishLoadMore=true;
        });
      }
    });
  }
  List<ModelName>foundModelNames =[];
  List<CameraEvent> listCam = [];
  List<CameraEvent> foundListCam =[];
  List<ModelName> defaultModel = [];
  Future<void> getEvents() async {
    modelnames = await APIService.getModelNameCam();
    foundModelNames = modelnames;
    defaultModel = await APIService.getModelNameCam();;
    listCam = await APIService.getNameCams();
    foundListCam = listCam;
    _listCam = await APIService.getNameCameras();
    _events = await APIService.getListEvent();
    if (newEvents.isEmpty == true) {
      for (var i in _events) {
        int index =
            _listCam.indexWhere((element) => element["Id"] == i.content);
        String camName = _listCam[index]["Name"];
        String eventNameConverted = mapNameEvent(i.type.toString());
        newEvents.add(Event(
            content: camName,
            dateTimeCreated: i.dateTimeCreated,
            dateTimeUpdated: i.dateTimeUpdated,
            detected: i.detected,
            eventName: i.eventName,
            id: i.id,
            imageEvent: "",
            level: i.level,
            type: eventNameConverted,
            selected: false));
      }
      if(newEvents.length > 10){
        newEvents = newEvents.getRange(0, 10).toList();
      }
    } else if (newEvents.isEmpty == false) {
      List<Event> refreshEvent =
          await APIService.geNewEvent(newEvents.first.id.toString());
      for (var i in refreshEvent) {
        int index =
            _listCam.indexWhere((element) => element["Id"] == i.content);
        String camName = _listCam[index]["Name"];
        String eventNameConverted = mapNameEvent(i.type.toString());
        newEvents.add(Event(
            content: camName,
            dateTimeCreated: i.dateTimeCreated,
            dateTimeUpdated: i.dateTimeUpdated,
            detected: i.detected,
            eventName: i.eventName,
            id: i.id,
            imageEvent: "",
            level: i.level,
            type: eventNameConverted,
            selected: false));
      }
      if(newEvents.length > 10){
        newEvents.getRange(0, 10).toList();
      }
      newEvents.sort((a, b) => b.dateTimeCreated.compareTo(a.dateTimeCreated));
    }

    setState(() {
      finishLoadMore = false;
      _isLoading = false;
      filterListShow = true;
    });
  }

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime(2022, 11, 5),
    end: DateTime(2022, 12, 24),
  );

  List listSelectedBranchCam = [];

  List<CameraBranch> camBranches = [
    CameraBranch(
        'Chi nhánh 1',
        [
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false)
        ],
        false),
    CameraBranch(
        'Chi nhánh 2',
        [
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false)
        ],
        false),
    CameraBranch(
        'Chi nhánh 3',
        [
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false),
          CameraNode('Camera 1', false)
        ],
        false),
  ];

  List<Filter> filters = [
    Filter("", [], "Tên bài"),
    Filter("", [], "Thời gian"),
    Filter("", [], "Camera")
  ];

  List listHours = [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23"
  ];
  List listMinutes = [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59"
  ];

  List<ModelName> selectedModelNames = [];
  Widget _buildItemList(BuildContext context, int index) {
    if (index == listHours.length)
      return Center(child: CircularProgressIndicator());
    return Container(
      width: 50,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.transparent,
              width: 50,
              height: 50,
              child: Center(
                  child: Text('${listHours[index]}',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            )
          ]),
    );
  }

  Widget _buildMinutesList(BuildContext context, int index) {
    if (index == listMinutes.length)
      return Center(child: CircularProgressIndicator());
    return Container(
      width: 50,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.transparent,
              width: 50,
              height: 50,
              child: Center(
                  child: Text('${listMinutes[index]}',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            )
          ]),
    );
  }

  bool everyChecked(List e) {
    for (var i in e) {
      if (!i.isSelected) return false;
    }
    return true;
  }

  Widget branchesCamTemplate(branchesCam) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter settStateModal) {
      return TreeView(
        nodes: [
          TreeNode(
            content: Flexible(
                child: ListTile(
              title: Text(
                branchesCam.branchName,
                style: TextStyle(color: Colors.white),
              ),
              trailing: branchesCam.isSelected
                  ? Icon(
                      Icons.check_box_rounded,
                      color: Colors.orange[700],
                    )
                  : Icon(Icons.check_box_outline_blank_rounded,
                      color: Colors.grey),
              onTap: () {
                final newValue = !branchesCam.isSelected;
                settStateModal(() {
                  branchesCam.isSelected = newValue;
                  for (var i in branchesCam.listCam) {
                    i.isSelected = newValue;
                  }
                  if (branchesCam.isSelected == true) {
                    listSelectedBranchCam
                        .add(CameraBranch(branchesCam.branchName, [], true));
                  } else if (branchesCam.isSelected == false) {
                    listSelectedBranchCam.removeWhere((element) =>
                        element.branchName == branchesCam.branchName);
                  }
                });
              },
            )),
            children: [
              for (var camNode in branchesCam.listCam)
                TreeNode(
                    content: Flexible(
                        child: ListTile(
                  title: Text(
                    camNode.nodeName.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: camNode.isSelected
                      ? Icon(
                          Icons.check_box_rounded,
                          color: Colors.orange[700],
                        )
                      : Icon(Icons.check_box_outline_blank_rounded,
                          color: Colors.grey),
                  onTap: () {
                    final newValue = !camNode.isSelected;
                    settStateModal(() {
                      camNode.isSelected = newValue;
                      if (!newValue) {
                        branchesCam.isSelected = false;
                      } else {
                        bool checkAll = everyChecked(branchesCam.listCam);
                        branchesCam.isSelected = checkAll;
                      }

                      if (camNode.isSelected == true) {
                        for (var i in listSelectedBranchCam) {
                          if (i.branchName = branchesCam.name) {
                            i.listCam.add(CameraNode(
                                camNode.nodeName, camNode.isSelected));
                          } else {
                            listSelectedBranchCam.add(CameraBranch(
                                branchesCam.branchName,
                                [],
                                branchesCam.isSelected));
                          }
                        }
                      } else if (camNode.isSelected == false) {
                        for (var i in listSelectedBranchCam) {
                          if (i.branchName =
                              branchesCam.name || i.listCam != null) {
                            i.listCam.removeWhere((element) =>
                                element.nodeName == camNode.nodeName);
                          } else if (i.branchName =
                              branchesCam.name || i.listCam != null) {
                            listSelectedBranchCam.removeWhere((element) =>
                                element.branchName == branchesCam.branchName);
                          }
                        }
                      }
                    });
                  },
                ))),
            ],
          )
        ],
      );
    });
  }

  Widget filterTemplate(filter) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter settStateModal) {
      return Card(
          color: HexColor("404447"),
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: InkWell(
            onTap: () {
              routeFilter(filter.Name);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 7.0),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(filter.Name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold)),
                          ]),
                    ],
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: filter.Value.isEmpty
                            ? Text(
                                "Chọn",
                                style: TextStyle(color: Colors.white),
                              )
                            : Container(
                                width: 150,
                                child: Text(
                                  filter.displayValue,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                  ),
                  filter.Value.isEmpty
                      ? Container()
                      : Container(
                          width: 45,
                          child: Align(
                            child: FlatButton(
                              onPressed: () {
                                settStateModal(() {
                                  clearList(filter.Name);
                                });
                              },
                              child: Image.asset('assets/icons/coolicon.png'),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                        )
                ],
              ),
            ),
          ));
    });
  }
  clearALL() async{
    startMinutetap = 0;
    startHourTap = 0;
    endMinutetap;
    endHourtap;
    filters[0].Value = [];
    filters[0].displayValue = "";
    listModelName = [];
    filters[1].Value = [];
    filters[1].displayValue = "";
    CamNames = [];
    filters[2].Value = [];
    filters[2].displayValue = "";
    modelnames = await APIService.getModelNameCam();
    listCam = await APIService.getNameCams();
    foundModelNames = defaultModel;
    enableEditStartDate = true;
    enableEditEndDate = true;
    endDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
    startDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
    startHour = "00";
    endHour = "23";
    startMinute = "00";
    endMinute = "59";

    enableEditStartDate = true;
    enableEditEndDate = true;
  }
  clearList(filterName) async {
    switch (filterName) {
      case "Tên bài":
        foundModelNames.any((element) => element.isSelected=false);
        filters[0].Value = [];
        filters[0].displayValue = "";
        listModelName = [];
        break;
      case "Thời gian":
        filters[1].Value = [];
        filters[1].displayValue = "";
        enableEditStartDate = true;
        enableEditEndDate = true;
        endDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
        startDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
        startHour = "00";
        endHour = "23";
        startMinute = "00";
        endMinute = "59";
        startMinutetap = 0;
        startHourTap = 0;
        endMinutetap;
        endHourtap;
        break;
      case "Camera":
        foundListCam.any((element) => element.isSelected=false);
        CamNames = [];
        filters[2].Value = [];
        filters[2].displayValue = "";
        break;
    }
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  Widget eventTemplate(event) {
    return InkWell(
      onTap: () {
        setState(() {
          event.selected = true;
        });
        _showCupertinoDialog(event);
      },
      child: Card(
        color: HexColor("2B2F33"),
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          height: 90,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(1.0, 8.0, 1.0, 1.0),
                    width: 55.0,
                    height: 55.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white10,
                      backgroundImage: AssetImage(imageModel(event.type)),
                    ),
                  ),
                  SizedBox(width: 7.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.type,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold)),
                              Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text("Camera " + event.content,
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(
                                    DateFormat("hh:mm:ss - dd-MM-yyyy", "vi")
                                        .format(DateTime.parse(
                                                event.dateTimeCreated)
                                            .toLocal()),
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          padding: EdgeInsetsDirectional.fromSTEB(
                              10.0, 5.0, 10.0, 10.0)),
                    ],
                  ),
                ],
              ),
              // Container(
              //   margin: EdgeInsets.fromLTRB(70, 8.0, 0, 0),
              //   width: 10,
              //   height: 10,
              //   child: event.selected
              //       ? CircleAvatar(
              //           backgroundColor: HexColor("2B2F33"),
              //         )
              //       : CircleAvatar(backgroundColor: Colors.red),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  List CamNames = [];
  Widget camFilterTemplate(camName) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter settStateModal) {
      return ListTile(
        title: Text(
          camName.name,
          style: TextStyle(color: Colors.white),
        ),
        trailing: camName.isSelected
            ? Icon(
                Icons.radio_button_checked_rounded,
                color: Colors.orange[700],
              )
            : Icon(Icons.radio_button_off, color: Colors.grey),
        onTap: () {
          settStateModal(() {
            camName.isSelected = !camName.isSelected;
            if (camName.isSelected == true) {
              CamNames.add(camName.name);
              filters[2].Value.add(camName.id);
              filters[2].displayValue = CamNames.join(", ");
            } else if (camName.isSelected == false) {
              filters[2].Value.removeWhere((element) => element == camName.id);
              CamNames.removeWhere((element) => element == camName.name);
              filters[2].displayValue = CamNames.join(", ");
            }
          });
        },
      );
    });
  }

  List listModelName = [];
  Widget modelFilterTemplate(modelName) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter settStateModal) {
      return ListTile(
        title: Text(
          modelName.name,
          style: TextStyle(color: Colors.white),
        ),
        trailing: modelName.isSelected
            ? Icon(
                Icons.radio_button_checked_rounded,
                color: Colors.orange[700],
              )
            : Icon(Icons.radio_button_off, color: Colors.grey),
        onTap: () {
          settStateModal(() {
            modelName.isSelected = !modelName.isSelected;
            if (modelName.isSelected == true) {
              listModelName.add(modelName.name);
              filters[0].Value.add(modelName.type);
              filters[0].displayValue = listModelName.join(", ");
            } else if (modelName.isSelected == false) {
              filters[0]
                  .Value
                  .removeWhere((element) => element == modelName.type);
              listModelName.removeWhere((element) => element == modelName.name);
              filters[0].displayValue = listModelName.join(", ");
            }
          });
        },
      );
    });
  }

  void routeFilter(filter) {
    switch (filter) {
      case "Tên bài":
        Navigator.of(context).pop();
        _showModalModelName();
        break;
      case "Thời gian":
        Navigator.of(context).pop();
        _showModalTime();
        break;
      case "Camera":
        Navigator.of(context).pop();
        _showModalCameraName();
        break;
    }
  }
  void _showModalModelName() async {
    bool labelEnable = false;
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settStateModal) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  builder: (_, controller) => Container(
                      height: 500,
                      child: Container(
                        decoration: BoxDecoration(
                            color: HexColor("2B2F33"),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                        child: Column(
                          children: <Widget>[
                            Stack(children: [
                              Container(
                                width: double.infinity,
                                height: 55.0,
                                child: const Center(
                                  child: Text("Tên bài",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900)),
                                ),
                              ),
                              Positioned(
                                left: 0.0,
                                top: 5,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showModalBottom();
                                  },
                                ),
                              ),
                            ]),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white),
                                      onChanged: (text){
                                        print(text.toLowerCase());
                                        List<ModelName> results = [];
                                        if (text=="") {
                                          results = modelnames;
                                        }
                                        else {
                                          results = modelnames
                                              .where((model) =>
                                              model.name.toLowerCase().contains(text.toLowerCase()))
                                              .toList();
                                        }
                                        settStateModal(() {
                                          foundModelNames = results;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.white),
                                        border: InputBorder.none,
                                      ),
                                    )),
                                // DraggableScrollableSheet(builder: builder)
                              ],
                            ),
                            Expanded(
                              child:  ListView.builder(
                                itemCount: foundModelNames.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    key: ValueKey(foundModelNames[index].name),
                                    title: Text(
                                      foundModelNames[index].name,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: foundModelNames[index].isSelected
                                        ? Icon(
                                      Icons.radio_button_checked_rounded,
                                      color: Colors.orange[700],
                                    )
                                        : Icon(Icons.radio_button_off, color: Colors.grey),
                                    onTap: () {
                                      settStateModal(() {
                                        foundModelNames[index].isSelected = !foundModelNames[index].isSelected;
                                        if (foundModelNames[index].isSelected == true) {
                                          listModelName.add(foundModelNames[index].name);
                                          filters[0].Value.add(foundModelNames[index].type);
                                          filters[0].displayValue = listModelName.join(", ");
                                        } else if (foundModelNames[index].isSelected == false) {
                                          filters[0]
                                              .Value
                                              .removeWhere((element) => element == foundModelNames[index].type);
                                          listModelName.removeWhere((element) => element == foundModelNames[index].name);
                                          filters[0].displayValue = listModelName.join(", ");
                                        }
                                      });
                                    },
                                  );;
                                }),
                            ),
                            Card(
                                color: HexColor("#FD7B38"),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _showModalBottom();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    height: 60,
                                    width: MediaQuery.of(context).size.width,
                                    child: Align(
                                      child: Text("Xác nhận",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      )),
                );
              });

        });
  }
  String endDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
  String startDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
  String startHour = "00";
  String endHour = "23";
  String startMinute = "00";
  String endMinute = "59";
  bool enableEditStartDate = true;
  bool enableEditEndDate = true;
  double startMinutetap = 0;
  double startHourTap = 0;
  double endMinutetap;
  double endHourtap;
  Future<void> _showAlertDialogStartDate(){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor('#2B2F33'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            height: 130,
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ngày bắt đầu phải nhỏ hơn ngày kết thúc',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Divider(
                  color: Colors.grey,
                  height: 4.0,
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: HexColor('#2B2F33'),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0)),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(color: Colors.red, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _showAlertDialogEndDate(){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor('#2B2F33'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            height: 130,
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ngày kết thúc phải lớn hơn ngày bắt đầu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Divider(
                  color: Colors.grey,
                  height: 4.0,
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: HexColor('#2B2F33'),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0)),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(color: Colors.red, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showModalTime() {
    ScrollController scrollStartHourSnapListController = ScrollController();
    ScrollController scrollStartMinuteSnapListController = ScrollController();
    ScrollController scrollEndHourSnapListController = ScrollController();
    ScrollController scrollEndMinuteSnapListController = ScrollController();
    bool switchStartEnd = false;
    bool hightlightStartDate = true;
    bool hightLightEndDate = false;
    String labelStart = "Nhập ngày bắt đầu";
    String labelEnd = "Nhập ngày kết thúc";
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.95,
              builder: (_, controller) => StatefulBuilder(builder:
                      (BuildContext context, StateSetter settStateModal) {
                    return Container(
                        height: 800.0,
                        child: Container(
                          decoration: BoxDecoration(
                              color: HexColor("2B2F33"),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          child: Column(
                            children: <Widget>[
                              Stack(children: [
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: const Center(
                                    child: Text("Thời gian",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                ),
                                Positioned(
                                  left: 0.0,
                                  top: 5,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showModalBottom();
                                    },
                                  ),
                                ),
                              ]),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Container(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: hightlightStartDate
                                                  ? MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.orangeAccent)
                                                  : MaterialStateProperty.all<
                                                      Color>(Colors.white24)),
                                          child: enableEditStartDate
                                              ? Text('${labelStart}',
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              : Text(
                                                  '${startHour}:${startMinute}-${startDate}',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                          onPressed: () {
                                            settStateModal(() {
                                              switchStartEnd = false;
                                              hightlightStartDate = true;
                                              hightLightEndDate = false;
                                            });
                                          },
                                        ),
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: hightLightEndDate
                                                ? MaterialStateProperty.all<
                                                    Color>(Colors.orangeAccent)
                                                : MaterialStateProperty.all<
                                                    Color>(Colors.white24)),
                                        child: enableEditEndDate
                                            ? Text('${labelEnd}',
                                                style: TextStyle(
                                                    color: Colors.white))
                                            : Text(
                                                '${endHour}:${endMinute}-${endDate}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                        onPressed: () {
                                          settStateModal(() {
                                            switchStartEnd = true;
                                            hightLightEndDate = true;
                                            hightlightStartDate = false;
                                          });
                                        },
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Visibility(
                                    visible: hightlightStartDate,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        SingleChildScrollView(
                                          child: TableCalendar(
                                            focusedDay: DateTime.now(),
                                            firstDay: DateTime.utc(2010, 10, 16),
                                            lastDay: DateTime.utc(2030, 3, 14),
                                            currentDay:  DateFormat("dd/MM/yyyy").parse(startDate),
                                            onDaySelected: (DateTime selectedDay, DateTime s){
                                              settStateModal(() {
                                                if(hightlightStartDate){
                                                  DateTime startDateCompare = DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy').format(selectedDay));
                                                  if(startDateCompare.compareTo(DateFormat('dd/MM/yyyy').parse(endDate)) < 0 ||startDateCompare.isAtSameMomentAs(DateFormat('dd/MM/yyyy').parse(endDate))){
                                                    enableEditStartDate= false;
                                                    startDate =  DateFormat("dd/MM/yyyy").format(selectedDay);
                                                  }else{
                                                    _showAlertDialogStartDate();
                                                  }
                                                }
                                                  });
                                            },
                                            headerStyle: HeaderStyle(
                                                formatButtonVisible: false,
                                                titleCentered: true,
                                                leftChevronIcon: Icon(Icons.arrow_back_ios, color: HexColor("#FD7B38"),),
                                                rightChevronIcon: Icon(Icons.arrow_forward_ios, color: HexColor("#FD7B38"),),
                                                titleTextStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w100
                                                )
                                            ),
                                            calendarStyle: CalendarStyle(
                                              defaultTextStyle: TextStyle(color: Colors.white),
                                              selectedDecoration: BoxDecoration(color:HexColor("#FD7B38") ),
                                              // selectedColor: HexColor("#FD7B38"),
                                              weekendTextStyle: TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                            daysOfWeekStyle: DaysOfWeekStyle(
                                                decoration: BoxDecoration(shape: BoxShape.rectangle),
                                                weekendStyle: TextStyle(
                                                    color: HexColor("#FD7B38")
                                                ),
                                                weekdayStyle: TextStyle(
                                                    color: HexColor("#FD7B38")
                                                )
                                            ),
                                            rowHeight: 45,
                                            calendarFormat: CalendarFormat.month,
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.white24,
                                          thickness: 5,
                                          indent: 50,
                                          endIndent: 50,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              // crossAxisAlignment: CrossAxisAlignment.baseline,
                                              children: [
                                                Container(
                                                  child: InkWell(
                                                    child: Icon(Icons.arrow_drop_up),
                                                    onTap: (){
                                                      startHourTap = startHourTap + 50;
                                                      settStateModal(() {
                                                        scrollStartHourSnapListController.animateTo(startHourTap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: ScrollSnapList(
                                                    listController: scrollStartHourSnapListController,
                                                    initialIndex: double.parse(startHour),
                                                    scrollDirection: Axis.vertical,
                                                    onItemFocus: (int index) {
                                                      settStateModal(() {
                                                        if(hightlightStartDate){
                                                          enableEditStartDate=false;
                                                          startHour = listHours[index];
                                                        }
                                                      });
                                                    },
                                                    focusOnItemTap: true,
                                                    dynamicItemSize: true,
                                                    dynamicItemOpacity: 0.3,
                                                    itemBuilder: _buildItemList,
                                                    itemSize: 50,
                                                    itemCount: listHours.length,
                                                  ),
                                                ),
                                                Container(
                                                  child: InkWell(
                                                    child: Icon(Icons.arrow_drop_down),
                                                    onTap: (){
                                                      startHourTap = startHourTap - 50;
                                                      settStateModal(() {
                                                        scrollStartHourSnapListController.animateTo(startHourTap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 50,
                                              width: 2,
                                              child: Align(
                                                child: Text(
                                                  ":",
                                                  style:
                                                  TextStyle(color: Colors.white),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: InkWell(
                                                    child: Icon(Icons.arrow_drop_up),
                                                    onTap: (){
                                                      startMinutetap = startMinutetap + 50;
                                                      settStateModal(() {
                                                        scrollStartMinuteSnapListController.animateTo(startMinutetap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: ScrollSnapList(
                                                    listController: scrollStartMinuteSnapListController,
                                                    initialIndex: double.parse(startMinute),
                                                    scrollDirection: Axis.vertical,
                                                    onItemFocus: (int index) {
                                                      settStateModal(() {
                                                        if(hightlightStartDate){
                                                          enableEditStartDate=false;
                                                          startMinute =
                                                          listMinutes[index];
                                                        }
                                                      });
                                                    },
                                                    focusOnItemTap: true,
                                                    dynamicItemSize: true,
                                                    dynamicItemOpacity: 0.3,
                                                    itemBuilder: _buildMinutesList,
                                                    itemSize: 50,
                                                    itemCount: listMinutes.length,
                                                  ),
                                                ),
                                                Container(
                                                  child: InkWell(
                                                    child: Icon(Icons.arrow_drop_down),
                                                    onTap: (){
                                                      startMinutetap = startMinutetap - 50;
                                                      settStateModal(() {
                                                        scrollStartMinuteSnapListController.animateTo(startMinutetap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                      });
                                                    },
                                                  ),                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.white24,
                                          thickness: 5,
                                          indent: 50,
                                          endIndent: 50,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                      visible:!hightlightStartDate,
                                      child:ListView(
                                    shrinkWrap: true,
                                    children: [
                                      SingleChildScrollView(
                                        child: TableCalendar(
                                          focusedDay: DateTime.now(),
                                          firstDay: DateTime.utc(2010, 10, 16),
                                          lastDay: DateTime.utc(2030, 3, 14),
                                          currentDay: DateFormat("dd/MM/yyyy").parse(endDate),
                                          onDaySelected: (DateTime selectedDay, DateTime s){
                                            settStateModal(() {
                                              if(hightLightEndDate){
                                                if(selectedDay.compareTo(DateFormat('dd/MM/yyyy').parse(startDate)) > 0 || selectedDay.isAtSameMomentAs(DateFormat('dd/MM/yyyy').parse(startDate))){
                                                  enableEditEndDate = false;
                                                  endDate =  DateFormat("dd/MM/yyyy").format(selectedDay);
                                                }
                                                else{
                                                  _showAlertDialogEndDate();

                                                }
                                              }
                                            });
                                          },
                                          headerStyle: HeaderStyle(
                                              formatButtonVisible: false,
                                              titleCentered: true,
                                              leftChevronIcon: Icon(Icons.arrow_back_ios, color: HexColor("#FD7B38"),),
                                              rightChevronIcon: Icon(Icons.arrow_forward_ios, color: HexColor("#FD7B38"),),
                                              titleTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w100
                                              )
                                          ),
                                          calendarStyle: CalendarStyle(

                                            selectedDecoration: BoxDecoration(color:HexColor("#FD7B38") ),
                                            weekendTextStyle: TextStyle(
                                                color: Colors.white
                                            ),
                                            defaultTextStyle: TextStyle(
                                              color: Colors.white
                                            )
                                            // weekdayStyle: TextStyle(
                                            //     color: Colors.white
                                            // ),
                                          ),
                                          daysOfWeekStyle: DaysOfWeekStyle(
                                              decoration: BoxDecoration(shape: BoxShape.rectangle),
                                              weekendStyle: TextStyle(
                                                  color: HexColor("#FD7B38")
                                              ),
                                              weekdayStyle: TextStyle(
                                                  color: HexColor("#FD7B38")
                                              )
                                          ),
                                          rowHeight: 45,
                                          calendarFormat: CalendarFormat.month,
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.white24,
                                        thickness: 5,
                                        indent: 50,
                                        endIndent: 50,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: InkWell(
                                                  child: Icon(Icons.arrow_drop_up),
                                                  onTap: (){
                                                    endHourtap = endHourtap + 50;
                                                    settStateModal(() {
                                                      scrollEndHourSnapListController.animateTo(endHourtap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: 50,
                                                width: 50,
                                                child: ScrollSnapList(
                                                  listController: scrollEndHourSnapListController,
                                                  initialIndex: double.parse(endHour),
                                                  scrollDirection: Axis.vertical,
                                                  onItemFocus: (int index) {
                                                    settStateModal(() {
                                                      if(hightLightEndDate){
                                                        enableEditEndDate =false;
                                                        endHour = listHours[index];
                                                      }
                                                    });
                                                  },
                                                  focusOnItemTap: true,
                                                  dynamicItemSize: true,
                                                  dynamicItemOpacity: 0.3,
                                                  itemBuilder: _buildItemList,
                                                  itemSize: 50,
                                                  itemCount: listHours.length,
                                                ),
                                              ),
                                              Container(
                                                child: InkWell(
                                                  child: Icon(Icons.arrow_drop_down),
                                                  onTap: (){
                                                    endHourtap = scrollEndHourSnapListController.offset - 50;
                                                    settStateModal(() {
                                                      scrollEndHourSnapListController.animateTo(endHourtap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 50,
                                            width: 2,
                                            child: Align(
                                              child: Text(
                                                ":",
                                                style:
                                                TextStyle(color: Colors.white),
                                              ),
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: InkWell(
                                                  child: Icon(Icons.arrow_drop_up),
                                                  onTap: (){
                                                    endMinutetap = endMinutetap + 50;
                                                    settStateModal(() {
                                                      scrollEndMinuteSnapListController.animateTo(endMinutetap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                    });
                                                  },
                                                ),                                              ),
                                              Container(
                                                height: 50,
                                                width: 50,
                                                child: ScrollSnapList(
                                                  listController: scrollEndMinuteSnapListController,
                                                  initialIndex: double.parse(endMinute),
                                                  scrollDirection: Axis.vertical,
                                                  onItemFocus: (int index) {
                                                    settStateModal(() {
                                                      if(hightLightEndDate){
                                                        enableEditEndDate =false;
                                                        endMinute =  listMinutes[index];
                                                      }
                                                    });
                                                  },
                                                  focusOnItemTap: true,
                                                  dynamicItemSize: true,
                                                  dynamicItemOpacity: 0.3,
                                                  itemBuilder: _buildMinutesList,
                                                  itemSize: 50,
                                                  itemCount: listMinutes.length,
                                                ),
                                              ),
                                              Container(
                                                child: InkWell(
                                                  child: Icon(Icons.arrow_drop_down),
                                                  onTap: (){
                                                    endMinutetap = scrollEndMinuteSnapListController.offset - 50;
                                                    settStateModal(() {
                                                      scrollEndMinuteSnapListController.animateTo(endMinutetap, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                                                    });
                                                  },
                                                ),                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.white24,
                                        thickness: 5,
                                        indent: 50,
                                        endIndent: 50,
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                              Card(
                                  color: HexColor("#FD7B38"),
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  margin:
                                      EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      String dateNow = DateFormat("dd/MM/yyyy")
                                          .format(DateTime.now());
                                      if (startDate == "") {
                                        startDate = dateNow;
                                      }
                                      if (endDate == "") {
                                        endDate = dateNow;
                                      }
                                      if (startHour == "") {
                                        startHour = "00";
                                      }
                                      if (startMinute == "") {
                                        startMinute = "00";
                                      }
                                      if (endHour == "") {
                                        endHour = "23";
                                      }
                                      if (endMinute == "") {
                                        endMinute = "59";
                                      }
                                      String dateStart = startHour +
                                          ":" +
                                          startMinute +
                                          "-" +
                                          startDate;
                                      String dateEnd = endHour +
                                          ":" +
                                          endMinute +
                                          "-" +
                                          endDate;
                                      print(filters[1]
                                          .Value);
                                      filters[1]
                                          .Value=[];
                                      filters[1].displayValue ="";
                                      filters[1]
                                          .Value
                                          .addAll([dateStart, dateEnd]);
                                      filters[1].displayValue =
                                          startDate + " - " + endDate;
                                      _showModalBottom();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5.0),
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      child: Align(
                                        child: Text("Xác nhận",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold)),
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ));
                  }));
        });
  }

  void _showModalCameraName() async{
    APIService.getNameCams();
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settStateModal) {
            return DraggableScrollableSheet(
                initialChildSize: 0.7,
                builder: (_, controller) => Container(
                    height: 500,
                    child: Container(
                      decoration: BoxDecoration(
                          color: HexColor("2B2F33"),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                      child: Column(
                        children: <Widget>[
                          Stack(children: [
                            Container(
                              width: double.infinity,
                              height: 55.0,
                              child: const Center(
                                child: Text("Camera",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                            Positioned(
                              left: 0.0,
                              top: 5,
                              child: IconButton(
                                icon:
                                    Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showModalBottom();
                                },
                              ),
                            ),
                          ]),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: Align(
                                    // alignment: Alignment.bottomCenter,
                                    child: TextField(
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white),
                                      onChanged: (text){
                                        List<CameraEvent> resultCam = [];
                                        if (text=="") {
                                          resultCam = listCam;
                                        } else {
                                          resultCam = listCam
                                              .where((cam) =>
                                              cam.name.toLowerCase().contains(text.toLowerCase()))
                                              .toList();
                                        }
                                        settStateModal(() {
                                          foundListCam = resultCam;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.white),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          Expanded(
                          //     child: ListView(
                          //   children: foundListCam
                          //       .map((camName) => camFilterTemplate(camName))
                          //       .toList(),
                          // )
                            child: ListView.builder(
                                itemCount: foundListCam.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      foundListCam[index].name,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: foundListCam[index].isSelected
                                        ? Icon(
                                      Icons.radio_button_checked_rounded,
                                      color: Colors.orange[700],
                                    )
                                        : Icon(Icons.radio_button_off, color: Colors.grey),
                                    onTap: () {
                                      settStateModal(() {
                                        foundListCam[index].isSelected = !foundListCam[index].isSelected;
                                        if (foundListCam[index].isSelected == true) {
                                          CamNames.add(foundListCam[index].name);
                                          filters[2].Value.add(foundListCam[index].id);
                                          filters[2].displayValue = CamNames.join(", ");
                                        } else if (foundListCam[index].isSelected == false) {
                                          filters[2].Value.removeWhere((element) => element == foundListCam[index].id);
                                          CamNames.removeWhere((element) => element == foundListCam[index].name);
                                          filters[2].displayValue = CamNames.join(", ");
                                        }
                                      });
                                    },
                                  );
                                }),
                          ),
                          Card(
                              color: HexColor("#FD7B38"),
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showModalBottom();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  child: Align(
                                    child: Text("Xác nhận",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ))
                        ],
                      ),
                    )));
          });
        });
  }

  void _showCupertinoDialog(event) async {
    String urlVideo = await APIService.stringVideoEvent(event.id);
    String urlImage = await APIService.getImageEvent(event.id);
    VlcPlayerController _videoPlayerController;
    listUrlWidget.add(urlImage);
    listUrlWidget.add(urlVideo);
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settStateModal) {
            return Container(
              color: HexColor("212529"),
              height: 280.0,
              width: 300.0,
              child: Column(
                children: <Widget>[
                  Stack(children: [
                    Container(
                      color: HexColor("2B2F33"),
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text(event.type,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins')),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      child: Container(
                        width: 50,
                        child: FlatButton(
                          child:
                              Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            listUrlWidget = [];
                            tagImageVideo = false;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ]),
                  Card(
                    color: HexColor("2B2F33"),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                        10.0, 10.0, 1.0, 1.0),
                                    width: 55.0,
                                    height: 55.0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white10,
                                      backgroundImage:
                                          AssetImage(imageModel(event.type)),
                                    ),
                                  ),
                                  SizedBox(width: 7.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                    TextSpan(
                                                        text: event.type,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14))
                                                  ]))),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                    WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Icon(
                                                          Icons.access_time,
                                                          color: Colors.white,
                                                          size: 16,
                                                        )),
                                                    TextSpan(
                                                        text: "  " +
                                                            DateFormat(
                                                                    "hh:mm:ss - dd-MM-yyyy",
                                                                    "vi")
                                                                .format(DateTime
                                                                        .parse(event
                                                                            .dateTimeCreated)
                                                                    .toLocal()),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14))
                                                  ]))),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                    WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Icon(
                                                          Icons
                                                              .photo_camera_front,
                                                          color: Colors.white,
                                                          size: 16,
                                                        )),
                                                    TextSpan(
                                                        text: "  " +
                                                            event.content,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14))
                                                  ]))),
                                            ],
                                          ),
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 10.0, 10.0, 10.0)),
                                    ],
                                  ),
                                  //
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.white24,
                            thickness: 2,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            height: 200,
                            width: 600,
                            child: tagImageVideo
                                ? videoEventDetail(
                                    _videoPlayerController, urlVideo)
                                : imageEventDetail(urlImage),
                          ),
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                InkWell(
                                  onTap: () {
                                    settStateModal(() {
                                      tagImageVideo = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 80,
                                    width: 107,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              color: Colors.transparent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    border: tagImageVideo
                                                        ? Border.all(
                                                            color: Colors
                                                                .transparent)
                                                        : Border.all(
                                                            color: Colors
                                                                .blueAccent)),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.network(
                                                        '${listUrlWidget[0]}')),
                                              ))
                                        ]),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    settStateModal(() {
                                      tagImageVideo = true;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 107,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              color: Colors.transparent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    border: tagImageVideo
                                                        ? Border.all(
                                                            color: Colors
                                                                .blueAccent)
                                                        : Border.all(
                                                            color: Colors
                                                                .transparent)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Stack(
                                                    children: [
                                                      Image.network(
                                                          '${listUrlWidget[0]}'),
                                                      Positioned(
                                                          bottom: 15,
                                                          right: 15,
                                                          top: 15,
                                                          left: 15,
                                                          child: Icon(
                                                            Icons
                                                                .play_circle_fill_rounded,
                                                            color: Colors.white,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                        ]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget imageEventDetail(urlImage) {
    return Image.network(urlImage);
  }

  void _showModalBottom() async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settStateModal) {
            return Container(
                // color: Colors.white10,
                height: 400,
                child: Container(
                  decoration: BoxDecoration(
                      color: HexColor("2B2F33"),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                      )),
                  child: Column(
                    children: <Widget>[
                      Stack(children: [
                        Container(
                          width: double.infinity,
                          height: 56.0,
                          child: const Center(
                            child: Text("Bộ lọc",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          top: 5,
                          child: Container(
                            width: 50,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                  'assets/icons/coolicon.png'),
                            ),
                          ),
                        ),
                        filters[0].Value.isEmpty == false ||
                                filters[1].Value.isEmpty == false ||
                                filters[2].Value.isEmpty == false
                            ? Positioned(
                                right: 50,
                                top: 5,
                                child: TextButton(
                                  onPressed: () {
                                    clearALL();
                                    settStateModal(() {
                                    });
                                  },
                                  child: Text('Đặt lại',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 18)),
                                ))
                            : Container(),
                      ]),
                      Column(children: [
                        Card(
                            color: HexColor("404447"),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            child: InkWell(
                              onTap: () {
                                routeFilter("Tên bài");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 7.0),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text("Tên bài",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                      )),
                                            ]),
                                      ],
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: filters[0].Value.isEmpty
                                              ? Text(
                                                  "Chọn",
                                                  style: TextStyle(
                                                      color: HexColor("#818181")),
                                                )
                                              : Container(
                                                  width: 150,
                                                  child: Text(
                                                    filters[0].displayValue,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                    ),
                                    filters[0].Value.isEmpty
                                        ? Container()
                                        : Container(
                                            width: 45,
                                            child: Align(
                                              child: FlatButton(
                                                onPressed: () {
                                                  settStateModal(() {
                                                     clearList("Tên bài");
                                                  });
                                                },
                                                child: Image.asset(
                                                    'assets/icons/coolicon.png'),
                                              ),
                                              alignment: Alignment.centerRight,
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            )),
                        Card(
                            color: HexColor("404447"),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            child: InkWell(
                              onTap: () {
                                routeFilter("Thời gian");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 7.0),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text("Thời gian",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                      )),
                                            ]),
                                      ],
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: filters[1].Value.isEmpty
                                              ? Text(
                                                  "Chọn",
                                                  style: TextStyle(
                                                      color: HexColor("#818181")),
                                                )
                                              : Container(
                                                  width: 160,
                                                  child: Text(
                                                    filters[1].displayValue,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                    ),
                                    filters[1].Value.isEmpty
                                        ? Container()
                                        : Container(
                                            width: 45,
                                            child: Align(
                                              child: FlatButton(
                                                onPressed: () {
                                                  settStateModal(() {
                                                    clearList("Thời gian");
                                                  });
                                                },
                                                child: Image.asset(
                                                    'assets/icons/coolicon.png'),
                                              ),
                                              alignment: Alignment.centerRight,
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            )),
                        Card(
                            color: HexColor("404447"),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            child: InkWell(
                              onTap: () {
                                routeFilter("Camera");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 7.0),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text("Camera",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0,
                                                      )),
                                            ]),
                                      ],
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: filters[2].Value.isEmpty
                                              ? Text(
                                                  "Chọn",
                                                  style: TextStyle(
                                                      color: HexColor("#818181")),
                                                )
                                              : Container(
                                                  width: 150,
                                                  child: Text(
                                                    filters[2].displayValue,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                    ),
                                    filters[2].Value.isEmpty
                                        ? Container()
                                        : Container(
                                            width: 45,
                                            child: Align(
                                              child: FlatButton(
                                                onPressed: () {
                                                  settStateModal(() {
                                                    clearList("Camera");
                                                  });
                                                },
                                                child: Image.asset(
                                                    'assets/icons/coolicon.png'),
                                              ),
                                              alignment: Alignment.centerRight,
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            )),
                      ]),

                      AbsorbPointer(
                        absorbing:filters[0].Value.isEmpty&&
                            filters[1].Value.isEmpty&&
                            filters[2].Value.isEmpty,
                        child: Card(
                            color: filters[0].Value.isEmpty &&
                                filters[1].Value.isEmpty &&
                                filters[2].Value.isEmpty ?  HexColor("#818181") :HexColor("#FD7B38"),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            child: InkWell(
                              onTap: () async {
                                newEvents = [];
                                List<Event> filterListOriginal = [];
                                // Navigator.of(context).pop();
                                filterListOriginal =
                                    await APIService.filterEvent(filters);
                                for (var i in filterListOriginal) {
                                  int index = _listCam.indexWhere(
                                      (element) => element["Id"] == i.content);
                                  String camName = _listCam[index]["Name"];
                                  String eventNameConverted =
                                      mapNameEvent(i.type.toString());
                                  newEvents.add(Event(
                                      content: camName,
                                      dateTimeCreated: i.dateTimeCreated,
                                      dateTimeUpdated: i.dateTimeUpdated,
                                      detected: i.detected,
                                      eventName: i.eventName,
                                      id: i.id,
                                      imageEvent: "",
                                      level: i.level,
                                      type: eventNameConverted,
                                      selected: false));
                                }
                                Navigator.of(context).pop();
                                setState(() {
                                  filterListShow = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: Align(
                                  child: Text("Hiển thị kết quả",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  alignment: Alignment.center,
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ));
          });
        });
  }

  Widget videoEventDetail(_videoPlayerController, urlVideo) {
    String urlTest = "https://media.w3.org/2010/05/sintel/trailer.mp4";
    _videoPlayerController = VlcPlayerController.network(
      urlVideo,
      hwAcc: HwAcc.FULL,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    return Card(
      child: FutureBuilder(
          future: _videoPlayerController.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: VlcPlayer(
                  controller: _videoPlayerController,
                  aspectRatio: 16 / 9,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "Không có dữ liệu video",
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 20),
                ),
              );
            }
          }),
    );
  }
}
