import 'package:b_dep/src/utils/constants.dart';
import 'package:flutter/material.dart';

import 'multi_select_chip_display.dart';
import 'multi_select_field.dart';
import 'multi_select_widgets/multi_select_widgets.dart';

class MultiSelectFormField<V> extends FormField<List<V>> {
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
  final FormFieldSetter<List<V>> onSaved;
  final FormFieldValidator<List<V>> validator;
  final List<V> initialValue;
  final bool autovalidate;
  final double iconSize;
  final bool searchable;
  final String confirmText;
  final String cancelText;
  final Key key;

  MultiSelectFormField({
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
    this.onSaved,
    this.validator,
    this.initialValue,
    this.autovalidate = false,
    this.iconSize,
    this.searchable,
    this.confirmText,
    this.cancelText,
    this.key,
  }) : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
            initialValue: initialValue ?? List(),
            builder: (FormFieldState<List<V>> state) {
              return MultiSelectField(
                state: state,
                title: title,
                items: items,
                buttonText: buttonText,
                buttonIcon: buttonIcon,
                chipDisplay: chipDisplay,
                decoration: decoration,
                dialogType: dialogType,
                onConfirm: onConfirm,
                onSelectionChanged: onSelectionChanged,
                textStyle: textStyle,
                iconSize: iconSize,
                initialValue: initialValue,
                searchable: searchable,
                confirmText: confirmText,
                cancelText: cancelText,
              );
            });
}
