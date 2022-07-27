// @dart=2.9
library blup_dependencies;

import 'dart:async';
import 'dart:convert';
import 'package:b_dep/src/utils/variables.dart' as variables;
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:b_dep/src/frideos_flutter/frideos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dio/dio.dart' as dio;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:b_dep/src/utils.dart';

export 'package:b_dep/src/utils/widgets.dart';
export 'package:b_dep/src/utils.dart';

///For BLUP CODE-GENERATION | ADD THIS FILE TO a_blup/lib folder.

init(String userEmail) {
  variables.clientEmail = userEmail;
}

initMain() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}

initSystem(State state, context, width, height, {String version}) async {
  if (variables.designSize == null&&MediaQuery.of(context).size.width!=0.0) {
    variables.designSize = Size(width, height);
    if (variables.isUpdateSUtilsOnInit) {
      ScreenUtil.init(
          BoxConstraints(
              maxWidth: kIsWeb ? MediaQuery.of(context).size.height * (9 / 16) : MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height),
          orientation: Orientation.portrait,
          /*context: context,*/
          designSize: variables.designSize);
    }
    variables.blupVersion = version;
    SharedPreferences.getInstance().then((prefs) {
      state.setState(() => variables.bPrefs = prefs);
    });
  }
}

class InheritedScrollDataProvider<T> extends InheritedWidget {
  final StreamedValue<T> data;

  InheritedScrollDataProvider({this.data, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedScrollDataProvider oldWidget) {
    return data != oldWidget.data;
  }

  static StreamedValue<T> of<T>(BuildContext context) {
    if (context == null) {
      return null;
    }
    var data;
    try {
      data = (context.dependOnInheritedWidgetOfExactType<InheritedScrollDataProvider<T>>() == null
          ? null
          : (context.dependOnInheritedWidgetOfExactType<InheritedScrollDataProvider<T>>()).data);
    } catch (e) {}
    return data;
  }
}

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

FirebaseApp app;

BHelperFunctions bHelperFunctions = BHelperFunctions();

//BStorage bStorage = BStorage();

///xxx---Stripe-Payments---xxx///

class StripeCheckout {
  void start(BuildContext context, String apiKey, String secretKey, List<String> paymentMethods, String priceId,
      String success_url, String cancelUrl,
      {int quantity = 1}) async {
    final sessionId =
        await Server().createCheckout(secretKey, paymentMethods, priceId, success_url, cancelUrl, quantity: quantity);
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => CheckoutPage(
              sessionId: sessionId,
              apiKey: apiKey,
            )));
  }
}

class Server {
  Future<String> createCheckout(
      String secretKey, List<String> paymentMethods, String priceId, String success_url, String cancelUrl,
      {int quantity = 1}) async {
    final auth = 'Basic ' + base64Encode(utf8.encode('$secretKey:'));
    final body = {
      'payment_method_types': paymentMethods ?? ['card'],
      'line_items': [
        {
          'price': priceId,
          'quantity': quantity,
        }
      ],
      'mode': 'payment',
      'success_url': success_url ?? 'https://success.com/{CHECKOUT_SESSION_ID}',
      'cancel_url': cancelUrl ?? 'https://cancel.com/',
    };

    try {
      final result = await dio.Dio().post(
        "https://api.stripe.com/v1/checkout/sessions",
        data: body,
        options: dio.Options(
          headers: {HttpHeaders.authorizationHeader: auth},
          contentType: "application/x-www-form-urlencoded",
        ),
      );
      return result.data['id'];
    } on dio.DioError catch (e, s) {
      print(e.response);
      throw e;
    }
  }
}

class CheckoutPage extends StatefulWidget {
  final String sessionId;
  final String apiKey;

  const CheckoutPage({Key key, this.sessionId, this.apiKey}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebView(
        initialUrl: initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) => _controller = controller,
        onPageFinished: (String url) {
          //<---- add this
          if (url == initialUrl) {
            _redirectToStripe();
          }
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://success.com')) {
            Navigator.of(context).pop('success'); // <-- Handle success case
          } else if (request.url.startsWith('https://cancel.com')) {
            Navigator.of(context).pop('cancel'); // <-- Handle cancel case
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  String get initialUrl => 'data:text/html;base64,${base64Encode(const Utf8Encoder().convert(kStripeHtmlPage))}';

  void _redirectToStripe() {
    //<--- prepare the JS in a normal string
    final redirectToCheckoutJs = '''
var stripe = Stripe(\'${widget.apiKey}\');
    
stripe.redirectToCheckout({
  sessionId: '${widget.sessionId}'
}).then(function (result) {
  result.error.message = 'Error'
});
''';
    _controller.evaluateJavascript(redirectToCheckoutJs); //<--- call the JS function on controller
  }
}

const kStripeHtmlPage = '''
<!DOCTYPE html>
<html>
<script src="https://js.stripe.com/v3/"></script>
<head><title>Stripe checkout</title></head>
<body>
Stripe Checkout powered by Blup
</body>
</html>
''';
