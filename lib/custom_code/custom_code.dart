import 'package:flutter/material.dart';
import 'dart:math' as math;

///Code to store & display the
///number of times a button is clicked.

int counter = 0;

///Updates the number of
///times the button is tapped.
void setText() {
  counter++;
}

///Gives back "How many
///times the button is tapped?"
String getText() {
  return "The like is tapped $counter times";
}

Color getColor(){
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.2);
}

