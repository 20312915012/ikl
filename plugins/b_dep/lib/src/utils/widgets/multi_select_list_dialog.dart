import 'package:flutter/material.dart';

import 'package:b_dep/src/utils/b_stateful_widget.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'multi_select_widgets/multi_select_widgets.dart';

class MultiSelectListDialog<V> extends BStatefulWidget with MultiSelectDialogActions<V> {
  final List<MultiSelectItem<V>> items;
  final List<V> initialSelectedItems;
  final String title;
  final void Function(List<V>) onSelectionChanged;
  final void Function(List<V>, int) onConfirm;
  final bool searchable;
  final String confirmText;
  final String cancelText;
  bool isOnlyOneChildAllowed;
  bool isArgAddShow;

  MultiSelectListDialog({
    @required this.items,
    this.initialSelectedItems,
    @required this.title,
    this.onSelectionChanged,
    this.onConfirm,
    this.searchable,
    this.confirmText,
    this.cancelText,
    this.isArgAddShow = true,
    this.isOnlyOneChildAllowed = false,
  });

  @override
  BState<BStatefulWidget> createState() => _MultiSelectListDialogState<V>(items);
}

class _MultiSelectListDialogState<V> extends BState<MultiSelectListDialog<V>> {
  List<V> _selectedValues = List<V>();
  bool _showSearch = false;
  List<MultiSelectItem<V>> _items;
  int addNewVarNum = 0;

  _MultiSelectListDialogState(this._items);

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.only(top: 10, bottom: 10),
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
      contentPadding: const EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
          child: Column(
        children: columnChildren(),
      ) /*ListTileTheme(
            contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
            child: ListBody(
              children: _items.map(_buildItem).toList(),
            ),
          ),*/
          ),
      actions: <Widget>[
        const Spacer(),
        FlatButton(
          child: widget.cancelText != null ? Text(widget.cancelText) : const Text('CANCEL'),
          onPressed: () {
            widget.onCancelTap(context, widget.initialSelectedItems);
          },
        ),
        FlatButton(
          child: widget.confirmText != null ? Text(widget.confirmText) : const Text('OK'),
          onPressed: () {
            if (widget.onConfirmTap != null) {
              if (widget.onConfirmTap != null) {
                widget.onConfirmTap(context, _selectedValues, widget.onConfirm, addNewVarNum);
              }
            }
          },
        )
      ],
    );
  }

  List<Widget> columnChildren() {
    List<Widget> widgetList = List();
    Map<String, List<Widget>> widgetChildrenList = Map<String, List<Widget>>();
    bool isStickyHeaderNull = true;

    _items.forEach((MultiSelectItem<V> item) {
      if (item.stickyHeaderLabel != null) {
        if (!widgetChildrenList
            .containsKey(item.stickyHeaderLabel) /*!stickyHeaderList.contains(item.stickyHeaderLabel)*/) {
          isStickyHeaderNull = false;
          List<Widget> tempList = [_buildItem(item)];
          widgetChildrenList[item.stickyHeaderLabel] = tempList.toList();
        } else {
          widgetChildrenList[item.stickyHeaderLabel].add(_buildItem(item));
        }
      }
    });

    if (!isStickyHeaderNull) {
      widgetChildrenList.forEach((stickyHeaderLabel, childrenWidget) {
        widgetList.add(StickyHeader(
          header: Container(
            height: 25.0,
            color: const Color(0xFFF8F8F8), //.blueGrey[700],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stickyHeaderLabel}',
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),
                const Text(
                  'TABLE',
                  style: TextStyle(color: Colors.black26, fontSize: 10),
                ),
              ],
            ),
          ),
          content: ListTileTheme(
            contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
            child: ListBody(
              children: childrenWidget,
            ),
          ),
        ));
      });
    } else {
      widgetList.add(ListTileTheme(
        contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
        child: ListBody(
          children: _items.map(_buildItem).toList(),
        ),
      ));
    }
    return widgetList;
  }

  Widget _buildItem(MultiSelectItem<V> item) {
    if (item.label.contains("Clusters")) {
      return CheckboxListTile(
        value: _selectedValues.contains(item.value),
        title: Text(item.label),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setState(() {
            if (!widget.isOnlyOneChildAllowed) {
              _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
            } else {
              _selectedValues.clear();
              _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
            }
          });
        },
      );
    } else {
      return CheckboxListTile(
        value: _selectedValues.contains(item.value),
        title: Text(item.label),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setState(() {
            if (!widget.isOnlyOneChildAllowed) {
              _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
            } else {
              _selectedValues.clear();
              _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
            }
          });
        },
      );
    }
  }

  @override
  void updateValues() {
    // TODO: implement updateValues
  }
}
