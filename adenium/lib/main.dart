import 'package:adenium/data.dart';
import 'package:flutter/material.dart';

///This is how a single [Plant] is stored in the entire program.
///It have its name as [plantname], its details regarding 
///it as [plantdetails] and the date as [plantdate]
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

///The [_PlantOrgState] have the [initState] function where the program tries 
///to read a text file and populate the data or else create a new text file for 
///storing the newly populated data
class _PlantOrgState extends State<PlantOrg> {
  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  late String plantBufferDate = DateTime.now().toString();

  List<Plant> plist = [];  

  @override
  initState() {
    plantDataLoad();
    super.initState();
  }

  ///[plantDataLoad] Loads the [Plant] Data to a [plist] which could be 
  ///used throughout the program instance
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
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Plant Settings",
                style: TextStyle(fontSize: 40, fontFamily: "Noto Sans Korean"),
              ),
            ),
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
        tooltip: "add plant",
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

  ///Addding a new [Plant]
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

  ///Selecting a date for the [Plant] 
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

  /// the dialog window caused by clicking on the FAB button
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

///[_plantSorter] sort out plants in the order of date t serve the planting functionality
_plantSorter(List<Plant> unsortedPlantList) {
  unsortedPlantList.sort((a, b) =>
      (DateTime.parse(a.plantdate)).compareTo(DateTime.parse(b.plantdate)));
  PlantData().writeJson(unsortedPlantList);
}

/// [_dateTimeFormatter] is used to deal with the format of the DateTime and String
String _dateTimeFormatter(DateTime? datetime) {
  //the function returns a string Date
  final datetimeparsed = DateTime.parse(datetime.toString());
  return "${datetimeparsed.day}-${datetimeparsed.month}-${datetimeparsed.year}";
}


/// This is the UI of a single [Plant] TILE
/// multiple of these instances are created with to form a long list of plants 
class PlantOrgItem extends StatelessWidget {
  PlantOrgItem({
    Key? key,
    required this.plant,
    required this.onPlantOrgChange,
  }) : super(key: ObjectKey(plant));

  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onPlantOrgChange(plant);
      },
      leading: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: const Icon(
          Icons.yard,
          size: 50,
        ),
      ),      
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.lightBlueAccent),
            child: Text(plant.plantname, style: const TextStyle(fontSize: 30)),           
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:                
                Text(
              _dateTimeFormatter(DateTime.parse(plant.plantdate)),
              style: const TextStyle(fontSize: 25),
              textAlign: TextAlign.right,
            ),            
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
