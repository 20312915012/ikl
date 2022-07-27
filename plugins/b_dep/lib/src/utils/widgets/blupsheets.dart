import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

typedef BSheetsBuilder = Widget Function(BuildContext context);
typedef BSheetsQueryController = void Function(BuildContext context);
typedef BSSOnSuccess = void Function(String downloadUrl);
typedef BSSOnFailure = void Function();
typedef BSSOnUploading = int Function(double progress, int currentIndex);

var client = http.Client();

class BlupSheets extends BStatefulWidget {
  BlupSheets({
    Key key,
    String id,
    Widget child,
    this.queryListMap,
    this.isRealtime = false,
    this.backendConnectStr,
    this.backendUserAgentStr,
    this.builder,
    this.queryController,
  }) : super(
          key: key,
          id: id,
          child: child,
        );

  final List<Map<String, List<String>>> queryListMap;
  final bool isRealtime;
  final BSheetsBuilder builder;
  final BSheetsQueryController queryController;

  final String backendConnectStr;
  final String backendUserAgentStr;

  @override
  BState<BStatefulWidget> createState() => _BlupSheetsState();
}

class _BlupSheetsState extends BState<BlupSheets> {
  BuildContext contextForProvider;

  WebSocketChannel channel;
  BlupSheetsQueryController blupSheetsQueryController;

  @override
  void initState() {
    super.initState();
    /*BlupSheets(
        builder: (context)=>Container(),
      );*/
    if (widget.backendConnectStr != null && widget.backendConnectStr.isNotEmpty /*&&widget.isRealtime*/) {
      //channel = WebSocketChannel.connect(widget.backendConnectStr,headers: {"User-Agent":widget.backendUserAgentStr});
      if (kIsWeb) {
        channel = WebSocketChannel.connect(
          Uri.parse(widget.backendConnectStr),

          ///TODO: add headers to WebSocket to function properly with Flutter Web & Mobile.
          //headers: {"User-Agent": mBackendUserAgentStr}
        );
      } else {
        channel = IOWebSocketChannel.connect(Uri.parse(widget.backendConnectStr),
            headers: {"User-Agent": widget.backendUserAgentStr});
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    if (channel != null) {
      channel.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getWidget();
  }

  Widget getWidget() {
    ///TODO: Import provider, web_socket
    if (widget.isRealtime) {
      backendCaller();
    }
    return StreamBuilder(
        stream: getStream(),
        builder: (context, snapshot) {
          //print("webSocket data0>>" + snapshot.data?.body.toString() + " >>>> ");
          if (!snapshot.data.toString().contains('"message": "Internal server error"') &&
              snapshot.data.toString() != "null" &&
              !snapshot.data.body.toString().contains('"errorType":"TypeError"')) {
            //print("webSocket data>>" + snapshot.data.toString()+" >>>> "+jsonDecode(snapshot.data)["result"].toString());
            //onSnapshotReceivedRestApi(snapshot.data);
            ///-------------------
            ///
            /// var provider=Provider.of<List<dynamic>>(context,listen: false);
            ///
            /// if(provider.length>0) {
            ///    print("AWS VALUE IN PROVIDER>>>> " + provider[index]["Image3"].toString());
            /// }
            ///
            ///-------------------
          }
          return Provider(
              create: (_) => <dynamic, dynamic>{},
              child: Builder(builder: (context) {
                contextForProvider = context;
                if (blupSheetsQueryController == null) {
                  //blupSheetsQueryController=BlupSheetsQueryController(context,widget.backendUserAgentStr,channel);
                  //widget.queryController(blupSheetsQueryController);
                }
                widget.queryController(contextForProvider);
                return StatefulBuilder(builder: (context, setStateA) {
                  variables.blStateSetter = setStateA;
                  return widget.builder(context);
                });
              }));
        });
  }

  Stream<dynamic> getStream() {
    if (widget.isRealtime && channel != null) {
      return channel.stream;
    } else {
      if (widget.queryListMap.isNotEmpty) {
        return awsReadTable_rest_api(contextForProvider, widget.queryListMap.first);
      } else {
        return null;
      }
    }
  }

  Stream<dynamic> awsReadTable_rest_api(BuildContext context, Map<String, List<String>> queryMap) {
    const _apiGatewayURL = "https://9eb4p1zl55.execute-api.ap-south-1.amazonaws.com/prod/client-bsheets";

    String body = '''
        {
          "isRestApiCall":"true",
          "mCase":"1",
          "email":"${widget.backendUserAgentStr}",
          "queryMap":${json.encode(queryMap)}
        }
      ''';

    return client
        .post(
          Uri.tryParse(_apiGatewayURL),
          body: body,
        )
        .asStream();
  }

  void onSnapshotReceived(var snapshot) {
    if (!jsonDecode(snapshot.data)['id'].toString().contains("subscription")) {
      isAwsReturnedResponse = true;
      //Map<dynamic,dynamic> as = jsonDecode(snapshot.data)['result'] as Map;
      List<dynamic> as = jsonDecode(snapshot.data)['result'] as List;
      //Provider.of<List<dynamic>>(contextForProvider, listen: false).clear();
      //Provider.of<List<dynamic>>(contextForProvider, listen: false).addAll(as);

      Provider.of<Map<dynamic, dynamic>>(contextForProvider, listen: false).clear();
      Provider.of<Map<dynamic, dynamic>>(contextForProvider, listen: false).addAll(as.first);
    } else if (jsonDecode(snapshot.data)['id'].toString().contains("subscription")) {
      if (jsonDecode(snapshot.data)['result']["queryMap"].toString().contains(widget.queryListMap.first.toString())) {
        backendCaller();
      }
    }
  }

  void onSnapshotReceivedRestApi(http.Response snapshot) {
    if (!jsonDecode(snapshot.body)['id'].toString().contains("subscription")) {
      isAwsReturnedResponse = true;
      //Map<dynamic,dynamic> as = jsonDecode(snapshot.data)['result'] as Map;
      List<dynamic> as = jsonDecode(utf8.decode(snapshot.bodyBytes))['result'] as List;
      //Provider.of<List<dynamic>>(contextForProvider, listen: false).clear();
      //Provider.of<List<dynamic>>(contextForProvider, listen: false).addAll(as);
      if (as.isNotEmpty) {
        String key = (as.first as Map<dynamic, dynamic>).keys.first;
        Map<dynamic, dynamic> mapResult = {};
        List<dynamic> listResult = [];
        for (Map<dynamic, dynamic> map in as) {
          listResult.add(map[key]);
        }
        mapResult[key] = listResult.toList();
        //print("as>> "+mapResult.toString());
        Provider.of<Map<dynamic, dynamic>>(contextForProvider, listen: false).clear();
        Provider.of<Map<dynamic, dynamic>>(contextForProvider, listen: false).addAll(mapResult);
      }
    } else if (jsonDecode(snapshot.body)['id'].toString().contains("subscription")) {
      if (jsonDecode(snapshot.body)['result']["query"].toString().contains(widget.queryListMap.first.toString())) {
        backendCaller();
      }
    }
  }

  void backendCaller() {
    if (widget.isRealtime) {
      //channel.sink.add(widget.backendSendStr);
      shootTOAws(widget.queryListMap.first);
    }
  }

  int numOfAwsRetryThreshold = 10;
  int awsRetryCount = 0;
  bool isAwsReturnedResponse = false;
  Timer retryTimer;
  void shootTOAws(Map<String, List<String>> awsShootStr) {
    //print("AWSRetryCountOUT>>> "+awsRetryCount.toString());
    if (retryTimer == null && !isAwsReturnedResponse && awsRetryCount < numOfAwsRetryThreshold && channel != null) {
      channel.sink.add(awsShootStr);
      //print("AWSRetryCount>>> "+awsRetryCount.toString());
      awsRetryCount++;
    }

    retryTimer = Timer(Duration(milliseconds: (200 * awsRetryCount)), () {
      if (!isAwsReturnedResponse && awsRetryCount < numOfAwsRetryThreshold) {
        ///Retry.
        shootTOAws(awsShootStr);
      } else {
        ///Done.
        awsRetryCount = 0;
        isAwsReturnedResponse = false;
      }
      retryTimer = null;
    });
  }

  @override
  void updateValues() {
    // TODO: implement updateValues
  }
}

class BlupSheetsQueryController {
  BuildContext _context;
  bool _isRealtime = false;
  String _backendUserAgentStr;
  Map<String, List<String>> _queryMap;
  Map<String, String> _queryValuesMapList;
  Function _onDone, _onSuccess, _onFailure;
  String backendConnectStr = "wss://dw5ej3zudb.execute-api.ap-south-1.amazonaws.com/production";

  ///WebSocket Api variables.
  WebSocketChannel _channel;
  int numOfAwsRetryThreshold = 10;
  int awsRetryCount = 0;
  bool isAwsReturnedResponse = false;
  Timer retryTimer;

  final String _mainRestApiHeaderToNodgeWebSockets = '''
  {
    "requestContext": {
        "eventType": "MESSAGE",
        "extendedRequestId": "PKcEKHrEhcwFs9g=",
        "stage": "production",
        "connectedAt": 1593891352651,
        "requestId": "PKcEKHrEhcwFs9g=",
        "domainName": "dw5ej3zudb.execute-api.ap-south-1.amazonaws.com",
        "connectionId": "PKcD3dnnhcwAcqw=",
        "apiId": "dw5ej3zudb"
    },
    "body": 
  ''';

  BlupSheetsQueryController(BuildContext mContext, String mBackendUserAgentStr) {
    _context = mContext;
    _backendUserAgentStr = mBackendUserAgentStr;
    if (backendConnectStr.isNotEmpty) {
      if (kIsWeb) {
        _channel = WebSocketChannel.connect(
          Uri.parse(backendConnectStr),

          ///TODO: add headers to WebSocket to function properly with Flutter Web & Mobile.
          //headers: {"User-Agent": mBackendUserAgentStr}
        );
      } else {
        _channel =
            IOWebSocketChannel.connect(Uri.parse(backendConnectStr), headers: {"User-Agent": mBackendUserAgentStr});
      }
      _channel.stream.listen((event) {
        if (_isRealtime && _context != null) {
          //print("onListen>>> " + event.toString());
          _onSnapshotReceivedRestApi(null, event, _context, _queryMap, _queryValuesMapList);
        }
      }, onDone: () {
        if (_onDone != null && _isRealtime) {
          _onDone();
        }
      }, onError: (err) {
        //print("--onErr-->> "+err.toString());
        if (_onFailure != null && _isRealtime) {
          _onFailure();
        }
      });
    }
  }

  Stream<dynamic> runQuery(bool isRealtime, Map<String, List<String>> queryMap, Map<String, String> queryValuesMapList,
      Function onDone, Function onSuccess, Function onFailure,{bool isDataFromLocalDB = false}) {
    _isRealtime = isRealtime;
    _queryMap = queryMap;
    _queryValuesMapList = queryValuesMapList;
    _onDone = onDone;
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    return isDataFromLocalDB ? _loadDataFromLocalDB(queryMap, queryValuesMapList, onDone, onSuccess, onFailure) : _runRestApi(isRealtime, queryMap, queryValuesMapList, onDone, onSuccess, onFailure);
  }

  Stream<dynamic> _runRestApi(bool isRealtime, Map<String, List<String>> queryMap,
      Map<String, String> queryValuesMapList, Function onDone, Function onSuccess, Function onFailure) {
    const _apiGatewayURL = "https://9eb4p1zl55.execute-api.ap-south-1.amazonaws.com/prod/client-bsheets";
    String body = '''
        {
          ${isRealtime ? "" : '"isRestApiCall":"true",'}
          "mCase":"1",
          "email":"$_backendUserAgentStr",
          "queryMap":${json.encode(queryMap)},
          "queryValuesMap":${json.encode(queryValuesMapList)}
        }
      ''';
    String finalBody;
    if (isRealtime) {
      finalBody = _mainRestApiHeaderToNodgeWebSockets + body + "}";
    } else {
      finalBody = body;
    }
    return client.post(Uri.tryParse(_apiGatewayURL), body: finalBody).then((http.Response value) {
      //print("resultForm bSheetsQueryObject> "  +value.body.toString());
      if (_context != null) {
        _onSnapshotReceivedRestApi(value, null, _context, queryMap, queryValuesMapList);
      }
      if (value.body != null && onSuccess != null) {
        Timer(const Duration(milliseconds: 100), () {
          onSuccess();
        });
      }
      if (onDone != null) {
        Timer(const Duration(milliseconds: 100), () {
          onDone();
        });
      }
      return value;
    }).onError((error, stackTrace) {
      print("error in BL Query>> " + error.toString());
      if (onFailure != null) {
        onFailure();
      }
      if (onDone != null) {
        onDone();
      }
    }).asStream();
  }

  void _onSnapshotReceivedRestApi(http.Response snapshot, String snapshotFromSubscription, context,
      Map<String, List<String>> queryMap, Map<String, String> queryValuesMapList) {
    //print("resultForm bSheetsQueryObjectIn> "  +snapshot.body.toString());
    if (snapshot != null && !jsonDecode(utf8.decode(snapshot.bodyBytes))['id'].toString().contains("subscription")) {
      //print("jsonDecode00------------>> "+jsonDecode(utf8.decode(snapshot.bodyBytes))['result'].toString());
      List<dynamic> as = jsonDecode(utf8.decode(snapshot.bodyBytes))['result'] as List;
      if (as.isNotEmpty) {
        //print("as_out> "+as.first.toString()+" >> "+(as.first as Map<dynamic,dynamic>).keys.toString());
        Map<dynamic, dynamic> mapResult = {};

        ///[{"k0":"1","k1":"2"},{"k3":"2"}]
        List<dynamic> listResult = [];
        //String key;
        for (Map<dynamic, dynamic> map in as) {
          map.forEach((key, value) {
            listResult = mapResult[key] ?? [];
            listResult.add(value);
            mapResult[key] = listResult.toList();
          });
        }
        Provider.of<Map<dynamic, dynamic>>(context, listen: false).clear();
        Provider.of<Map<dynamic, dynamic>>(context, listen: false).addAll(mapResult);
      }
    } else if (snapshotFromSubscription != null &&
        jsonDecode(snapshotFromSubscription)['id'].toString().contains("subscription")) {
      if (jsonDecode(snapshotFromSubscription)['result']["queryMap"].toString().contains(queryMap.toString())) {
        //_runWebSocketApi(queryMap, queryValuesMapList);
        _runRestApi(true, queryMap, queryValuesMapList, _onDone, _onSuccess, _onFailure);
      } else {
        //try{
        //print("jsonDecode>> "+jsonDecode(snapshotFromSubscription)['result'].toString());
        Map<dynamic, dynamic> as = jsonDecode(snapshotFromSubscription)['result'] as Map; //.contains(as["tableName"])
        //print("result>> "+queryMap["from"].toList().where((element) => as["tableName"].contains(element)).toString()+" >> "+queryMap["from"].toString()+" as>> "+as["tableName"].toString());
        if (as.containsKey("tableName") && queryMap.containsKey("from")) {
          //queryMap["from"].toList().where((element) => as["tableName"].contains(element)).isNotEmpty;
          if (as["tableName"].runtimeType == String) {
            if (queryMap["from"].toList().where((element) => as["tableName"].contains(element)).isNotEmpty) {
              _runRestApi(true, queryMap, queryValuesMapList, _onDone, _onSuccess, _onFailure);
            }
          } else {
            List<dynamic> tableNameListFromResult = as["tableName"] as List;
            for (String tableName in tableNameListFromResult) {
              if (queryMap["from"].toList().where((element) => tableName.contains(element)).isNotEmpty) {
                _runRestApi(true, queryMap, queryValuesMapList, _onDone, _onSuccess, _onFailure);
                return;
              }
            }
          }
        }
        //}catch(e){}
      }
    }
  }

  Stream<dynamic> _loadDataFromLocalDB(Map<String, List<String>> queryMap,
      Map<String, String> queryValuesMapList, Function onDone, Function onSuccess, Function onFailure) {
    /// TODO:: Define...
  }
}
