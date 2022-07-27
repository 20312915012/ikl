import 'package:flutter/material.dart';

class MultiSelectDialogActions<V> {
  List<V> onItemCheckedChange(List<V> selectedValues, V itemValue, bool checked) {
    if (checked) {
      selectedValues.add(itemValue);
    } else {
      selectedValues.remove(itemValue);
    }
    return selectedValues;
  }

  void onCancelTap(BuildContext ctx, List<V> initiallySelectedValues) {
    Navigator.pop(ctx, initiallySelectedValues);
  }

  void onConfirmTap(BuildContext ctx, List<V> selectedValues, Function(List<V>, int) onConfirm, int addNewVarNum) {
    Navigator.pop(ctx, selectedValues);
    if (onConfirm != null) {
      onConfirm(selectedValues, addNewVarNum);
    }
  }
}
