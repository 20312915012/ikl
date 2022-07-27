import 'dart:convert';

import 'package:json_path/json_path.dart';

class BJsonPath{
  dynamic getValue(dynamic input, String filter){
    dynamic json=input;
    if(input is String) {
      json = jsonDecode(input);
    }
    filter=filter.replaceAll("[*]", "*");
    filter=filter.replaceAll("\$.", "");
    while(filter.contains(".[")){
      var startIndex=filter.indexOf(".[");
      filter=filter.replaceFirst("[", "",startIndex);
      filter=filter.replaceFirst("]", "",startIndex);
    }

    final path = JsonPath('\$.$filter');
    return path.readValues(json);
  }
}