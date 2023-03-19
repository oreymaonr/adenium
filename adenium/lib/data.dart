import 'package:adenium/main.dart';


class PlantData {
  final List<Plant> plist = <Plant>[
    Plant(
      plantname: "adenium",
      plantdetails: "Adenium obesum is grown as a houseplant in temperate and tropical regions." 
      "Numerous hybrids have been developed. Adeniums are appreciated for their colorful flowers,"
      " but also for their unusual, thick caudices. They can be grown for many years in a pot and "
      "are commonly used for bonsai.One of the paired, follicular fruit of an Adenium species, "
      "dehiscing to release seeds equipped with a double pappus (i.e. tuft of hairs at each end) for wind-dispersal"
      "Because seed-grown plants are not genetically identical to the mother plant, desirable varieties are"
      "commonly propagated by grafting. Genetically identical plants can also be propagated by cutting.",
      plantdate: DateTime.now(),
    ),
    Plant(
      plantname: "aster", 
      plantdetails: 
        "Like other members of the family Asteraceae, they have very small flowers collected together"
        " into a composite flower head. Each single flower in a head is called a floret. In part due to"
        " their abundance, along with being a generalist species, dandelions are one of the most vital"
        " early spring nectar sources for a wide host of pollinators.",
        plantdate: DateTime.now(),
    ),
  ];

  List<Plant> get getplantData => plist;
}

