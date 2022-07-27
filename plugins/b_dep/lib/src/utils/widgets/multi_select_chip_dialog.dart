import 'package:flutter/material.dart';

import 'multi_select_widgets/multi_select_widgets.dart';

class MultiSelectChipDialog<V> extends StatefulWidget with MultiSelectDialogActions<V> {
  final List<V> initialSelectedItems;
  final List<MultiSelectItem> items;
  final String title;
  final Function(List<V>) onSelectionChanged;
  final Function(List<V>, int) onConfirm;
  final bool searchable;
  final String confirmText;
  final String cancelText;

  MultiSelectChipDialog({
    @required this.items,
    @required this.title,
    this.initialSelectedItems,
    this.onSelectionChanged,
    this.onConfirm,
    this.searchable,
    this.confirmText,
    this.cancelText,
  });
  @override
  _MultiSelectChipDialogState createState() => _MultiSelectChipDialogState<V>(items);
}

class _MultiSelectChipDialogState<V> extends State<MultiSelectChipDialog<V>> {
  List<V> _selectedValues = List<V>();
  bool _showSearch = false;
  List<MultiSelectItem<V>> _items;

  _MultiSelectChipDialogState(this._items);

  void initState() {
    super.initState();
    if (widget.initialSelectedItems != null) {
      _selectedValues.addAll(widget.initialSelectedItems);
    }
  }

  void onSearchTap() {
    if (_showSearch) {
      setState(() {
        _showSearch = false;
        _items = widget.items;
      });
    } else {
      setState(() {
        _showSearch = true;
      });
    }
  }

  void _updateSearchQuery(String val) {
    if (val != null && val.isEmpty) {
      setState(() {
        _items = widget.items;
      });
      return;
    }

    if (val != null && val.isNotEmpty) {
      List<MultiSelectItem<V>> filteredItems = [];
      for (var item in widget.items) {
        if (item.label.toLowerCase().contains(val.toLowerCase())) {
          filteredItems.add(item);
        }
      }
      setState(() {
        _items = filteredItems;
      });
    }
  }

  Widget _buildItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        label: Text(item.label),
        selected: _selectedValues.contains(item.value),
        onSelected: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.searchable == false
          ? Text(widget.title)
          : Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _showSearch
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Search",
                              ),
                              onChanged: (val) {
                                _updateSearchQuery(val);
                              },
                            ),
                          ),
                        )
                      : Text(widget.title),
                  IconButton(
                    icon: _showSearch ? const Icon(Icons.close) : const Icon(Icons.search),
                    onPressed: () {
                      onSearchTap();
                    },
                  ),
                ],
              ),
            ),
      content: Wrap(
        children: _items.map((item) => _buildItem(item)).toList(),
      ),
      actions: <Widget>[
        FlatButton(
          child: widget.cancelText != null ? Text(widget.cancelText) : const Text('CANCEL'),
          onPressed: () {
            widget.onCancelTap(context, widget.initialSelectedItems);
          },
        ),
        FlatButton(
          child: widget.confirmText != null ? Text(widget.confirmText) : const Text('OK'),
          onPressed: () {
            widget.onConfirmTap(context, _selectedValues, widget.onConfirm, 0);
          },
        )
      ],
    );
  }
}
