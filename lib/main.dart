import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'core/di/injection_container.dart' as di;
import 'data/services/push_notification_service.dart';
import 'app.dart';

const _taskCheckNotifications = 'com.financialite.checkNotifications';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _taskCheckNotifications) {
      await PushNotificationService.checkForNewNotifications();
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await PushNotificationService.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    _taskCheckNotifications,
    _taskCheckNotifications,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  runApp(const FinancialiteApp());
}
