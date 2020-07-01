import 'package:foreground_service/foreground_service.dart';

void startService() async {
  var n = ForegroundService.notification;
  await n.setTitle('Dupa');
  await n.setText('Navigating to: ');

  await ForegroundService.startForegroundService();
}

void serviceFunction() {
  print('dupa12');
  Future.delayed(Duration(seconds: 5)).then((value) {
    print('dupa');
    return ForegroundService.stopForegroundService();
  });
}
