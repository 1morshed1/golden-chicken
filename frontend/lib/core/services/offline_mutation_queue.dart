import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class PendingMutation {
  const PendingMutation({
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.createdAt,
  });

  factory PendingMutation.fromJson(Map<String, dynamic> json) {
    return PendingMutation(
      id: json['id'] as String,
      method: json['method'] as String,
      path: json['path'] as String,
      body: json['body'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String method;
  final String path;
  final Map<String, dynamic> body;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'path': path,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };
}

class OfflineMutationQueue {
  OfflineMutationQueue({
    required Dio dio,
    required Connectivity connectivity,
  })  : _dio = dio,
        _connectivity = connectivity;

  static const String _boxName = 'offline_mutations';

  final Dio _dio;
  final Connectivity _connectivity;
  final _logger = Logger();
  Box<String>? _box;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> enqueue({
    required String method,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final mutation = PendingMutation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      method: method,
      path: path,
      body: body,
      createdAt: DateTime.now(),
    );
    await _box?.put(mutation.id, jsonEncode(mutation.toJson()));
    _logger.i('Queued offline mutation: $method $path');
  }

  int get pendingCount => _box?.length ?? 0;

  List<PendingMutation> get pendingMutations {
    if (_box == null) return [];
    return _box!.values
        .map((v) => PendingMutation.fromJson(
              jsonDecode(v) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasConnection =
        results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      await syncAll();
    }
  }

  Future<void> syncAll() async {
    if (_isSyncing || _box == null || _box!.isEmpty) return;
    _isSyncing = true;
    _logger.i('Syncing ${_box!.length} queued mutations');

    final keys = _box!.keys.toList();
    for (final key in keys) {
      final raw = _box!.get(key);
      if (raw == null) continue;

      final mutation = PendingMutation.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      try {
        switch (mutation.method) {
          case 'POST':
            await _dio.post<dynamic>(mutation.path, data: mutation.body);
          case 'PATCH':
            await _dio.patch<dynamic>(mutation.path, data: mutation.body);
          case 'PUT':
            await _dio.put<dynamic>(mutation.path, data: mutation.body);
          default:
            _logger.w('Unknown method: ${mutation.method}');
        }
        await _box!.delete(key);
        _logger.i('Synced mutation: ${mutation.method} ${mutation.path}');
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          _logger.w('Still offline, stopping sync');
          break;
        }
        _logger.e('Failed to sync mutation: ${mutation.path}', error: e);
        await _box!.delete(key);
      }
    }
    _isSyncing = false;
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _box?.close();
  }
}
