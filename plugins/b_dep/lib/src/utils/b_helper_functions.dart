import 'package:provider/provider.dart';

class BHelperFunctions {
  getDataFromBSheets(context, colName, bool isSmallCircle) {
    String value = "";
    try {
      if (Provider.of<Map<dynamic, dynamic>>(context, listen: false).length > 0) {
        var data = Provider.of<Map<dynamic, dynamic>>(context, listen: false)[
            (Provider.of<Map<dynamic, dynamic>>(context, listen: false))
                .keys
                .firstWhere((element) => element.contains('${_getLabelFromString(colName)}'))
                .toString()];
        if (data != null) {
          if (data is String) {
            value = (data as String);
          } else if (data is List) {
            if ((data as List).length > 0) {
              if (isSmallCircle) {
                value = (data as List)?.first;
              } else {
                return data as List; //as List
              }
            }
          }
        } /*else{
            if(onFailure!=null){
              onFailure();
            }
          }*/
      } else {
        value = "";
      }
    } catch (e) {
      ///Error: Unhandled Exception: Error: Could not find
      ///the correct Provider<Map<dynamic, dynamic>>
      ///above this MyHomePage Widget.
      return null;
    }
    if (isSmallCircle) {
      return value;
    } else {
      return value.isEmpty ? [] : [value];
    }
  }

  String getRawColName(context, colName) {
    String value = "";
    if (Provider.of<Map<dynamic, dynamic>>(context, listen: false).length > 0) {
      value = (Provider.of<Map<dynamic, dynamic>>(context, listen: false))
          .keys
          .firstWhere((element) => element.contains('${_getLabelFromString(colName)}'));
    } else {
      value = "";
    }
    return value;
  }

  String _getLabelFromString(String itemName) {
    if (itemName.contains(".")) {
      return itemName.substring(itemName.indexOf(".") + 1);
    } else {
      return itemName;
    }
  }
}
