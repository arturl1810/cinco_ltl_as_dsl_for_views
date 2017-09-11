class MapList {
  String name;
  List<MapListValue> values;
  bool open = true;

  MapList(String this.name,{List<MapListValue> this.values})
  {

  }
}

class MapListValue {
  String name;
  String identifier;
  String imgPath;

  MapListValue(String this.name,{String this.identifier,String this.imgPath})
  {

  }
}

