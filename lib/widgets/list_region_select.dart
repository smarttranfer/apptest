import 'package:boilerplate/constants/regions.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/expandable_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class ListRegionSelect extends StatefulWidget {
  @override
  _ListRegionSelectState createState() => _ListRegionSelectState();
}

class _ListRegionSelectState extends State<ListRegionSelect> {
  HomeStore _homeStore;
  ProfileStore _profileStore;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _profileStore = Provider.of(context);
    _homeStore.regionCode =
        await appComponent.getSharedPreferenceHelper().currentRegionCode;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      List<Region> listContinents = _profileStore.listContinents.isEmpty
          ? listContinentsCache.map((e) => Region.fromJson(e)).toList()
          : _profileStore.listContinents;
      List<Region> listCountries = _profileStore.listCountries.isEmpty
          ? listCountriesCache.map((e) => Region.fromJson(e)).toList()
          : _profileStore.listCountries;

      listCountries.sort((a, b) => a.name.compareTo(b.name));

      listContinents.forEach((element) {
        element.childList = [];
      });
      List<Region> listRegionFilter =
          _setRegionByFilter(listContinents, listCountries);
      return Expanded(
        child: listRegionFilter.isNotEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: listRegionFilter
                    .map(
                      (continent) => ExpandableGroup(
                        isExpanded: _profileStore.regionFilter.length > 0 &&
                            continent.parentId == 0,
                        header: _header(continent.name),
                        expandedIcon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                        ),
                        collapsedIcon: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 24,
                        ),
                        items: _buildItems(context, continent.childList),
                        headerEdgeInsets:
                            EdgeInsets.only(left: 16.0, right: 16.0),
                      ),
                    )
                    .toList(),
              )
            : Center(
                child: Container(
                  child: Text(
                    Translate.getString("start.no_data", context),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _header(name) => Text(name,
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));

  List<ListTile> _buildItems(BuildContext context, List<Region> items) => items
      .map<ListTile>((e) => ListTile(
            tileColor: Color.fromRGBO(23, 22, 27, 1),
            onTap: () {
              _homeStore.regionCode = e.regionalId.toString();
            },
            title: Text(e.name,
                style: TextStyle(
                    color: _homeStore.regionCode == e.regionalId.toString()
                        ? Colors.blueAccent
                        : Colors.white)),
            trailing: Icon(
              _homeStore.regionCode == e.regionalId.toString()
                  ? Icons.radio_button_checked_outlined
                  : Icons.radio_button_unchecked,
              color: _homeStore.regionCode == e.regionalId.toString()
                  ? Colors.blueAccent
                  : Colors.grey[400],
            ),
          ))
      .toList();

  _setRegionByFilter(List<Region> listContinents, List<Region> listCountries) {
    List<Region> listRegionFilter = [];
    for (Region data in listContinents) {
      if (data.name
          .toLowerCase()
          .contains(_profileStore.regionFilter.toLowerCase())) {
        Region parent = new Region.fromJson(data.toJson());
        parent.childList = listCountries
            .where((element) => element.parentId == data.regionalId)
            .toList();
        listRegionFilter.add(parent);
      }
    }
    if (_profileStore.regionFilter.isEmpty) return listRegionFilter;
    List<Region> parentListTemp = [];
    for (Region child in listCountries) {
      if (child.name
          .toLowerCase()
          .contains(_profileStore.regionFilter.toLowerCase())) {
        if (!listRegionFilter.any((el) => el.regionalId == child.parentId)) {
          Region existParent = parentListTemp.firstWhere(
              (element) => element.regionalId == child.parentId,
              orElse: () => null);
          if (existParent == null) {
            existParent = new Region.fromJson(listContinents
                .firstWhere(
                    (continent) => continent.regionalId == child.parentId)
                .toJson());
            listRegionFilter.add(existParent);
            existParent.childList = [];
            parentListTemp.add(existParent);
          }
          existParent.childList.add(child);
        } else {
          Region existParent = parentListTemp.firstWhere(
              (element) => element.regionalId == child.parentId,
              orElse: () => null);
          if (existParent != null) {
            existParent.childList.add(child);
          }
        }
      }
    }
    return listRegionFilter;
  }
}

class Region {
  Region({
    this.regionalId,
    this.parentId,
    this.name,
    this.isActive,
    this.level,
    this.cityFlag,
    this.description,
    this.prefix,
    this.fullAddress,
    this.childList,
  });

  int regionalId;
  int parentId;
  String name;
  String isActive;
  int level;
  String cityFlag;
  String description;
  dynamic prefix;
  String fullAddress;
  List<Region> childList;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        regionalId: json["RegionalID"],
        parentId: json["ParentID"],
        name: json["Name"],
        isActive: json["IsActive"],
        level: json["Level"],
        cityFlag: json["CityFlag"],
        description: json["Description"],
        prefix: json["Prefix"],
        fullAddress: json["FullAddress"],
      );

  Map<String, dynamic> toJson() => {
        "RegionalID": regionalId,
        "ParentID": parentId,
        "Name": name,
        "IsActive": isActive,
        "Level": level,
        "CityFlag": cityFlag,
        "Description": description,
        "Prefix": prefix,
        "FullAddress": fullAddress,
      };
}
