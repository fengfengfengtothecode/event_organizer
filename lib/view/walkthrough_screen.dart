import 'package:flutter/cupertino.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';

class GuideSteps extends IntroScreen{
  final Function(int) doneRead;
  GuideSteps(this.doneRead, {required super.onbordingDataList, required super.colors, required super.nextButton, required super.lastButton, required super.skipButton});

  @override
  void skipPage(BuildContext context){
    if(pageRoute!=null){
      Navigator.push(context, pageRoute!);
    }else{
        doneRead(1);
    }
  }

}