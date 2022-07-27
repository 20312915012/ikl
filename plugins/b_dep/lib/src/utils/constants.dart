enum enumListType {
  simpleList,
  oneItemList,
  pageList,
}

enum enumBSFieldType { SINGLE_LINE_TEXT, PARAGRAPH, IMAGE, VIDEO, ATTACHMENT, DATE_AND_TIME, NUMBER, EXTERNAL_API }

enum enumBSDateTimeFieldProperty {
  ONLY_DATE,
  ONLY_TIME,
  DATE_N_TIME,
  AUTO_CREATE_ONLY_DATE,
  AUTO_CREATE_ONLY_TIME,
  AUTO_CREATE_DATE_N_TIME,
}
enum enumBSDateFormatType { LOCAL, FRIENDLY, US, EUROPEAN, ISO }
enum enumBSTimeFormatType {
  x24_HOUR, //24Hour
  x12_HOUR, //12Hour
}

enum enumStackCompType { Stack, Column, Row }

enum MultiSelectDialogType { LIST, CHIP }
