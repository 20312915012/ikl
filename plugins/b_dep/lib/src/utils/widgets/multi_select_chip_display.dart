import 'package:flutter/material.dart';

import 'multi_select_widgets/multi_select_widgets.dart';

class MultiSelectChipDisplay<V> extends StatefulWidget {
  final List<MultiSelectItem<V>> items;
  final Function(V) onTap;
  final Color chipColor;
  final Alignment alignment;
  final BoxDecoration decoration;
  final TextStyle textStyle;

  MultiSelectChipDisplay({
    this.items,
    this.onTap,
    this.chipColor,
    this.alignment,
    this.decoration,
    this.textStyle,
  });

  @override
  _MultiSelectChipDisplayState createState() => _MultiSelectChipDisplayState<V>();
}

class _MultiSelectChipDisplayState<V> extends State<MultiSelectChipDisplay<V>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      alignment: widget.alignment ?? Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        children: widget.items != null
            ? widget.items.map((item) => _buildItem(item)).toList()
            : <Widget>[
                const SizedBox(height: 0),
              ],
      ),
    );
  }

  Widget _buildItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        label: Text(
          item.label,
          style: widget.textStyle != null ? widget.textStyle : null,
        ),
        selected: widget.items.contains(item),
        selectedColor: widget.chipColor != null ? widget.chipColor : null,
        onSelected: (_) {
          if (widget.onTap != null) widget.onTap(item.value);
        },
      ),
    );
  }
}
