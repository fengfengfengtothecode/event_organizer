import 'package:event_organizer/controller/navigator_controller.dart';
import 'package:event_organizer/model/onboard_record_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../main.dart';
import '../persist/onboard_record_persist.dart';

class MyAppController extends ControllerMVC{
  Onboard_Record _onboard_record = Onboard_Record();
  NavigatorController _navigatorController = NavigatorController();
  factory MyAppController()=>_this??=MyAppController._();
  MyAppController._();
  static MyAppController? _this;



  int get onboardTime=> OnboardRecordModel.onboardTime;

  void update(int i){
    print("update"+ i.toString());
    OnboardRecordModel.setOnboardTime(i);
  }

  Future<void> onboarding() async{
    _onboard_record.onboard().then((value) => {
      update(value)
    });
  }

  Widget checkIsFirstTimeOnboard(){

    onboarding();
    if(onboardTime>1){
      _navigatorController.update(1);
    }else{
      _navigatorController.update(0);
    }
    return const NavigationBar();
  }
}