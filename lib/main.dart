import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:event_bus/event_bus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:b_dep/b_dep.dart';
 
import 'package:ikl/custom_code/custom_code.dart';

 
void main() async {
  await initMain();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BView(child: MyHomePage()),
    );
  }
}
 
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
 
class _MyHomePageState extends State<MyHomePage> {
  BuildContext contextFromProvider;

  @override
  void initState() {
    super.initState();
    
  }
  
  @override
  void dispose() {
    super.dispose();
    
  }
  
  @override
  void setState(fn) {
   try{if (mounted) {
     super.setState(fn);
   }else{
     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
       super.setState(fn);
     });
   }}catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    initSystem(this, context, 434.9, 774.8,version:'0.1042');
        return Scaffold(
   backgroundColor: Color(0xffb5b5b5),
   resizeToAvoidBottomInset: false,
   body: BlupSheets(
      backendConnectStr: "",
      backendUserAgentStr: "ayushiagg1509@gmail.com",
      isRealtime: false,
      queryListMap: [],
      queryController:(context){
         contextFromProvider=context;
      },
      builder: (context) => BStack(
         id: "d80e7160-0b39-11ed-862b-998a8b985316",
         paddingLeft: ScreenUtil().setWidth(0.0),
         paddingRight: ScreenUtil().setWidth(0.0),
         paddingTop: ScreenUtil().setHeight(0.0),
         paddingBottom: ScreenUtil().setHeight(0.0),
         isHide: false,
         enumStackCompTypeValueStr: "enumStackCompType.Stack",
         children: <Widget>[
         BContainer(
            id: "da116d50-0b39-11ed-862b-998a8b985316",
            paddingLeft: ScreenUtil().setWidth(0.0),
            paddingRight: ScreenUtil().setWidth(0.0),
            paddingTop: ScreenUtil().setHeight(0.0),
            paddingBottom: ScreenUtil().setHeight(0.0),
            isHide: false,
            imageFit: "cover",
            child: Align(
               alignment: Alignment(-1.0, -1.0),
               child: BStack(
                  id: "dbb161b0-0b39-11ed-862b-998a8b985316",
                  width: 434.89999999999986,
                  height: 751.9849926564825,
                  paddingLeft: ScreenUtil().setWidth(0.0),
                  paddingRight: ScreenUtil().setWidth(0.0),
                  paddingTop: ScreenUtil().setHeight(0.0),
                  paddingBottom: ScreenUtil().setHeight(0.0),
                  isHide: false,
                  enumStackCompTypeValueStr: "enumStackCompType.Stack",
                  children: <Widget>[
                  BContainer(
                     id: "da1f01e3-0b39-11ed-862b-998a8b985316",
                     paddingLeft: ScreenUtil().setWidth(0.0),
                     paddingRight: ScreenUtil().setWidth(0.0),
                     paddingTop: ScreenUtil().setHeight(0.0),
                     paddingBottom: ScreenUtil().setHeight(0.0),
                     isHide: false,
                     imageFit: "cover",
                     child: Align(
                        alignment: Alignment(0.8858802453399379, 1.0),
                        child: BStack(
                           id: "dbb188c0-0b39-11ed-862b-998a8b985316",
                           width: 81.49490644825758,
                           height: 81.49490644825758,
                           paddingLeft: ScreenUtil().setWidth(0.0),
                           paddingRight: ScreenUtil().setWidth(0.0),
                           paddingTop: ScreenUtil().setHeight(0.0),
                           paddingBottom: ScreenUtil().setHeight(0.0),
                           isHide: false,
                           enumStackCompTypeValueStr: "enumStackCompType.Stack",
                           children: <Widget>[
                           BContainer(
                              id: "da223630-0b39-11ed-862b-998a8b985316",
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              imageFit: "cover",
                              child: Align(
                                 alignment: Alignment(-1.0, -1.0),
                                 child: IgnorePointer(
                                    ignoring: true,
                                    child: BContainer(
                                       id: "da2395c0-0b39-11ed-862b-998a8b985316",
                                       width: 81.4949064482576,
                                       height: 81.4949064482576,
                                       paddingLeft: ScreenUtil().setWidth(0.0),
                                       paddingRight: ScreenUtil().setWidth(0.0),
                                       paddingTop: ScreenUtil().setHeight(0.0),
                                       paddingBottom: ScreenUtil().setHeight(0.0),
                                       decoration: BoxDecoration(
                                          borderRadius:BorderRadius.circular(ScreenUtil().radius(40.7)),
                                          color:Color(0xffcdcdcd),
                                          boxShadow:[BoxShadow( color:Color(0x00ffffff), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(24.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                          border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                                       ),
                                       isHide: false,
                                       imageFit: "cover",
                                    )/*BContainer-End*/                                 )/*IgnorePointer-End*/,
                              ),
                           )/*BContainer-End*/,
                           
                           BContainer(
                              id: "da312a53-0b39-11ed-862b-998a8b985316",
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              imageFit: "cover",
                              child: Align(
                                 alignment: Alignment(-1.0, -1.0),
                                 child: IgnorePointer(
                                    ignoring: true,
                                    child: BContainer(
                                       id: "da3214b3-0b39-11ed-862b-998a8b985316",
                                       width: 81.4949064482576,
                                       height: 81.4949064482576,
                                       paddingLeft: ScreenUtil().setWidth(0.0),
                                       paddingRight: ScreenUtil().setWidth(0.0),
                                       paddingTop: ScreenUtil().setHeight(0.0),
                                       paddingBottom: ScreenUtil().setHeight(0.0),
                                       decoration: BoxDecoration(
                                          borderRadius:BorderRadius.circular(ScreenUtil().radius(40.7)),
                                          color:Color(0xffcdcdcd),
                                          boxShadow:[BoxShadow( color:Color(0x00ffffff), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(24.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                          border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                                       ),
                                       isHide: false,
                                       imageFit: "cover",
                                    )/*BContainer-End*/                                 )/*IgnorePointer-End*/,
                              ),
                           )/*BContainer-End*/,
                           
                           BContainer(
                              id: "da3485b3-0b39-11ed-862b-998a8b985316",
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              imageFit: "cover",
                              child: Align(
                                 alignment: Alignment(-0.006108774968419772, 0.01901785579829207),
                                 child:                                  BContainer(
                                    id: "da359723-0b39-11ed-862b-998a8b985316",
                                    width: 48.0,
                                    height: 48.0,
                                    paddingLeft: ScreenUtil().setWidth(0.0),
                                    paddingRight: ScreenUtil().setWidth(0.0),
                                    paddingTop: ScreenUtil().setHeight(0.0),
                                    paddingBottom: ScreenUtil().setHeight(0.0),
                                    decoration: BoxDecoration(
                                       borderRadius:BorderRadius.zero,
                                       color:Color(0xffffff),
                                       boxShadow:[BoxShadow( color:Color(0x00ffffff), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(24.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                       border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                                    ),
                                    isHide: false,
                                    imageFit: "cover",
                                    child: SizedBox(
                                       width: 48.0,
                                       height: 48.0,
                                       child: Padding(
                                          padding: EdgeInsets.all(ScreenUtil().setHeight(0.0)),
                                          child: BFloatingActionButton(
                                             id: "dbb2e850-0b39-11ed-862b-998a8b985316",
                                             backgroundColor: Color(0xffb1b1b1),
                                             elevation: null,
                                             disabledElevation: null,
                                             focusElevation: null,
                                             hoverElevation: null,
                                             highlightElevation: null,
                                             onClick: getFAB_541_onClick_run,
                                             child: BIcon(
                                                Icons.thumb_up_rounded,
                                                id: "dee1e120-0b39-11ed-862b-998a8b985316",
                                                color: Color(0xffecc59b),
                                                size: 20.0,
                                             ),
                                          ),
                                       ),
                                    ),
                                 )/*BContainer-End*/,
                              ),
                           )/*BContainer-End*/,
                           
],
                        ),
                     ),
                  )/*BContainer-End*/,
                  
                  BContainer(
                     id: "da4d64e3-0b39-11ed-862b-998a8b985316",
                     paddingLeft: ScreenUtil().setWidth(0.0),
                     paddingRight: ScreenUtil().setWidth(0.0),
                     paddingTop: ScreenUtil().setHeight(0.0),
                     paddingBottom: ScreenUtil().setHeight(0.0),
                     isHide: false,
                     imageFit: "cover",
                     child: Align(
                        alignment: Alignment(-1.0, -1.0),
                        child: IgnorePointer(
                           ignoring: true,
                           child: BContainer(
                              id: "da4e4f41-0b39-11ed-862b-998a8b985316",
                              width: 434.9,
                              height: 33.77394349380293,
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              decoration: BoxDecoration(
                                 borderRadius:BorderRadius.zero,
                                 color:Color(0xffb8b8b8),
                                 boxShadow:[BoxShadow( color:Color(0x60171717), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(13.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                 border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                              ),
                              isHide: false,
                              imageFit: "cover",
                           )/*BContainer-End*/                        )/*IgnorePointer-End*/,
                     ),
                  )/*BContainer-End*/,
                  
                  BContainer(
                     id: "da509933-0b39-11ed-862b-998a8b985316",
                     paddingLeft: ScreenUtil().setWidth(0.0),
                     paddingRight: ScreenUtil().setWidth(0.0),
                     paddingTop: ScreenUtil().setHeight(0.0),
                     paddingBottom: ScreenUtil().setHeight(0.0),
                     isHide: false,
                     imageFit: "cover",
                     child: Align(
                        alignment: Alignment(-0.00023727775096493708, 0.6857717045653573),
                        child: BStack(
                           id: "dbb3aba0-0b39-11ed-862b-998a8b985316",
                           width: 368.9205060650721,
                           height: 88.61729979241053,
                           paddingLeft: ScreenUtil().setWidth(0.0),
                           paddingRight: ScreenUtil().setWidth(0.0),
                           paddingTop: ScreenUtil().setHeight(0.0),
                           paddingBottom: ScreenUtil().setHeight(0.0),
                           isHide: false,
                           enumStackCompTypeValueStr: "enumStackCompType.Stack",
                           children: <Widget>[
                           BContainer(
                              id: "da53a671-0b39-11ed-862b-998a8b985316",
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              imageFit: "cover",
                              child: Align(
                                 alignment: Alignment(0.0, 1.0),
                                 child: IgnorePointer(
                                    ignoring: true,
                                    child: BContainer(
                                       id: "da5490d3-0b39-11ed-862b-998a8b985316",
                                       width: 368.9205060650721,
                                       height: 88.61729979241049,
                                       paddingLeft: ScreenUtil().setWidth(0.0),
                                       paddingRight: ScreenUtil().setWidth(0.0),
                                       paddingTop: ScreenUtil().setHeight(0.0),
                                       paddingBottom: ScreenUtil().setHeight(0.0),
                                       decoration: BoxDecoration(
                                          borderRadius:BorderRadius.only(topLeft: Radius.circular(ScreenUtil().setHeight(44.3)), topRight: Radius.circular(ScreenUtil().setHeight(44.3)), bottomLeft: Radius.circular(ScreenUtil().setHeight(44.3)), bottomRight: Radius.circular(ScreenUtil().setHeight(5.4))),
                                          color:getRectangle_568_Fill(),
                                          boxShadow:[BoxShadow( color:Color(0x00ffffff), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(24.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                          border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                                       ),
                                       isHide: false,
                                       imageFit: "cover",
                                    )/*BContainer-End*/                                 )/*IgnorePointer-End*/,
                              ),
                           )/*BContainer-End*/,
                           
                           BContainer(
                              id: "da574ff0-0b39-11ed-862b-998a8b985316",
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              imageFit: "cover",
                              child: Align(
                                 alignment: Alignment(0.03787468080212886, 0.008049287423485207),
                                 child: IgnorePointer(
                                    ignoring: true,
                                    child: BText(
                                       '''${getText_543_text()??'''The like is tapped 0 times.'''}''',
                                       style: TextStyle(
                                          fontSize: ScreenUtil().setSp(22.0),
                                          letterSpacing: 0.0,
                                          height: 1.2,
                                          color: Color(0xff364c36),
                                          fontWeight : FontWeight.w700,
                                          fontStyle : FontStyle.normal,
                                       ),                                    
                                       textAlign: TextAlign.left,
                                          id: "dbb49600-0b39-11ed-862b-998a8b985316",
                                          width: 290.0,
                                          height: 26.0,
                                          paddingLeft: ScreenUtil().setWidth(0.0),
                                          paddingRight: ScreenUtil().setWidth(0.0),
                                          paddingTop: ScreenUtil().setHeight(0.0),
                                          paddingBottom: ScreenUtil().setHeight(0.0),
                                          maxLines: null,
                                          textWrap: TextWrap.autoWidth,
                                          isHide: false,
                                          isEllipsis: false,
                                          isTextSelectable: false,
                                       ),
                                    ),
                                 ),
                              )/*BContainer-End*/,
                              
],
                           ),
                        ),
                     )/*BContainer-End*/,
                     
                     BContainer(
                        id: "da9da7c3-0b39-11ed-862b-998a8b985316",
                        paddingLeft: ScreenUtil().setWidth(0.0),
                        paddingRight: ScreenUtil().setWidth(0.0),
                        paddingTop: ScreenUtil().setHeight(0.0),
                        paddingBottom: ScreenUtil().setHeight(0.0),
                        isHide: false,
                        imageFit: "cover",
                        child: Align(
                           alignment: Alignment(6.8833827526759706e-15, -0.5685782853970568),
                           child: BStack(
                              id: "dbb4e420-0b39-11ed-862b-998a8b985316",
                              width: 387.7983429803338,
                              height: 465.0427732720711,
                              paddingLeft: ScreenUtil().setWidth(0.0),
                              paddingRight: ScreenUtil().setWidth(0.0),
                              paddingTop: ScreenUtil().setHeight(0.0),
                              paddingBottom: ScreenUtil().setHeight(0.0),
                              isHide: false,
                              enumStackCompTypeValueStr: "enumStackCompType.Stack",
                              children: <Widget>[
                              BContainer(
                                 id: "daa018c0-0b39-11ed-862b-998a8b985316",
                                 paddingLeft: ScreenUtil().setWidth(0.0),
                                 paddingRight: ScreenUtil().setWidth(0.0),
                                 paddingTop: ScreenUtil().setHeight(0.0),
                                 paddingBottom: ScreenUtil().setHeight(0.0),
                                 isHide: false,
                                 imageFit: "cover",
                                 child: Align(
                                    alignment: Alignment(-1.0, -1.0),
                                    child: IgnorePointer(
                                       ignoring: true,
                                       child: BContainer(
                                          id: "daa10323-0b39-11ed-862b-998a8b985316",
                                          width: 387.7983429803337,
                                          height: 465.0427732720711,
                                          paddingLeft: ScreenUtil().setWidth(0.0),
                                          paddingRight: ScreenUtil().setWidth(0.0),
                                          paddingTop: ScreenUtil().setHeight(0.0),
                                          paddingBottom: ScreenUtil().setHeight(0.0),
                                          decoration: BoxDecoration(
                                             borderRadius:BorderRadius.only(topLeft: Radius.circular(ScreenUtil().setHeight(43.8)), topRight: Radius.circular(ScreenUtil().setHeight(43.8)), bottomLeft: Radius.circular(ScreenUtil().setHeight(43.8)), bottomRight: Radius.circular(ScreenUtil().setHeight(7.3))),
                                             color:Color(0xff000000),
                                             boxShadow:[BoxShadow( color:Color(0x671e1e1e), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(13.0)), blurRadius: ScreenUtil().radius(31.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                             border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(9.0),),
                                             image:DecorationImage( fit:BoxFit.cover, image:NetworkImage("https://i.pinimg.com/originals/16/74/40/167440e3dde893c9c1a2066ef1cef60a.gif"),),
                                          ),
                                          isHide: false,
                                          imageFit: "cover",
                                       )/*BContainer-End*/                                    )/*IgnorePointer-End*/,
                                 ),
                              )/*BContainer-End*/,
                              
                              BContainer(
                                 id: "daa744b0-0b39-11ed-862b-998a8b985316",
                                 paddingLeft: ScreenUtil().setWidth(0.0),
                                 paddingRight: ScreenUtil().setWidth(0.0),
                                 paddingTop: ScreenUtil().setHeight(0.0),
                                 paddingBottom: ScreenUtil().setHeight(0.0),
                                 isHide: false,
                                 imageFit: "cover",
                                 child: Align(
                                    alignment: Alignment(-0.8428500523392696, -0.9077603080787152),
                                    child: BStack(
                                       id: "dbb50b30-0b39-11ed-862b-998a8b985316",
                                       width: 137.90356290876048,
                                       height: 34.66542655299631,
                                       paddingLeft: ScreenUtil().setWidth(0.0),
                                       paddingRight: ScreenUtil().setWidth(0.0),
                                       paddingTop: ScreenUtil().setHeight(0.0),
                                       paddingBottom: ScreenUtil().setHeight(0.0),
                                       isHide: false,
                                       enumStackCompTypeValueStr: "enumStackCompType.Stack",
                                       children: <Widget>[
                                       BContainer(
                                          id: "daadad50-0b39-11ed-862b-998a8b985316",
                                          paddingLeft: ScreenUtil().setWidth(0.0),
                                          paddingRight: ScreenUtil().setWidth(0.0),
                                          paddingTop: ScreenUtil().setHeight(0.0),
                                          paddingBottom: ScreenUtil().setHeight(0.0),
                                          isHide: false,
                                          imageFit: "cover",
                                          child: Align(
                                             alignment: Alignment(-1.0, -1.0),
                                             child: IgnorePointer(
                                                ignoring: true,
                                                child: BContainer(
                                                   id: "daafa923-0b39-11ed-862b-998a8b985316",
                                                   width: 34.66542655299631,
                                                   height: 34.66542655299631,
                                                   paddingLeft: ScreenUtil().setWidth(0.0),
                                                   paddingRight: ScreenUtil().setWidth(0.0),
                                                   paddingTop: ScreenUtil().setHeight(0.0),
                                                   paddingBottom: ScreenUtil().setHeight(0.0),
                                                   decoration: BoxDecoration(
                                                      borderRadius:BorderRadius.circular(ScreenUtil().radius(20.5)),
                                                      gradient:RadialGradient(
                                                         center:Alignment.center,
                                                         radius:0.5,
                                                         colors:[Color(0xffdd9057), Color(0xff3a2f25), Color(0xff23211e)],
                                                         stops:[0.0, 0.5682142857142853, 1.0],
                                                         focal:null,
                                                         focalRadius:0.0,
                                                      ),
                                                      boxShadow:[BoxShadow( color:Color(0x00ffffff), offset: Offset(ScreenUtil().setWidth(0.0), ScreenUtil().setHeight(10.0)), blurRadius: ScreenUtil().radius(24.0), spreadRadius: ScreenUtil().radius(0.0),)],
                                                      border:Border.all( color:Color(0x00ffffff), width: ScreenUtil().radius(1.0),),
                                                   ),
                                                   isHide: false,
                                                   imageFit: "cover",
                                                )/*BContainer-End*/                                             )/*IgnorePointer-End*/,
                                          ),
                                       )/*BContainer-End*/,
                                       
                                       BContainer(
                                          id: "dab21a23-0b39-11ed-862b-998a8b985316",
                                          paddingLeft: ScreenUtil().setWidth(0.0),
                                          paddingRight: ScreenUtil().setWidth(0.0),
                                          paddingTop: ScreenUtil().setHeight(0.0),
                                          paddingBottom: ScreenUtil().setHeight(0.0),
                                          isHide: false,
                                          imageFit: "cover",
                                          child: Align(
                                             alignment: Alignment(0.9999999999999967, -7.993605777301127e-15),
                                             child: IgnorePointer(
                                                ignoring: true,
                                                child: BText(
                                                   '''Shasha Grey''',
                                                   style: TextStyle(
                                                      fontSize: ScreenUtil().setSp(16.0),
                                                      letterSpacing: 0.0,
                                                      height: 1.2,
                                                      color: Color(0xff5b5b5b),
                                                      fontWeight : FontWeight.w600,
                                                      fontStyle : FontStyle.normal,
                                                   ),                                                
                                                   textAlign: TextAlign.left,
                                                      id: "dbb55950-0b39-11ed-862b-998a8b985316",
                                                      width: 100.0,
                                                      height: 19.0,
                                                      paddingLeft: ScreenUtil().setWidth(0.0),
                                                      paddingRight: ScreenUtil().setWidth(0.0),
                                                      paddingTop: ScreenUtil().setHeight(0.0),
                                                      paddingBottom: ScreenUtil().setHeight(0.0),
                                                      maxLines: null,
                                                      textWrap: TextWrap.autoWidth,
                                                      isHide: false,
                                                      isEllipsis: false,
                                                      isTextSelectable: false,
                                                   ),
                                                ),
                                             ),
                                          )/*BContainer-End*/,
                                          
],
                                       ),
                                    ),
                                 )/*BContainer-End*/,
                                 
],
                              ),
                           ),
                        )/*BContainer-End*/,
                        
],
                     ),
                  ),
               )/*BContainer-End*/,
               
],
            ),
         ),
      );
  }
   
                                 
   void runInsert_Code() async   {
      var value = getColor();
   }
      
   getFAB_541_onClick_run()   {
      setState((){});
      runInsert_Code();
      runInsert_Code_1();
   }
      
   void runInsert_Code_1() async   {
      setText();
   }
      
   getRectangle_568_Fill()   {
      var value = getColor();
      return value;
   }
         
   getText_543_text()   {
      var value = getText();
      return value;
   }
   
}
 
class NewPage328400a0067711ed80c77ddd3cc54d4a extends StatefulWidget {
  NewPage328400a0067711ed80c77ddd3cc54d4a({Key key}) : super(key: key);
  
  @override
  _NewPage328400a0067711ed80c77ddd3cc54d4aState createState() => _NewPage328400a0067711ed80c77ddd3cc54d4aState();
}

class _NewPage328400a0067711ed80c77ddd3cc54d4aState extends State<NewPage328400a0067711ed80c77ddd3cc54d4a> with AutomaticKeepAliveClientMixin<NewPage328400a0067711ed80c77ddd3cc54d4a> {
  BuildContext contextFromProvider;

  @override
  void initState() {
    super.initState();
    
  }
  
  @override
  void dispose() {
    super.dispose();
    
  }
  
  @override
  void setState(fn) {
   try{if (mounted) {
     super.setState(fn);
   }else{
     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
       super.setState(fn);
     });
   }}catch(e){}
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
        return Scaffold(
   backgroundColor: Color(0x0),
   resizeToAvoidBottomInset: false,
   body: BlupSheets(
      backendConnectStr: "",
      backendUserAgentStr: "ayushiagg1509@gmail.com",
      isRealtime: false,
      queryListMap: [],
      queryController:(context){
         contextFromProvider=context;
      },
      builder: (context) => BStack(
         id: "d67533c0-0b39-11ed-862b-998a8b985316",
         paddingLeft: ScreenUtil().setWidth(0.0),
         paddingRight: ScreenUtil().setWidth(0.0),
         paddingTop: ScreenUtil().setHeight(0.0),
         paddingBottom: ScreenUtil().setHeight(0.0),
         isHide: false,
         enumStackCompTypeValueStr: "enumStackCompType.Stack",
      ),
   ),
);
  }

}
