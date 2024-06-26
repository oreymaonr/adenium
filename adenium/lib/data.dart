import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:adenium/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PlantData {  

  static const String green = "\x1B[32m";
  static const String reset = "\x1B[0m";
  static const String yellow = "\x1B[33m";
  static const String red = "\x1B[31m";
  static const String filelocation = "storage/emulated/0/FlutterPlantData/plantfile.txt";

  /// The [_supplyPlist] method act as the part which reads the list in the initial instace of the program.
  /// The method returns a [Plant] object list which is in Future reference.  
  Future<List<Plant>> get getplantData async => await _supplyPlist();

  _supplyPlist() {
    Future<List<Plant>> plantList = readJson();
    return plantList;
  }

  ///Writing the [Plant] Data to the json file
  void writeJson(List<Plant> plants) async {    
   
    Directory dir = await getApplicationDocumentsDirectory();    
    developer.log("${green}The directory path is :${dir.path}$reset");    
    developer.log(green+filelocation+reset);
    fileWritingPart(filelocation, plants);
    
  }

  /// [async] method which actually does the [fileWritingPart] part
  /// I gave it a straight forward name for future reference
  void fileWritingPart(String filename, List<Plant> plist) async {
    File f = await File(filename).create(recursive: true);
    final p = plist.map((plant) => plant.toJson()).toList();
    f.writeAsString(jsonEncode(p));
    developer.log("${green}writing is success$reset");
  }

  ///[readJson] method reads the json Plant file and then populates the 
  ///[Plant] list which is ofcourse a [Future] details
  Future<List<Plant>> readJson() async {
    List<Plant> plantList = [];
    ///Checks for permission if possible
    var status = await Permission.storage.request();
    developer.log("${yellow}status of the permission is :$status$reset");
    try {      
      File f = File(filelocation);      
      String str = await f.readAsString();
      final plantListJson = await jsonDecode(str);
      for (var i = 0; i < plantListJson.length; i++) {
        plantList.add(Plant(
            plantname: plantListJson[i]["plantname"],
            plantdetails: plantListJson[i]["plantdetails"],
            plantdate: plantListJson[i]["plantdate"]));
      }
      developer.log("${green}read is success$reset");
    // ignore: sdk_version_since
    } on PathNotFoundException catch (_) {
      developer.log("${red}exception caught while reading$reset");
    }
    return plantList;
  }
}