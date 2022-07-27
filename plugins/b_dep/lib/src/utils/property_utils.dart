import 'package:b_dep/src/utils/widgets.dart';
import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:flutter/material.dart';

class PropertyUtils {
  ///Updates properties of [BStatefulWidget] widget
  ///& it's children.
  void updateProperties(BStatefulWidget widget) {
    // print("widgetState> "+widget.id.toString()+" >> "
    //     +BWidget.widgetMap[widget.id].toString()+" >> "+widget.runtimeType.toString());
    if (widget.id != null && BWidget.widgetMap[widget.id]?.state != null) {
      BWidget.widgetMap[widget.id].state.updateValues();
    }
    _updateChildProperties(widget.child);
  }

  ///Updates properties of [BStatefulWidget] widget's child.
  ///
  ///i.e. If widget is [BFlatButton] then
  ///it's child will be [BText].
  void _updateChildProperties(Widget child) {
    if (child != null) {
      Widget widget = getBWidgetFromChild(child);
      updateProperties(widget);
    }
  }

  String getTextFromBTextChild(BStatefulWidget widget) {
    BStatefulWidget child = getBWidgetFromChild(widget.child);
    if (child is BText) {
      return child.text;
    } else {
      return null;
    }
  }

  ///Returns [BStatefulWidget] widget child.
  Widget getBWidgetFromChild(Widget child) {
    switch (child.runtimeType) {
      case IgnorePointer:
        child = getBWidgetFromChild((child as IgnorePointer).child);
        break;
      case Align:
        child = getBWidgetFromChild((child as Align).child);
        break;
      case GestureDetector:
        child = getBWidgetFromChild((child as GestureDetector).child);
        break;
      case SizedBox:
        child = getBWidgetFromChild((child as SizedBox).child);
        break;
      default:
        return child;
    }
    return child;
  }
}
