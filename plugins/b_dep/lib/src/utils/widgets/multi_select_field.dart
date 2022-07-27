import 'package:b_dep/src/utils/constants.dart';
import 'package:flutter/material.dart';

import 'multi_select_chip_dialog.dart';
import 'multi_select_chip_display.dart';
import 'multi_select_list_dialog.dart';
import 'multi_select_widgets/multi_select_widgets.dart';

class MultiSelectField<V> extends StatefulWidget {
  final MultiSelectDialogType dialogType;
  final BoxDecoration decoration;
  final String buttonText;
  final Icon buttonIcon;
  final String title;
  final List<MultiSelectItem<V>> items;
  final void Function(List<V>) onSelectionChanged;
  final void Function(List<V>, int) onConfirm;
  final TextStyle textStyle;
  final MultiSelectChipDisplay chipDisplay;
  final FormFieldState<List<V>> state;
  final double iconSize;
  final List<V> initialValue;
  final bool searchable;
  final String confirmText;
  final String cancelText;

  MultiSelectField({
    @required this.title,
    @required this.items,
    this.buttonText,
    this.buttonIcon,
    this.dialogType,
    this.decoration,
    this.onSelectionChanged,
    this.onConfirm,
    this.textStyle,
    this.chipDisplay,
    this.iconSize,
    this.initialValue,
    this.searchable,
    this.confirmText,
    this.cancelText,
    this.state,
  });

  @override
  _MultiSelectFieldState createState() => _MultiSelectFieldState<V>();
}

class _MultiSelectFieldState<V> extends State<MultiSelectField<V>> {
  List<V> _selectedItems = List<V>();

  _showDialog(BuildContext ctx) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        if (widget.dialogType == MultiSelectDialogType.CHIP) {
          return MultiSelectChipDialog<V>(
            items: widget.items,
            title: widget.title != null ? widget.title : "Select",
            initialSelectedItems: widget.initialValue ?? _selectedItems,
            searchable: widget.searchable ?? false,
            confirmText: widget.confirmText,
            cancelText: widget.cancelText,
            onConfirm: (selected, addNewVarNum) {
              if (widget.state != null) {
                widget.state.didChange(selected);
              }
              _selectedItems = selected;
              widget.onConfirm(selected, addNewVarNum);
            },
          );
        } else {
          return MultiSelectListDialog<V>(
            items: widget.items,
            title: widget.title != null ? widget.title : "Select",
            initialSelectedItems: widget.initialValue ?? _selectedItems,
            searchable: widget.searchable ?? false,
            confirmText: widget.confirmText,
            cancelText: widget.cancelText,
            onConfirm: (selected, addNewVarNum) {
              if (widget.state != null) {
                widget.state.didChange(selected);
              }
              _selectedItems = selected;
              widget.onConfirm(selected, addNewVarNum);
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            _showDialog(context);
          },
          child: Container(
            decoration: widget.state != null
                ? widget.decoration ??
                    BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: widget.state != null && widget.state.hasError ? Colors.red : Colors.black,
                          width: 1,
                        ),
                      ),
                    )
                : widget.decoration,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                widget.buttonText == null
                    ? Text(
                        "Select",
                        style: widget.textStyle,
                      )
                    : Text(
                        widget.buttonText != null ? widget.buttonText : "",
                        style: widget.textStyle != null ? widget.textStyle : null,
                      ),
                widget.buttonIcon ??
                    Icon(
                      Icons.arrow_downward,
                      color: widget.textStyle != null && widget.textStyle.color != null ? widget.textStyle.color : null,
                    ),
              ],
            ),
          ),
        ),
        widget.chipDisplay != null && (widget.chipDisplay.items != null && widget.chipDisplay.items.length > 0)
            ? widget.chipDisplay
            : Container(),
        widget.state != null && widget.state.hasError ? const SizedBox(height: 5) : Container(),
        widget.state != null && widget.state.hasError
            ? Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      widget.state.errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}
