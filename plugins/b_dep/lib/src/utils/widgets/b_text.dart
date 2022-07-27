import 'package:b_dep/b_dep.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;

enum TextWrap{
  autoWidth,
  autoHeight,
  fixedSize,
}

typedef void BTextFieldOnSubmitted(String text);
typedef void BTextFieldOnTextChanged(String text);
typedef void BTextFieldMText(TextEditingController textEditingController);

class BText extends BStatefulWidget {
  BText(
    this.text, {
    Key key,
    String id,
    double width,
    double height,
    double paddingLeft,
    double paddingRight,
    double paddingTop,
    double paddingBottom,
    bool isHide = false,
    this.style,
    this.isDataFromBSheets = false,
    this.bSheetsColumnName,
    this.isTextField = false,
    this.isEllipsis,
    this.isParagraphEditor,
    this.isAdjustWithKeyboard,
    this.isPasswordField,
    this.maxLines,
    this.backgroundColor,
    this.hintText,
    this.hintColor,
    this.borderFocusedColor,
    this.borderUnFocusedColor,
    this.borderFocusedWidth,
    this.borderUnFocusedWidth,
    this.borderFocusedRadius,
    this.borderUnFocusedRadius,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.tfPaddingLeft,
    this.tfPaddingRight,
    this.tfPaddingTop,
    this.tfPaddingBottom,
    this.textAlign,
    this.textWrap,
    this.textFieldWidth,
    this.textFieldHeight,
    this.onSubmitted,
    this.onTextChanged,
    this.onPropertiesUpdate,
    this.onTextDefaultPropUpdate,
    this.onTextExtraPropUpdate,
    this.onTextfieldDefaultPropUpdate,
    this.onTextfieldExtraPropUpdate,
    this.currentText,
    this.lineHeight,
    this.letterSpacing,
    this.inputType,
    this.isTextSelectable = false,
    this.extraData,
    this.index,
    this.onClick,
  }) : super(
          key: key,
          id: id,
          width: width,
          height: height,
          paddingLeft: paddingLeft,
          paddingRight: paddingRight,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          isHide: isHide,
        );

  final String text;
  final TextStyle style;
  bool isDataFromBSheets;
  String bSheetsColumnName;
  dynamic extraData;

  int index;

  final bool isTextField;
  final bool isEllipsis;
  final bool isParagraphEditor;
  final bool isPasswordField;
  final bool isAdjustWithKeyboard;
  final int maxLines;
  //final enum textInputType;
  final Color backgroundColor;
  final String hintText;
  final Color hintColor;
  //final enum borderType;
  final Color borderFocusedColor;
  final Color borderUnFocusedColor;
  final double borderFocusedWidth;
  final double borderUnFocusedWidth;
  final double borderFocusedRadius;
  final double borderUnFocusedRadius;
  final Color cursorColor;
  final double cursorWidth;
  final double cursorHeight;
  final double cursorRadius;
  double textFieldWidth;
  double textFieldHeight;
  double lineHeight, letterSpacing;
  final double tfPaddingLeft, tfPaddingRight, tfPaddingTop, tfPaddingBottom;
  final TextAlign textAlign;
  final TextInputType inputType;
  final bool isTextSelectable;
  final BTextFieldOnSubmitted onSubmitted;
  final BTextFieldOnTextChanged onTextChanged;
  final BTextFieldMText currentText;
  final Function onPropertiesUpdate;
  final Function onTextExtraPropUpdate, onTextDefaultPropUpdate;
  final Function onTextfieldExtraPropUpdate, onTextfieldDefaultPropUpdate;
  final Function onClick;

  final TextWrap textWrap;

  @override
  BState<BStatefulWidget> createState() => BTextState();
}

class BTextState extends BState<BText> {
  //ZefyrController _zefyrTextController;
  FocusNode _zefyrTextFocusNode;

  TextEditingController textFieldController;
  FocusNode _textFieldFocusNode;

  enumBSFieldType _enumFieldType = enumBSFieldType.SINGLE_LINE_TEXT;
  enumBSDateTimeFieldProperty _enumDateTimeProp = enumBSDateTimeFieldProperty.DATE_N_TIME;
  enumBSDateFormatType _enumDateFormat = enumBSDateFormatType.LOCAL;
  enumBSTimeFormatType _enumTimeFormat = enumBSTimeFormatType.x12_HOUR;

  @override
  void initState() {
    super.initState();
    //initializeDateFormatting();
    _zefyrTextFocusNode = FocusNode();
    _textFieldFocusNode = FocusNode();
    if (widget.isTextField) {
      if (widget.isDataFromBSheets) {
        textFieldController = TextEditingController(text: widget.text ?? "");
      } else {
        textFieldController = TextEditingController(text: widget.text);
      }
    }
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
    _initEnumForBSheets();
    if (widget.isHide) {
      return const SizedBox();
    } else {
      return getWidgetEngine();
    }
  }

  void _initEnumForBSheets() {
    if (widget.isDataFromBSheets) {
      String rawColName = bHelperFunctions.getRawColName(context, widget.bSheetsColumnName);
      _enumFieldType = _getBSEnumFieldType(rawColName);
      _enumDateTimeProp = _getBSEnumDateTimeFieldProp(rawColName);
      _enumDateFormat = _getBSEnumDateFormatType(rawColName);
      _enumTimeFormat = _getBSEnumTimeFormatType(rawColName);
    }
  }

  Widget getWidgetEngine() {
    if (!widget.isDataFromBSheets && !widget.isTextField) {
      if (textFieldController?.text == null || textFieldController?.text != widget.text) {
        PropertyUtils().updateProperties(widget);
      }
    }
    if (widget.isTextField) {
      return getTextFieldWidgetEngine();
    } else {
      return SizedBox(
        width: widget.textWrap!=TextWrap.autoWidth?widget.width:null,
        height: widget.textWrap==TextWrap.fixedSize?widget.height:null,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.paddingLeft ?? 0,
            right: widget.paddingRight ?? 0,
            top: widget.paddingTop ?? 0,
            bottom: widget.paddingBottom ?? 0,
          ),
          child: getTextWidgetEngine(),
        ),
      );
    }
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    if (variables.blupVersion.toString() != "null") {
      if (widget.textFieldWidth != widget.textFieldHeight) {
        widget.textFieldWidth = widget.textFieldWidth == null ? null : ScreenUtil().setWidth(widget.textFieldWidth);
        widget.textFieldHeight = widget.textFieldHeight == null ? null : ScreenUtil().setHeight(widget.textFieldHeight);
      } else {
        widget.textFieldWidth = widget.textFieldWidth == null ? null : ScreenUtil().setWidth(widget.textFieldWidth);
        widget.textFieldHeight = widget.textFieldHeight == null ? null : ScreenUtil().setWidth(widget.textFieldWidth);
      }

      if (widget.width != widget.height) {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setHeight(widget.height);
      } else {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setWidth(widget.width);
      }
    }
  }

  Widget getTextFieldWidgetEngine() {
    if (widget.isAdjustWithKeyboard != null && widget.isAdjustWithKeyboard == true) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          getNormalTextField(),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      );
    } else {
      return getNormalTextField();
    }
  }

  Widget getTextWidgetEngine() {
    // ignore: missing_enum_constant_in_switch
    if (widget.isTextSelectable) {
      return getSelectableText();
    }

    switch (_enumFieldType) {
      case enumBSFieldType.SINGLE_LINE_TEXT:
        return getNormalText();
        break;
      case enumBSFieldType.PARAGRAPH:
        return getParagraphText();
        break;
      case enumBSFieldType.DATE_AND_TIME:
        return getDateTimeWidget();
        break;
      case enumBSFieldType.NUMBER:
        return getNormalText();
        break;
    }
    return getNormalText();
  }

  Widget getSelectableText() {
    return SelectableText(widget.text,
        maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
        // overflow: widget.isEllipsis == null || !widget.isEllipsis
        //     ? null
        //     : TextOverflow.ellipsis,
        style: widget.style,
        textAlign: widget.textAlign);
  }

  GlobalKey _textFieldKey = GlobalKey();
  String textFromWidget;
  List<TextInputFormatter> inputFormatters;

  void setInputFormatters(TextInputType inputType) {
    if (inputType == TextInputType.number) {
      inputFormatters = [
        FilteringTextInputFormatter.deny(RegExp('[a-zA-Z]')),
        FilteringTextInputFormatter.deny(RegExp('[`~!@#\$%^&*()_=]')),
        FilteringTextInputFormatter.deny(RegExp('[{}\[\]\\|;:\'",<>/?]')),
      ];
    } else if (inputType == TextInputType.phone) {
      inputFormatters = [
        FilteringTextInputFormatter.deny(RegExp('[a-zA-Z]')),
        FilteringTextInputFormatter.deny(RegExp('[`~!@#\$%^&*()_\\-\\=]')),
        FilteringTextInputFormatter.deny(RegExp('[{}\[\]\\|;:\'",<.>/?]')),
      ];
    } else if (inputType == TextInputType.name) {
      inputFormatters = [
        FilteringTextInputFormatter.deny(RegExp('[0-9]')),
        FilteringTextInputFormatter.deny(RegExp('[`~!@#\$%^&*()_+\\-\\=]')),
        FilteringTextInputFormatter.deny(RegExp('[{}\[\]\\|;:\'",<.>/?]')),
      ];
    } else {
      inputFormatters = [];
    }
  }

  Widget getNormalTextField() {
    //if (widget.isDataFromBSheets) {
    if (widget.text != null && (textFromWidget == null || textFromWidget != widget.text)) {
      if (!_textFieldFocusNode.hasFocus) {
        textFromWidget = widget.text;
        textFieldController.text = widget.text;
        PropertyUtils().updateProperties(widget);
      }
    }
    if (inputFormatters == null) {
      setInputFormatters(widget.inputType);
    }
    //}
    return SizedBox(
      width: widget.textFieldWidth,
      height: widget.textFieldHeight,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.paddingLeft ?? 0,
          right: widget.paddingRight ?? 0,
          top: widget.paddingTop ?? 0,
          bottom: widget.paddingBottom ?? 0,
        ),
        child: _textFieldKey.currentWidget ??
            TextField(
              key: _textFieldKey,
              textAlign: widget.textAlign,
              keyboardType: widget.inputType,
              style: widget.style,
              controller: textFieldController,
              focusNode: _textFieldFocusNode,
              obscureText: widget.isPasswordField,
              maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
              cursorColor: widget.cursorColor,
              cursorWidth: widget.cursorWidth,
              //cursorHeight: ((widget.cursorHeight==0.0)?null:widget.cursorHeight),
              cursorRadius: Radius.circular(widget.cursorRadius),
              onSubmitted: (text) {
                textFromWidget = text;
                PropertyUtils().updateProperties(widget);
                if (widget.onSubmitted != null) {
                  widget.onSubmitted(text);
                }
              },
              onChanged: (text) {
                textFromWidget = text;
                PropertyUtils().updateProperties(widget);
                if (widget.onTextChanged != null) {
                  widget.onTextChanged(text);
                }
                if (widget.currentText != null) {
                  widget.currentText(textFieldController);
                }
              },
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: widget.tfPaddingLeft,
                  right: widget.tfPaddingRight,
                  top: widget.tfPaddingTop,
                  bottom: widget.tfPaddingBottom,
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.hintColor,
                ),
                filled:
                    widget.backgroundColor == null || widget.backgroundColor.toString().contains("0x00") ? false : true,
                border: widget.backgroundColor == null || widget.backgroundColor.toString().contains("0x00")
                    ? null
                    : InputBorder.none,
                fillColor: widget.backgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderUnFocusedRadius ?? widget.borderFocusedRadius),
                  borderSide: BorderSide(
                    color: widget.borderUnFocusedColor ?? widget.borderFocusedColor,
                    width: widget.borderUnFocusedWidth ?? widget.borderFocusedWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderFocusedRadius),
                  borderSide: BorderSide(
                    color: widget.borderFocusedColor,
                    width: widget.borderFocusedWidth,
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget getNormalText() {
    return MouseRegion(
      cursor: widget.onClick != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: () {
          if (widget.onClick != null) {
            if (widget.index != null) {
              widget.onClick(widget.index, widget.text);
            } else {
              widget.onClick(widget.text);
            }
          }
        },
        child: Text(widget.text,
            maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
            overflow: widget.isEllipsis == null || !widget.isEllipsis ? null : TextOverflow.ellipsis,
            style: widget.style,
            textAlign: widget.textAlign),
      ),
    );
  }

  Widget getDateTimeWidget() {
    if (_enumDateTimeProp == enumBSDateTimeFieldProperty.DATE_N_TIME ||
        _enumDateTimeProp == enumBSDateTimeFieldProperty.AUTO_CREATE_DATE_N_TIME) {
      return Text(
          getDateFormatedString(widget.text) +
              (getDateFormatedString(widget.text).length > 0 ? " " : "") +
              getTimeFormatedString(widget.text),
          maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
          overflow: widget.isEllipsis == null || !widget.isEllipsis ? null : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign);
    } else if (_enumDateTimeProp == enumBSDateTimeFieldProperty.ONLY_DATE ||
        _enumDateTimeProp == enumBSDateTimeFieldProperty.AUTO_CREATE_ONLY_DATE) {
      return Text(getDateFormatedString(widget.text),
          maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
          overflow: widget.isEllipsis == null || !widget.isEllipsis ? null : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign);
    } else if (_enumDateTimeProp == enumBSDateTimeFieldProperty.ONLY_TIME ||
        _enumDateTimeProp == enumBSDateTimeFieldProperty.AUTO_CREATE_ONLY_TIME) {
      return Text(getTimeFormatedString(widget.text),
          maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
          overflow: widget.isEllipsis == null || !widget.isEllipsis ? null : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign);
    } else {
      return Text(
          getDateFormatedString(widget.text) +
              (getDateFormatedString(widget.text).length > 0 ? " " : "") +
              getTimeFormatedString(widget.text),
          maxLines: widget.maxLines == null || widget.maxLines <= 0 ? null : widget.maxLines,
          overflow: widget.isEllipsis == null || !widget.isEllipsis ? null : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign);
    }
  }

  Widget getParagraphText() {
//      final document = _loadDocument();
    //_zefyrTextController = ZefyrController(document);
    return /*ZefyrScaffold(
          child: */
        Theme(
      data: ThemeData(
        primaryColorBrightness: Brightness.light,
      ),
//            child: ZefyrEditor(
//              controller: _zefyrTextController,
//              focusNode: _zefyrTextFocusNode,
//              //mode: ZefyrMode.select,
//              padding: EdgeInsets.all(16),
//              //physics: BouncingScrollPhysics(),
//              //imageDelegate: MyAppZefyrImageDelegate(),
//            ),
      /*)*/
    ); //Text(widget.text,style: widget.style,);
  }

//    NotusDocument _loadDocument() {
//      if(widget.text==null){
//        final Delta delta = Delta()..insert("Start here...\n");
//        return NotusDocument.fromDelta(delta);
//      }else if(widget.text.contains('[{"insert":"')){
//        return NotusDocument.fromJson(jsonDecode(widget.text));
//      }else{
//        final Delta delta = Delta()..insert(widget.text+"\n");
//        return NotusDocument.fromDelta(delta);
//      }
//    }

  String getDateFormatedString(String text) {
    String textFormated = "";
    if (text != null) {
      DateTime date = DateTime.parse(_ignoreSubMicro(text));
      if (_enumDateFormat == enumBSDateFormatType.LOCAL) {
        Locale myLocale = Localizations.localeOf(context);
        String formattedDate = DateFormat.yMd(myLocale.languageCode).format(date);
        textFormated = formattedDate;
      } else if (_enumDateFormat == enumBSDateFormatType.FRIENDLY) {
        String formattedDate = DateFormat.yMMMd().format(date);
        textFormated = formattedDate;
      } else if (_enumDateFormat == enumBSDateFormatType.US) {
        String formattedDate = DateFormat("mm/dd/yyyy").format(date);
        textFormated = formattedDate;
      } else if (_enumDateFormat == enumBSDateFormatType.EUROPEAN) {
        String formattedDate = DateFormat("dd/mm/yyyy").format(date);
        textFormated = formattedDate;
      } else if (_enumDateFormat == enumBSDateFormatType.ISO) {
        String formattedDate = DateFormat("yyyy-mm-dd").format(date);
        textFormated = formattedDate;
      }
    }
    return textFormated;
  }

  String getTimeFormatedString(String text) {
    String textFormated = "";
    if (text != null) {
      if (_enumTimeFormat == enumBSTimeFormatType.x24_HOUR) {
        DateTime date = DateTime.parse(_ignoreSubMicro(text)); //parse(text);
        String formattedTime = DateFormat.Hm().format(date);
        textFormated = formattedTime;
      } else if (_enumTimeFormat == enumBSTimeFormatType.x12_HOUR) {
        DateTime date = DateTime.parse(_ignoreSubMicro(text)); //parse(text);
        String formattedTime = DateFormat.jm().format(date);
        textFormated = formattedTime;
      }
    }
    return textFormated;
  }

  bool isValidDate(String input) {
    try {
      DateTime.parse(_ignoreSubMicro(input));
    } catch (e) {
      return false;
    }
    return true;
  }

  String _ignoreSubMicro(String s) {
    if (s.length > 27) return s.substring(0, 26) + s[s.length - 1];
    return s;
  }

  enumBSFieldType _getBSEnumFieldType(String rawColName) {
    if (rawColName.contains("|type:P")) {
      return enumBSFieldType.PARAGRAPH;
    } else if (rawColName.contains("|type:N")) {
      return enumBSFieldType.NUMBER;
    } else if (rawColName.contains("|type:S_L_T")) {
      return enumBSFieldType.SINGLE_LINE_TEXT;
    } else if (rawColName.contains("|type:D_A_T")) {
      return enumBSFieldType.DATE_AND_TIME;
    } else {
      return enumBSFieldType.SINGLE_LINE_TEXT;
    }
  }

  enumBSDateTimeFieldProperty _getBSEnumDateTimeFieldProp(String rawColName) {
    if (rawColName.contains("|sub1:D_N_T")) {
      return enumBSDateTimeFieldProperty.DATE_N_TIME;
    } else if (rawColName.contains("|sub1:O_D")) {
      return enumBSDateTimeFieldProperty.ONLY_DATE;
    } else if (rawColName.contains("|sub1:O_T")) {
      return enumBSDateTimeFieldProperty.ONLY_TIME;
    } else if (rawColName.contains("|sub1:A_C_D_N_T")) {
      return enumBSDateTimeFieldProperty.AUTO_CREATE_DATE_N_TIME;
    } else if (rawColName.contains("|sub1:A_C_O_D")) {
      return enumBSDateTimeFieldProperty.AUTO_CREATE_ONLY_DATE;
    } else if (rawColName.contains("|sub1:A_C_O_T")) {
      return enumBSDateTimeFieldProperty.AUTO_CREATE_ONLY_TIME;
    } else {
      return enumBSDateTimeFieldProperty.DATE_N_TIME;
    }
  }

  enumBSDateFormatType _getBSEnumDateFormatType(String rawColName) {
    if (rawColName.contains("|sub2:F")) {
      return enumBSDateFormatType.FRIENDLY;
    } else if (rawColName.contains("|sub2:E")) {
      return enumBSDateFormatType.EUROPEAN;
    } else if (rawColName.contains("|sub2:U")) {
      return enumBSDateFormatType.US;
    } else if (rawColName.contains("|sub2:L")) {
      return enumBSDateFormatType.LOCAL;
    } else if (rawColName.contains("|sub2:I")) {
      return enumBSDateFormatType.ISO;
    } else {
      return enumBSDateFormatType.LOCAL;
    }
  }

  enumBSTimeFormatType _getBSEnumTimeFormatType(String rawColName) {
    if (rawColName.contains("|sub3:x12_HOUR")) {
      return enumBSTimeFormatType.x12_HOUR;
    } else if (rawColName.contains("|sub3:x24_HOUR")) {
      return enumBSTimeFormatType.x24_HOUR;
    } else {
      return enumBSTimeFormatType.x12_HOUR;
    }
  }

  @override
  void updateValues() {
    if (widget.onPropertiesUpdate != null) {
      widget.onPropertiesUpdate(
        widget.text,
        widget.isHide,
        widget.style.fontSize,
        widget.style.color,
        widget.isEllipsis,
        widget.isAdjustWithKeyboard,
        widget.isParagraphEditor,
        widget.maxLines,
        widget.backgroundColor,
        widget.hintText,
        widget.hintColor,
        widget.borderFocusedColor,
        widget.borderUnFocusedColor,
        widget.borderFocusedWidth,
        widget.borderUnFocusedWidth,
        widget.borderFocusedRadius,
        widget.borderUnFocusedRadius,
        widget.cursorColor,
        widget.cursorWidth,
        widget.cursorHeight,
        widget.cursorRadius,
      );
    }
    if (widget.onTextDefaultPropUpdate != null) {
      widget.onTextDefaultPropUpdate(
        widget.isTextField ? textFieldController.text : widget.text,
        widget.isHide,
        widget.extraData,
      );
    }

    if (widget.onTextExtraPropUpdate != null) {
      ///If just text-widget, not a TextField.
      widget.onTextExtraPropUpdate(
        widget.style.color,
        widget.style.fontSize,
        widget.maxLines,
        widget.lineHeight,
        widget.letterSpacing,
        widget.paddingLeft,
        widget.paddingRight,
        widget.paddingTop,
        widget.paddingBottom,
        widget.isEllipsis,
      );
    }

    if (widget.onTextfieldDefaultPropUpdate != null) {
      widget.onTextfieldDefaultPropUpdate(
        widget.isHide,
        textFieldController.text ?? widget.text,
        widget.extraData,
      );
    }

    if (widget.onTextfieldExtraPropUpdate != null) {
      if (widget.isTextField) {
        widget.onTextfieldExtraPropUpdate(
          widget.textFieldWidth,
          widget.textFieldHeight,
          widget.hintText,
          widget.hintColor,
          widget.backgroundColor,
          widget.style.color,
          widget.style.fontSize,
          widget.paddingLeft,
          widget.paddingRight,
          widget.paddingTop,
          widget.paddingBottom,
          widget.tfPaddingLeft,
          widget.tfPaddingRight,
          widget.tfPaddingTop,
          widget.tfPaddingBottom,
          widget.maxLines,
          widget.lineHeight,
          widget.letterSpacing,
          widget.borderFocusedColor,
          widget.borderFocusedWidth,
          widget.borderFocusedRadius,
          widget.borderUnFocusedColor,
          widget.borderUnFocusedWidth,
          widget.borderUnFocusedRadius,
          widget.cursorColor,
          widget.cursorWidth,
          widget.cursorHeight,
          widget.cursorRadius,
          widget.isEllipsis,
          widget.isAdjustWithKeyboard,
          widget.isParagraphEditor,
          widget.isPasswordField,
        );
      }
    }
  }
}
