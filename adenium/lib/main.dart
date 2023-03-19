import 'package:adenium/data.dart';
import 'package:flutter/material.dart';


class Plant{
  Plant({required this.plantname,required this.plantdetails,required this.plantdate});
  String plantname;
  String plantdetails; 
  DateTime plantdate;
}
void main() {
  //TODO: split the whole functionality to different dart
  runApp(const Adenium());
}

class Adenium extends StatelessWidget{
  const Adenium({Key? key}) : super(key : key) ;

  @override
  Widget build(BuildContext context){
    return const MaterialApp(    
      title: "Adenium plant organiser",
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
  late  DateTime plantBufferDate = DateTime.now();

  //input data
  List<Plant>  plist = PlantData().getplantData; 
  // TODO:externalize the testing input to a new dart file, maybe add a loading screen
  // TODO: to sort by date

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:const Text("Plant Organiser"),
      ),
      body: ListView(
        padding:const EdgeInsets.symmetric(vertical: 8.0),
        children: plist.map((Plant plant){
          return PlantOrgItem(
            plant : plant,
            onPlantOrgChange : _handlePlantOrgChange,
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
  _updatePlantItem(Plant plant,String updatedPlantname,String updatedPlantDetails,DateTime date){
    setState(() {    
      plist.remove(plant);   
      plist.add(Plant(plantname: updatedPlantname, plantdetails: updatedPlantDetails,
            plantdate: date));
      _textEditingController1.clear();
      _textEditingController2.clear();
    });
  }
  _removePlantItem(Plant plant){
    setState(() {
      plist.remove(plant);
      _textEditingController1.clear();
      _textEditingController2.clear();      
    });
  }
  _handlePlantOrgChange(Plant plant){
    //your can update the plant details here 
    //by turing iun another dilouge box
    return  showDialog(      
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
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
                onPressed:() => _selectDate(context,plant) ,//_selectDate(context), 
                child:const Text('show date picker'))
            ],          
          ),
          actions: <Widget>[        
            TextButton(
              onPressed: (){   
                Navigator.of(context).pop();             
                _removePlantItem(plant);},                
              child: const Text("Remove")
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                _updatePlantItem(
                  plant, 
                  _textEditingController1.text.isEmpty ? plant.plantname : _textEditingController1.text,
                  _textEditingController2.text.isEmpty? plant.plantdetails:_textEditingController2.text,
                  plantBufferDate
                );                       
              }, 
              child: const Text("Update")
            ),
            TextButton(
              onPressed: (){Navigator.pop(context);}, 
              child: const Text("Cancel")
            ),
          ],
        );
      });
  }
  _addPlantItem(String name,String details){
    setState(() {
      plist.add(Plant(plantname: name, plantdetails: details,plantdate: DateTime.now()));
    });
    _textEditingController1.clear();
    _textEditingController2.clear();
  }
  Future<void> _selectDate(BuildContext context,Plant plant) async {    
    DateTime? newSelectedDate = DateTime.now();
    newSelectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021,7,12),
      firstDate: DateTime(1999),
      lastDate: DateTime(2032),
    );
    setState(() {
      plantBufferDate =newSelectedDate ??= DateTime.now();
    });
  }

  _displayDialog(){
    return showDialog(
      context: context,
      barrierDismissible: false, //user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add new Item"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,            
            children: [
              TextField(
                controller: _textEditingController1,
                decoration:  const InputDecoration(hintText: "add new plants"),
              ),
              TextField(
                controller: _textEditingController2,
                decoration:const InputDecoration(hintText: "details of the plant"),
              )
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                // TODO: to add date while adding plant               
                _addPlantItem(
                  _textEditingController1.text,
                  _textEditingController2.text
                );                  
              },
              child: const Text("Add")),
            TextButton(
              onPressed:(){
                Navigator.pop(context);
              },
              child:const Text("Cancel") 
            )
          ],
        );
      });
  }

}


class PlantOrgItem extends StatelessWidget {
  PlantOrgItem({
    Key? key,
    required this.plant,
    required this.onPlantOrgChange,
    }) 
    : super(key: ObjectKey(plant));

  final Plant plant;
  // ignore: prefer_typing_uninitialized_variables
  final onPlantOrgChange;

  _dateTimeFormatter(DateTime? datetime){
    //the function returns a string Date
    final datetimeparsed = DateTime.parse(datetime.toString());
    return "${datetimeparsed.day}-${datetimeparsed.month}-${datetimeparsed.year}";
    
  }
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        onPlantOrgChange(plant);
      },
      leading: 
      Container(
        padding: const EdgeInsets.all(8.0),
        child : const CircleAvatar(
          child: Text('+'),
        ),
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
            child : 
              Column(
                children : [
                  Text(
                    plant.plantname,
                    style:const TextStyle(fontSize: 30)),
                  Text(_dateTimeFormatter(plant.plantdate)),
                ]            
            ),
          ),         
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                plant.plantdetails,
                textAlign: TextAlign.justify,
              ),
            )
          ),          
        ],
      ),  
    );
  }
}
