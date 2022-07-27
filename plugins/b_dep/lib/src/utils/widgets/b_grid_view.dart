import 'dart:async';
import 'dart:convert';

import 'package:b_dep/b_dep.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:b_dep/src/utils/variables.dart' as variables;

class BGridView extends BStatefulWidget {
  BGridView({
    Key key,
    String id,
    double width,
    double height,
    double paddingLeft,
    double paddingRight,
    double paddingTop,
    double paddingBottom,
    bool isHide = false,
    this.itPaddingLeft,
    this.itPaddingRight,
    this.itPaddingTop,
    this.itPaddingBottom,
    this.scrollDirection,
    this.shrinkWrap,
    this.itemCount,
    this.gridDelegate,
    this.itemBuilder,
    this.listTypeEnumStr,
    this.isMakeMeDynamic,
    this.backendConnectStr,
    this.backendSendStr,
    this.backendUserAgentStr,
    this.widgetName,
    this.pageIndex,
    this.isUpdate,
    this.scrollListener,
    this.onBottomReached,
    this.onTopReached,
    this.onScrollDown,
    this.onScrollUp,
    this.onPageScroll,
    this.onDefaultPropUpdate,
    this.onPropertiesUpdate,
    this.extraData,
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

  Axis scrollDirection = Axis.vertical;
  bool shrinkWrap = false;
  bool isMakeMeDynamic = false;
  final String listTypeEnumStr;
  final String backendConnectStr;
  final String backendSendStr;
  final String backendUserAgentStr;
  final String widgetName;
  dynamic extraData;

  String itemCount = "0";
  String pageIndex;
  bool isUpdate;
  double itPaddingLeft, itPaddingRight, itPaddingTop, itPaddingBottom;

  Function scrollListener;
  Function onBottomReached;
  Function onTopReached;
  Function onScrollUp;
  Function onScrollDown;
  Function onPageScroll;
  final Function onDefaultPropUpdate;
  final Function onPropertiesUpdate;

  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;

  @override
  BState<BStatefulWidget> createState() => BGridViewState();
}

class BGridViewState extends BState<BGridView> {
  GlobalKey key = GlobalKey();
  bool isScrollViewReachedBottom = true;
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();
  BuildContext contextForProvider;

  double width, height;
  WebSocketChannel
      channel; // = WebSocketChannel.connect(widget.backendConnectStr/*"wss://6hylq4bfbb.execute-api.ap-south-1.amazonaws.com/prod"*/);

  Timer scrollTimer;
  double previousPixels = 0;
  bool mIsUpdateList = true;
  IndexedWidgetBuilder mItemBuilder;

  String mPageIndex, mPageIndexOnPageScroll;

  ///This boolean makes sure to block updating the
  ///[mPageIndexOnPageScroll]-variable so that
  ///the [scrollController.animateTo] may work correctly.
  bool isBlockUpdatePageIndexOnScroll = false;

  @override
  void initState() {
    super.initState();
    setInitScrollListener();
    updateOnEventBusFire();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    if (kIsWeb) {
      channel = WebSocketChannel.connect(
        Uri.parse(widget.backendConnectStr),

        ///TODO: add headers to WebSocket to function properly with Flutter Web & Mobile.
        //headers: {"User-Agent": mBackendUserAgentStr}
      );
    } else {
      channel = IOWebSocketChannel.connect(Uri.parse(widget.backendConnectStr),
          headers: {"User-Agent": widget.backendUserAgentStr});
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    if (channel != null) {
      channel.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrUtilConversion();
    if (widget.isUpdate != null && mIsUpdateList != widget.isUpdate) {
      mIsUpdateList = widget.isUpdate;
    } else if (widget.isUpdate == null) {
      mIsUpdateList = true;
    }

    /*if(widget.itemBuilder!=null&&mItemBuilder.toString()!=mItemBuilder.toString()){
        mIsUpdateList=true;
      }*/

    if (mPageIndex.toString() != widget.pageIndex.toString() ||
        (mPageIndexOnPageScroll != null && mPageIndexOnPageScroll.toString() != mPageIndex.toString()) ||
        isBlockUpdatePageIndexOnScroll) {
      // print("mUpdate0>> " +
      //     mPageIndex.toString() +
      //     " >> " +
      //     widget.pageIndex.toString() +
      //     " >> " +
      //     mPageIndexOnPageScroll.toString());
      if (mPageIndexOnPageScroll != null) {
        isBlockUpdatePageIndexOnScroll = true;
      } else {
        isBlockUpdatePageIndexOnScroll = false;
      }
      if (mPageIndexOnPageScroll != null && mPageIndexOnPageScroll.toString() != mPageIndex.toString()) {
        mPageIndex = mPageIndexOnPageScroll;
      } else {
        mPageIndex = widget.pageIndex;
      }
      //mPageIndex = mPageIndexOnPageScroll ?? widget.pageIndex;
      mPageIndexOnPageScroll = null;
      //mPageIndexOnPageScroll = widget.pageIndex;
      mIsUpdateList = true;
      if (mPageIndex != null && pageController != null && pageController.positions.length > 0) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          pageController.animateToPage(int.parse(mPageIndex),
              duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
        });
      }
    }
    if (mIsUpdateList) {
      PropertyUtils().updateProperties(widget);
    }
    if (widget.isHide) {
      return const SizedBox.shrink();
    }
    //getIsScrollViewReachedBottom();
    //print("mUpdate>> "+mIsUpdateList.toString());
    if (key.currentWidget == null || (mIsUpdateList)) {
      mIsUpdateList = false;
      return Padding(
        key: key,
        padding: EdgeInsets.only(
          left: widget.paddingLeft ?? 0,
          right: widget.paddingRight ?? 0,
          top: widget.paddingTop ?? 0,
          bottom: widget.paddingBottom ?? 0,
        ),
        child: getWidget(),
      );
    } else {
      return key.currentWidget;
    }
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    if (variables.blupVersion.toString() != "null") {
      if (widget.width != widget.height) {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setHeight(widget.height);
      } else {
        widget.width = widget.width == null ? null : ScreenUtil().setWidth(widget.width);
        widget.height = widget.height == null ? null : ScreenUtil().setWidth(widget.height);
      }
    }
  }

  Widget getWidget() {
    ///TODO: Import provider, web_socket
    backendCaller();
    return StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (!snapshot.data.toString().contains('"message": "Internal server error"') &&
              snapshot.data.toString() != "null") {
            //print("webSocket data>>" + snapshot.data.toString()+" >>>> "+jsonDecode(snapshot.data)["result"].toString());
            onSnapshotReceived(snapshot);

            ///-------------------
            ///
            /// var provider=Provider.of<List<dynamic>>(context,listen: false);
            ///
            /// if(provider.length>0) {
            ///    print("AWS VALUE IN PROVIDER>>>> " + provider[index]["Image3"].toString());
            /// }
            ///
            ///-------------------
          }
          return Provider(
              create: (_) => <dynamic>[],
              child: Builder(builder: (context) {
                contextForProvider = context;
                return getListWidget();
              }));
        });
  }

  void onSnapshotReceived(var snapshot) {
    if (!jsonDecode(snapshot.data)['id'].toString().contains("subscription")) {
      isAwsReturnedResponse = true;
      List<dynamic> as = jsonDecode(snapshot.data)['result'] as List;
      Provider.of<List<dynamic>>(contextForProvider, listen: false).clear();
      Provider.of<List<dynamic>>(contextForProvider, listen: false).addAll(as);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (int.parse(widget.itemCount == null || widget.itemCount == "null" ? "0" : widget.itemCount) != as.length) {
          setState(() {
            widget.itemCount = as.length.toString();
          });
        }
      });
    } else if (jsonDecode(snapshot.data)['id'].toString().contains("subscription")) {
      if (jsonDecode(snapshot.data)['result']["tableName"].toString().contains(widget.widgetName)) {
        backendCaller();
      }
    }
  }

  void backendCaller() {
    if (widget.isMakeMeDynamic) {
      //channel.sink.add(widget.backendSendStr);
      shootTOAws(widget.backendSendStr);
    }
  }

  int numOfAwsRetryThreshold = 10;
  int awsRetryCount = 0;
  bool isAwsReturnedResponse = false;
  Timer retryTimer;
  void shootTOAws(String awsShootStr) {
    //print("AWSRetryCountOUT>>> "+awsRetryCount.toString());
    if (retryTimer == null && !isAwsReturnedResponse && awsRetryCount < numOfAwsRetryThreshold) {
      channel.sink.add(awsShootStr);
      //print("AWSRetryCount>>> "+awsRetryCount.toString());
      awsRetryCount++;
    }

    retryTimer = Timer(Duration(milliseconds: (200 * awsRetryCount)), () {
      if (!isAwsReturnedResponse && awsRetryCount < numOfAwsRetryThreshold) {
        ///Retry.
        shootTOAws(awsShootStr);
      } else {
        ///Done.
        awsRetryCount = 0;
        isAwsReturnedResponse = false;
      }
      retryTimer = null;
    });
  }

  Widget getMainWidget() {
    mIsUpdateList = false;
    return getListWidget();
  }

  Widget getListWidget() {
    if(int.parse(widget.itemCount == null || widget.itemCount == "null" ? "0" : widget.itemCount)==0){
      return const SizedBox.shrink();
    }else {
      return widget.listTypeEnumStr == enumListType.simpleList.toString()
          ? GridView.builder(
              ///SimpleList
              //key: key,
              padding: EdgeInsets.only(
                left: widget.itPaddingLeft ?? 0,
                right: widget.itPaddingRight ?? 0,
                top: widget.itPaddingTop ?? 0,
                bottom: widget.itPaddingBottom ?? 0,
              ),
              physics: isScrollViewReachedBottom
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              shrinkWrap: widget.shrinkWrap,
              scrollDirection: widget.scrollDirection,
              itemCount: int.parse(
                  widget.itemCount == null || widget.itemCount == "null"
                      ? "0"
                      : widget.itemCount),
              gridDelegate: widget.gridDelegate,
              itemBuilder: widget.itemBuilder,
              controller: scrollController,
            )
          : (widget.listTypeEnumStr == enumListType.oneItemList.toString()
              ? (PageView.builder(
                  ///OneItemList
                  //key: key,
                  physics: isScrollViewReachedBottom
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  scrollDirection: widget.scrollDirection,
                  itemCount: int.parse(
                      widget.itemCount == null || widget.itemCount == "null"
                          ? "0"
                          : widget.itemCount),
                  itemBuilder: widget.itemBuilder,
                  controller: pageController,
                  onPageChanged: (pageIndex) {
                    if (!isBlockUpdatePageIndexOnScroll) {
                      mPageIndexOnPageScroll = pageIndex.toString();
                    }
                    if (widget.onPageScroll != null) {
                      widget.onPageScroll(pageIndex);
                    }
                  },
                ))
              : PageView.builder(
                  ///PageList
                  //key: key,
                  physics: isScrollViewReachedBottom
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  scrollDirection: widget.scrollDirection,
                  itemCount: int.parse(
                      widget.itemCount == null || widget.itemCount == "null"
                          ? "0"
                          : widget.itemCount),
                  itemBuilder: widget.itemBuilder,
                  controller: pageController,
                  onPageChanged: (pageIndex) {
                    if (!isBlockUpdatePageIndexOnScroll) {
                      mPageIndexOnPageScroll = pageIndex.toString();
                    }
                    if (widget.onPageScroll != null) {
                      widget.onPageScroll(pageIndex);
                    }
                  },
                ));
    }
  }

  getSizeAndPosition() {
    RenderBox _targetBox = context.findRenderObject();
    width = _targetBox.size.width;
    height = _targetBox.size.height;
  }

  void getIsScrollViewReachedBottom() {
    if (InheritedScrollDataProvider.of<Map<String, String>>(context) != null) {
      if (InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"] != "null") {
        var isScrollViewReachedBottomVar =
            InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"].toString() !=
                "false";
        var isDirectionSame =
            InheritedScrollDataProvider.of<Map<String, String>>(context).value["scrollViewAxis"].toString() ==
                widget.scrollDirection.toString();
        if (!isScrollViewReachedBottomVar) {
          isScrollViewReachedBottomVar = !isDirectionSame;
          if (isScrollViewReachedBottomVar != isScrollViewReachedBottom && isScrollViewReachedBottomVar == true) {
            isScrollViewReachedBottom = isScrollViewReachedBottomVar;
          } else {
            isScrollViewReachedBottom = isScrollViewReachedBottomVar;
          }
        } else {
          isScrollViewReachedBottom = isScrollViewReachedBottomVar;

          if (scrollController.positions.length > 0 && isDirectionSame) {
            scrollController.animateTo(scrollController.position.pixels + 200,
                curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
          }
          if (pageController.positions.length > 0 && isDirectionSame) {
            pageController.animateTo(pageController.position.pixels + 200,
                curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
          }
        }
        if (isScrollViewReachedBottom && widget.onBottomReached != null) {
          widget.onBottomReached;
        }
      }
    }
  }

  void setInitScrollListener() {
    scrollController.addListener(() {
      if (InheritedScrollDataProvider.of<Map<String, String>>(context) != null) {
        if (scrollController.position.pixels < 1) {
          var isDirectionSame =
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["scrollViewAxis"].toString() ==
                  widget.scrollDirection.toString();
          if (isDirectionSame &&
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"].toString() ==
                  "true") {
            setState(() {
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"] = "false";
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["scrollViewAxis"] =
                  widget.scrollDirection.toString();
              if (widget.onTopReached != null) {
                widget.onTopReached;
              }
            });
          }
        }
      }
      if (scrollTimer != null) {
        scrollTimer.cancel();
        if (previousPixels != scrollController.position.pixels) {
          ///Is scrolling.
          if (previousPixels < scrollController.position.pixels) {
            ///Is scrolling Down.
            if (widget.onScrollDown != null) {
              widget.onScrollDown;
            }
          } else {
            ///Is scrolling Up.
            if (widget.onScrollUp != null) {
              widget.onScrollUp;
            }
          }
          previousPixels = scrollController.position.pixels;
        }
      }
      scrollTimer = Timer(const Duration(milliseconds: 170), () {
        ///Not scrolling.
        previousPixels = scrollController.position.pixels;
      });
      if (widget.scrollListener != null) {
        widget.scrollListener(scrollController.position.pixels);
      }
    });
    pageController.addListener(() {
      if (InheritedScrollDataProvider.of<Map<String, String>>(context) != null) {
        if (pageController.position.pixels < 1) {
          var isDirectionSame =
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["scrollViewAxis"].toString() ==
                  widget.scrollDirection.toString();
          if (isDirectionSame &&
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"].toString() ==
                  "true") {
            setState(() {
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["isScrollViewAtEnd"] = "false";
              InheritedScrollDataProvider.of<Map<String, String>>(context).value["scrollViewAxis"] =
                  widget.scrollDirection.toString();
              if (widget.onTopReached != null) {
                widget.onTopReached;
              }
            });
          }
        }
      }
    });
  }

  void updateOnEventBusFire() {
    variables.eventBusOnTapForList.on<EBOnTapTapForList>().listen((EBOnTapTapForList event) {
      if (event.listId == widget.id) {
        var scrollTo = event.scrollTo.replaceAll("to ", "");
        var scrollItemDimension = ((widget.scrollDirection == Axis.horizontal) ? width : height);
        switch (scrollTo) {
          case "Previous":
            if (pageController.positions.length > 0) {
              pageController.previousPage(curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            } else {
              scrollController.animateTo(scrollController.position.pixels - scrollItemDimension,
                  curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            }
            break;
          case "Next":
            if (pageController.positions.length > 0) {
              pageController.nextPage(curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            } else {
              scrollController.animateTo(scrollController.position.pixels + scrollItemDimension,
                  curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            }
            break;
          default:
            if (pageController.positions.length > 0) {
              pageController.animateToPage(int.parse(scrollTo) - 1,
                  curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            } else {
              //double scrollTo = scrollController.offset>(int.parse(scrollTo)-1)*height?;
              scrollController.animateTo((double.parse(scrollTo) - 1) * scrollItemDimension,
                  curve: Curves.decelerate, duration: const Duration(milliseconds: 300));
            }
            break;
        }
      }
    });
  }

  @override
  void updateValues() {
    if (widget.onDefaultPropUpdate != null) {
      widget.onDefaultPropUpdate(
        widget.isUpdate,
        widget.itemCount,
        widget.isHide,
        widget.extraData,
      );
    }
    if (widget.onPropertiesUpdate != null) {
      if (widget.listTypeEnumStr == enumListType.simpleList.toString()) {
        widget.onPropertiesUpdate(
          widget.width,
          widget.height,
          widget.paddingLeft,
          widget.paddingRight,
          widget.paddingTop,
          widget.paddingBottom,
          widget.itPaddingLeft,
          widget.itPaddingRight,
          widget.itPaddingTop,
          widget.itPaddingBottom,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).mainAxisSpacing,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisSpacing,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).childAspectRatio,
        );
      } else {
        widget.onPropertiesUpdate(
          mPageIndex,
          widget.width,
          widget.height,
          widget.paddingLeft,
          widget.paddingRight,
          widget.paddingTop,
          widget.paddingBottom,
          widget.itPaddingLeft,
          widget.itPaddingRight,
          widget.itPaddingTop,
          widget.itPaddingBottom,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).mainAxisSpacing,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisSpacing,
          (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).childAspectRatio,
        );
      }
    }
  }
}
