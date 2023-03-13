import 'package:shared_preferences/shared_preferences.dart';

class Onboard_Record{

  Future<int> onboard() async{
    int result = 0;
    final prefs = await SharedPreferences.getInstance();
    final onboardRecord = prefs.getInt("onboard");
    if (onboardRecord != null) {
      result = onboardRecord+1;
      prefs.setInt("onboard", result);
    }else{
      result++;
      prefs.setInt('onboard', result);
    }

    return result;
  }

}