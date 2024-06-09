import 'package:adenium/data.dart';
import 'package:flutter/material.dart';

class Plant {
  Plant(
      {required this.plantname,
      required this.plantdetails,
      required this.plantdate});

  String plantname;
  String plantdetails;
  String plantdate;

  @override
  String toString() {
    return "plant_name :${plantname}plant_date :${plantdate}plant_details :$plantdetails";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["plantname"] = plantname;
    data["plantdetails"] = plantdetails;
    data["plantdate"] = plantdate;
    return data;
  }
}

void main() {
  runApp(const Adenium());
}

class Adenium extends StatelessWidget {
  const Adenium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Adenium plant organiser",
      debugShowCheckedModeBanner: false, 
      home: PlantOrg(),
    );
  }
}

class PlantOrg extends StatefulWidget {
  const PlantOrg({Key? key}) : super(key: key);

  @override
  State<PlantOrg> createState() => _PlantOrgState();
}

class _PlantOrgState extends State<PlantOrg> {
  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  late String plantBufferDate = DateTime.now().toString();

  List<Plant> plist = [];

  // TODO: to sort by date

  @override
  initState() {
    plantDataLoad();
    super.initState();
  }

  Future<void> plantDataLoad() async {
    List<Plant> inputPlantList = await PlantData().getplantData;
    _plantSorter(inputPlantList);
    setState(() {
      plist = inputPlantList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue                
              ),
              child: Text("Plant Settings",style: TextStyle(fontSize: 40,fontFamily: "Noto Sans Korean"),),),
            ListTile(
              title: const Text("Download as Excel"),
              onTap: () {
                //TODO: Navigation
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Plant Organiser"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: plist.map((Plant plant) {
          return PlantOrgItem(
            plant: plant,
            onPlantOrgChange: _handlePlantOrgChange,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDialog,
        tooltip: "add item",
        child: const Icon(Icons.add),
      ),
    );
  }

  _updatePlantItem(Plant plant, String updatedPlantname,
      String updatedPlantDetails, String date) {
    setState(() {
      plist.remove(plant);
      plist.add(Plant(
          plantname: updatedPlantname,
          plantdetails: updatedPlantDetails,
          plantdate: date));
      _textEditingController1.clear();
      _textEditingController2.clear();
    });
    _plantSorter(plist);
  }

  _removePlantItem(Plant plant) {
    setState(() {
      plist.remove(plant);
      _textEditingController1.clear();
      _textEditingController2.clear();
      _plantSorter(plist);
    });
  }

  _handlePlantOrgChange(Plant plant) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Modify plants"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _textEditingController1,
                  decoration: InputDecoration(hintText: plant.plantname),
                ),
                TextField(
                  controller: _textEditingController2,
                  decoration: InputDecoration(hintText: plant.plantdetails),
                ),
                ElevatedButton(
                    onPressed: () => _selectDate(context, plant),
                    child: const Text('Set Date'))
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _removePlantItem(plant);
                  },
                  child: const Text("Remove")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updatePlantItem(
                        plant,
                        _textEditingController1.text.isEmpty
                            ? plant.plantname
                            : _textEditingController1.text,
                        _textEditingController2.text.isEmpty
                            ? plant.plantdetails
                            : _textEditingController2.text,
                        plantBufferDate);
                  },
                  child: const Text("Update")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
            ],
          );
        });
  }

  _addPlantItem(String name, String details) {
    setState(() {
      plist.add(Plant(
          plantname: name,
          plantdetails: details,
          plantdate: DateTime.now().toString()));
      _plantSorter(plist);
    });
    _textEditingController1.clear();
    _textEditingController2.clear();
  }

  _selectDate(BuildContext context, Plant plant) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 12),
      firstDate: DateTime(1999),
      lastDate: DateTime(2032),
    );
    setState(() {
      plantBufferDate = newSelectedDate.toString();
    });
  }

  _displayDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false, //user must tap button
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add new Item"),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textEditingController1,
                  decoration: const InputDecoration(hintText: "add new plants"),
                ),
                TextField(
                  controller: _textEditingController2,
                  decoration:
                      const InputDecoration(hintText: "details of the plant"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: to add date while adding plant
                    _addPlantItem(_textEditingController1.text,
                        _textEditingController2.text);
                  },
                  child: const Text("Add")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }
}

//function _plantSorter
_plantSorter(List<Plant> unsortedPlantList) {
  unsortedPlantList.sort((a, b) =>
      (DateTime.parse(a.plantdate)).compareTo(DateTime.parse(b.plantdate)));
  PlantData().writeJson(unsortedPlantList);
}

//function _dateTimeFormatter
String _dateTimeFormatter(DateTime? datetime) {
  //the function returns a string Date
  final datetimeparsed = DateTime.parse(datetime.toString());
  return "${datetimeparsed.day}-${datetimeparsed.month}-${datetimeparsed.year}";
}

class PlantOrgItem extends StatelessWidget {
  PlantOrgItem({
    Key? key,
    required this.plant,
    required this.onPlantOrgChange,
  }) : super(key: ObjectKey(plant));

  // ignore: prefer_typing_uninitialized_variables
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onPlantOrgChange(plant);
      },
      leading:  Container(
        padding: const EdgeInsets.symmetric(vertical:8.0),
        child: const Icon(Icons.yard,size: 50,),
      ),
      // title: Text(
      //   plant.plantname,
      //   style: _getTextStyle(plant.checked),
      // ),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),              
              color: Colors.lightBlueAccent
            ),
            child: Text(plant.plantname, style: const TextStyle(fontSize: 30)),
            // Text(_dateTimeFormatter(DateTime.parse(plant.plantdate))),
            // Text(plant.plantdate),
          ),
          Container(            
            padding:
                const EdgeInsets.symmetric(vertical: 8.0),            
            child:
                // Text(plant.plantname, style: const TextStyle(fontSize: 30)),
                Text(_dateTimeFormatter(DateTime.parse(plant.plantdate)),style: const TextStyle(fontSize: 25),textAlign: TextAlign.right,),
            // Text(plant.plantdate),
          ),
        ],
      ),
      subtitle: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.blueGrey),
          ),
        ),
        child: Text(
          plant.plantdetails,
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  final Plant plant;

  final onPlantOrgChange;
}
