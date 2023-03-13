import 'package:event_organizer/model/navigate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class NavigatorController extends ControllerMVC{
  factory NavigatorController()=>_this??=NavigatorController._();
  NavigatorController._();
  static NavigatorController? _this;


  int get index=> NavigateModel.index;

  void update(int i){
      print("update"+ i.toString());
      NavigateModel.setIndex(i);
  }
}