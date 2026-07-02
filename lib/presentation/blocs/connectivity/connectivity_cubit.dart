import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/services/sync_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity;
  final SyncService _syncService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit(this._connectivity, this._syncService) : super(true) {
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    final online = _isConnected(results);
    emit(online);
    // Catches anything queued from a previous session that never got a
    // chance to sync (e.g. app was killed while offline).
    if (online) _syncService.processQueue();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !state;
      final online = _isConnected(results);
      emit(online);
      if (online && wasOffline) {
        _syncService.processQueue();
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
