import 'package:b_dep/src/utils/widgets/multi_select_list_dialog.dart';
import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:b_dep/src/utils/property_utils.dart';

import 'multi_select_widgets/multi_select_widgets.dart';

class BMultiChoiceDialog extends BStatefulWidget {
  BMultiChoiceDialog({
    Key key,
    String id,
    double width,
    double height,
    this.onMultichoicedialogDefaultPropUpdate,
    this.onMultichoicedialogExtraPropUpdate,
    this.onConfirm,
    this.title,
    this.confirmText,
    this.cancelText,
    this.isOnlyOneSelectionAllowed,
    this.items,
    this.initialSelectedItems,
    this.index,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
        );

  String title, confirmText, cancelText;
  bool isOnlyOneSelectionAllowed;
  List<dynamic> items, initialSelectedItems;
  final Function onMultichoicedialogDefaultPropUpdate;
  final Function onMultichoicedialogExtraPropUpdate;
  final Function onConfirm;
  int index;

  @override
  BState<BStatefulWidget> createState() => _BMultiChoiceDialogState();
}

class _BMultiChoiceDialogState extends BState<BMultiChoiceDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    PropertyUtils().updateProperties(widget);
    //    print("Multichoice called");
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
        ),
        onTap: (){
          //        print("onTap called");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MultiSelectListDialog(
                  items: widget.items.map((item) {
                    return MultiSelectItem(item, item, null);
                  }).toList(),
                  title: widget.title,
                  confirmText: widget.confirmText == null || widget.confirmText.length == 0 ? null : widget.confirmText,
                  cancelText: widget.cancelText == null || widget.cancelText.length == 0 ? null : widget.cancelText,
                  isOnlyOneChildAllowed: widget.isOnlyOneSelectionAllowed,
                  initialSelectedItems: widget.initialSelectedItems,
                  onConfirm: (List<dynamic> selectedList, int addNewVarNum) {
                    if (widget.onConfirm != null) {
                      //print("selectedList> "+selectedList.toString());
                      PropertyUtils().updateProperties(widget);
                      widget.onConfirm(selectedList);
                    }
                  },
                );
              });
        },
      ),
    );
  }

  @override
  void updateValues() {
    if (widget.onMultichoicedialogDefaultPropUpdate != null) {
      widget.onMultichoicedialogDefaultPropUpdate(
        widget.items,
      );
    }
    if (widget.onMultichoicedialogExtraPropUpdate != null) {
      widget.onMultichoicedialogExtraPropUpdate(
        widget.title,
        widget.confirmText,
        widget.cancelText,
        widget.isOnlyOneSelectionAllowed,
        widget.initialSelectedItems,
      );
    }
  }
}
