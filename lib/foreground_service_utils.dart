import 'package:foreground_service/foreground_service.dart';

/// Okay, so this is how bt communication will work
/// All connection stuff must be done and managed from foreground service
/// Any communication is done through .sendToPort()
/// main idea is to send a Map with 'method' - which contains
/// what you want to do, and another Map 'args' which has all required arguments
/// Let's see how this will go...
void serviceFunction() async {
  print('Foreground service start');
  void _handleMessage(dynamic message) {
    print('New message received in service: $message');
    assert(message is Map);
    switch (message['method']) {
      case 'connectTo':
        print('Connecting to...');
        break;
    }
  }

  await ForegroundService.setupIsolateCommunication(_handleMessage);

  var n = ForegroundService.notification;
  n.setTitle('Waiting to connect to hat...');
  await Future.delayed(Duration(seconds: 30));
  ForegroundService.stopForegroundService();

  while (true);
}
