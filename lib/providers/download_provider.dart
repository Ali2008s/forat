import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';

enum DownloadStatus { downloading, completed, failed, canceled }

class DownloadTask {
  final String id;
  final String title;
  final String type; // 'movie' or 'series'
  final String coverUrl;
  final String savePath;
  final String url;

  DownloadStatus status;
  double progress;
  CancelToken? cancelToken;

  DownloadTask({
    required this.id,
    required this.title,
    required this.type,
    required this.coverUrl,
    required this.savePath,
    required this.url,
    this.status = DownloadStatus.downloading,
    this.progress = 0.0,
    this.cancelToken,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'coverUrl': coverUrl,
    'savePath': savePath,
    'url': url,
    'status': status.index,
    'progress': progress,
  };

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
    id: json['id'],
    title: json['title'],
    type: json['type'],
    coverUrl: json['coverUrl'] ?? '',
    savePath: json['savePath'],
    url: json['url'],
    status: DownloadStatus.values[json['status'] ?? 0],
    progress: (json['progress'] ?? 0.0).toDouble(),
  );
}

class DownloadProvider with ChangeNotifier {
  List<DownloadTask> _tasks = [];
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 60),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      },
      followRedirects: true,
      maxRedirects: 5,
    ),
  );

  List<DownloadTask> get tasks => _tasks;

  List<DownloadTask> get activeTasks =>
      _tasks.where((t) => t.status != DownloadStatus.completed).toList();

  List<DownloadTask> get completedTasks =>
      _tasks.where((t) => t.status == DownloadStatus.completed).toList();

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  DownloadProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      debugPrint('DownloadProvider: Loading tasks...');
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('downloads');
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        final loadedTasks = decoded
            .map((item) => DownloadTask.fromJson(item))
            .toList();

        for (var task in loadedTasks) {
          if (task.status == DownloadStatus.downloading) {
            task.status = DownloadStatus.failed;
          }
        }

        // Merge: Add uniquely new tasks from loaded data
        final currentIds = _tasks.map((t) => t.id).toSet();
        for (var lt in loadedTasks) {
          if (!currentIds.contains(lt.id)) {
            _tasks.add(lt);
          }
        }

        notifyListeners();
        debugPrint('DownloadProvider: Loaded ${_tasks.length} tasks total');
      }
    } catch (e) {
      debugPrint('DownloadProvider Error: $e');
    } finally {
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('downloads', encoded);
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  bool isDownloading(String id) {
    return _tasks.any(
      (t) => t.id == id && t.status == DownloadStatus.downloading,
    );
  }

  double getProgress(String id) {
    try {
      final task = _tasks.firstWhere(
        (t) => t.id == id && t.status == DownloadStatus.downloading,
      );
      return task.progress;
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> startDownload({
    required String id,
    required String title,
    required String type,
    required String coverUrl,
    required String url,
    required String ext,
    String? seriesFolder,
  }) async {
    if (id.isEmpty) {
      debugPrint('Download: Error - ID is empty for $title');
      return;
    }

    debugPrint('Download: Starting $title ($id)');

    // Ensure loaded
    await initialized;

    // Check if already downloading
    if (isDownloading(id)) {
      debugPrint('Download: already downloading $id');
      return;
    }

    // Prepare Task first so it shows up in UI immediately
    final newTask = DownloadTask(
      id: id,
      title: title,
      type: type,
      coverUrl: coverUrl,
      savePath: '', // Will be updated
      url: url,
    );

    // Add to list immediately to show in UI
    _tasks.removeWhere((t) => t.id == id);
    _tasks.insert(0, newTask);
    notifyListeners();
    _saveTasks();

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        final idx = _tasks.indexWhere((t) => t.id == id);
        if (idx != -1) {
          _tasks[idx].status = DownloadStatus.failed;
          notifyListeners();
          _saveTasks();
        }
        throw 'Cannot access storage';
      }

      final appDir = Directory('${dir.path}/ForaTV');
      final folderName = seriesFolder != null
          ? _sanitize(seriesFolder)
          : _sanitize(title);
      final mediaDir = Directory('${appDir.path}/$folderName');

      if (!await mediaDir.exists()) {
        debugPrint('Download: Creating directory ${mediaDir.path}');
        await mediaDir.create(recursive: true);
      }

      final savePath = '${mediaDir.path}/${_sanitize(title)}.$ext';

      // Update task with final savePath
      final taskIdx = _tasks.indexWhere((t) => t.id == id);
      if (taskIdx != -1) {
        _tasks[taskIdx] = DownloadTask(
          id: id,
          title: title,
          type: type,
          coverUrl: coverUrl,
          savePath: savePath,
          url: url,
          cancelToken: CancelToken(),
          status: DownloadStatus.downloading,
        );
        notifyListeners();
        _saveTasks();
      } else {
        debugPrint('Download: Task $id was removed before it could start.');
        return;
      }

      final taskToRun = _tasks[taskIdx];
      debugPrint('Download: Running dio.download to ${taskToRun.savePath}');

      final uri = Uri.parse(url);

      await _dio.download(
        url,
        taskToRun.savePath,
        cancelToken: taskToRun.cancelToken,
        deleteOnError: true, // Clean up partial file on error
        options: Options(
          headers: {
            'Host': uri.host,
            'Referer': '${uri.scheme}://${uri.host}/',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && total > 0) {
            taskToRun.progress = received / total;
            notifyListeners();
          }
        },
      );

      taskToRun.status = DownloadStatus.completed;
      taskToRun.progress = 1.0;
      debugPrint('Download: Completed $title');
      notifyListeners();
      _saveTasks();
    } catch (e) {
      debugPrint('Download error for $title: $e');
      final taskIdx = _tasks.indexWhere((t) => t.id == id);
      if (taskIdx != -1) {
        if (e is DioException && CancelToken.isCancel(e)) {
          _tasks[taskIdx].status = DownloadStatus.canceled;
        } else {
          _tasks[taskIdx].status = DownloadStatus.failed;
        }
        notifyListeners();
        _saveTasks();
      }
    }
  }

  Future<void> cancelDownload(String id) async {
    debugPrint('Download: Canceling $id');
    final taskIdx = _tasks.indexWhere((t) => t.id == id);
    if (taskIdx != -1) {
      final task = _tasks[taskIdx];
      if (task.status == DownloadStatus.downloading) {
        task.cancelToken?.cancel();
        task.status = DownloadStatus.canceled;

        // Clean up partial file
        try {
          final file = File(task.savePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}

        notifyListeners();
        _saveTasks();
      }
    }
  }

  Future<void> removeTask(String id) async {
    final taskIdx = _tasks.indexWhere((t) => t.id == id);
    if (taskIdx != -1) {
      final task = _tasks[taskIdx];

      // If downloading, cancel first
      if (task.status == DownloadStatus.downloading) {
        task.cancelToken?.cancel();
      }

      // Delete file
      try {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      _tasks.removeAt(taskIdx);
      notifyListeners();
      _saveTasks();
    }
  }

  Future<void> openFile(String savePath) async {
    final file = File(savePath);
    if (await file.exists()) {
      await OpenFilex.open(savePath);
    }
  }
}
