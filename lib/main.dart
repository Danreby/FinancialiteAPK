import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
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

  // Start auth check early so splash transitions quickly
  di.sl<AuthBloc>().add(const AuthCheckRequested());

  try {
    await PushNotificationService.init();
  } catch (e) {
    debugPrint('[PushNotification] init error: $e');
  }

  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _taskCheckNotifications,
      _taskCheckNotifications,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (e) {
    debugPrint('[Workmanager] init error: $e');
  }

  runApp(const FinancialiteApp());
}
