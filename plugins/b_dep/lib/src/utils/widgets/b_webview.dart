import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:b_dep/src/utils/variables.dart' as variables;
import 'package:universal_io/io.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/webviewx.dart';

class BWebView extends BStatefulWidget {
  BWebView({
    Key key,
    String id,
    this.width,
    this.height,
    this.webLink,
    this.onWebviewDefaultPropUpdate,
    this.onWebviewExtraPropUpdate,
  }) : super(
          key: key,
          id: id,
    width: width,
    height: height,
        );

  String webLink;

  double width;
  double height;

  final Function onWebviewDefaultPropUpdate;
  final Function onWebviewExtraPropUpdate;

  @override
  BState<BStatefulWidget> createState() => _BWebViewState();
}

class _BWebViewState extends BState<BWebView> {
  WebViewXController webviewController;
  String mWebLink;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    scrUtilConversion();
    PropertyUtils().updateProperties(widget);

    if(webviewController!=null&&
        (mWebLink==null||mWebLink!=widget.webLink)) {
      mWebLink=widget.webLink;
      webviewController.loadContent(
        mWebLink,
        SourceType.url,
      );
    }

    return WebViewX(
      width: widget.width,
      height: widget.height,
      initialContent: widget.webLink,
      initialSourceType: SourceType.url,
      onWebViewCreated: (controller) => webviewController = controller,
    );
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    // if (variables.blupVersion.toString() != "null") {
    //   widget.size = widget.size == null ? null : ScreenUtil().setWidth(widget.size);
    // }
  }

  @override
  void updateValues() {
    if (widget.onWebviewDefaultPropUpdate != null) {
      widget.onWebviewDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onWebviewExtraPropUpdate != null) {
      widget.onWebviewExtraPropUpdate(
        widget.webLink,
      );
    }
  }
}
