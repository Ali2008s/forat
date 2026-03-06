import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isLive;
  final List<dynamic>? episodes;
  final int? currentEpisodeIndex;
  final List<dynamic>? channels;
  final int? currentChannelIndex;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.url,
    this.isLive = false,
    this.episodes,
    this.currentEpisodeIndex,
    this.channels,
    this.currentChannelIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  MethodChannel? _channel;
  bool _isPlaying = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _positionTimer;

  int _position = 0;
  int _duration = 0;
  bool _isDragging = false;

  String _currentUrl = "";
  String _currentTitle = "";
  int _currentEpIndex = 0;
  int _currentChIndex = 0;

  bool _isBuffering = true;
  bool _hasError = false;
  String _errorMessage = "";
  int _retryCount = 0;
  static const int _maxRetries = 10;
  Timer? _retryTimer;

  // Focus nodes for player controls
  final FocusNode _playerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _currentTitle = widget.title;
    _currentEpIndex = widget.currentEpisodeIndex ?? 0;
    _currentChIndex = widget.currentChannelIndex ?? 0;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _startHideTimer();
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('native_vlc_player_$id');
    _channel?.setMethodCallHandler((call) async {
      if (call.method == 'onStateChanged') {
        final state = call.arguments as String;
        if (mounted) {
          setState(() {
            if (state == 'playing' || state == 'ready') {
              _isPlaying = true;
              _isBuffering = false;
              _hasError = false;
              _retryCount = 0;
              _retryTimer?.cancel();
            } else if (state == 'paused') {
              _isPlaying = false;
              _isBuffering = false;
            } else if (state == 'ended') {
              _isPlaying = false;
              _isBuffering = false;
              if (!widget.isLive) _playNextEpisode();
            } else if (state == 'buffering') {
              _isBuffering = true;
            } else if (state == 'error') {
              _handleError();
            }
          });
        }
      }
    });

    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (_channel == null || !mounted || _isDragging) return;
      try {
        final pos = await _channel?.invokeMethod('getPosition') ?? 0;
        final dur = await _channel?.invokeMethod('getDuration') ?? 0;
        if (mounted) {
          setState(() {
            if (_position != pos) {
              _isBuffering = false;
              _hasError = false;
            }
            _position = pos;
            _duration = dur;
          });
        }
      } catch (_) {}
    });
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _channel?.invokeMethod('pause');
    } else {
      _channel?.invokeMethod('play');
    }
    _startHideTimer();
  }

  void _seekTo(double value) {
    _channel?.invokeMethod('seekTo', {'position': value.toInt()});
    setState(() {
      _position = value.toInt();
      _isDragging = false;
    });
    _startHideTimer();
  }

  void _seekForward() {
    if (!widget.isLive) {
      _seekTo((_position + 10000).toDouble().clamp(0, _duration.toDouble()));
    }
    _showControlsTemporarily();
  }

  void _seekBackward() {
    if (!widget.isLive) {
      _seekTo((_position - 10000).toDouble().clamp(0, _duration.toDouble()));
    }
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _startHideTimer();
  }

  void _loadNewMedia(String url, String title) {
    setState(() {
      _currentUrl = url;
      _currentTitle = title;
      _position = 0;
      _isBuffering = true;
      _hasError = false;
      _retryCount = 0;
    });
    _channel?.invokeMethod('load', {'url': url});
  }

  void _handleError() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      setState(() {
        _isBuffering = true;
        _errorMessage =
            "فشل الاتصال، جاري إعادة المحاولة ($_retryCount/$_maxRetries)...";
      });
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) _channel?.invokeMethod('load', {'url': _currentUrl});
      });
    } else {
      setState(() {
        _isBuffering = false;
        _hasError = true;
        _errorMessage =
            "تعذر الاتصال بالخادم. يرجى التحقق من الشبكة أو المحاولة لاحقاً.";
      });
    }
  }

  void _playNextEpisode() {
    if (widget.episodes != null &&
        _currentEpIndex < widget.episodes!.length - 1) {
      final nextIndex = _currentEpIndex + 1;
      final nextEp = widget.episodes![nextIndex];
      _currentEpIndex = nextIndex;
      _loadNewMedia(
        nextEp['url'] ?? '',
        nextEp['title'] ?? 'EP ${nextIndex + 1}',
      );
    }
  }

  void _playPreviousEpisode() {
    if (widget.episodes != null && _currentEpIndex > 0) {
      final prevIndex = _currentEpIndex - 1;
      final prevEp = widget.episodes![prevIndex];
      _currentEpIndex = prevIndex;
      _loadNewMedia(
        prevEp['url'] ?? '',
        prevEp['title'] ?? 'EP ${prevIndex + 1}',
      );
    }
  }

  void _nextChannel() {
    if (widget.channels != null &&
        _currentChIndex < widget.channels!.length - 1) {
      final nextIndex = _currentChIndex + 1;
      final ch = widget.channels![nextIndex];
      setState(() => _currentChIndex = nextIndex);
      _loadNewMedia(ch['url'] ?? '', ch['name'] ?? ch['title'] ?? 'قناة');
    }
  }

  void _previousChannel() {
    if (widget.channels != null && _currentChIndex > 0) {
      final prevIndex = _currentChIndex - 1;
      final ch = widget.channels![prevIndex];
      setState(() => _currentChIndex = prevIndex);
      _loadNewMedia(ch['url'] ?? '', ch['name'] ?? ch['title'] ?? 'قناة');
    }
  }

  /// Handle channel up/down based on content type
  void _handleChannelUp() {
    _showControlsTemporarily();
    if (widget.isLive &&
        widget.channels != null &&
        widget.channels!.isNotEmpty) {
      _previousChannel();
    } else if (!widget.isLive &&
        widget.episodes != null &&
        widget.episodes!.isNotEmpty) {
      _playPreviousEpisode();
    }
  }

  void _handleChannelDown() {
    _showControlsTemporarily();
    if (widget.isLive &&
        widget.channels != null &&
        widget.channels!.isNotEmpty) {
      _nextChannel();
    } else if (!widget.isLive &&
        widget.episodes != null &&
        widget.episodes!.isNotEmpty) {
      _playNextEpisode();
    }
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String minStr = (minutes % 60).toString().padLeft(2, '0');
    String secStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minStr:$secStr';
    } else {
      return '$minStr:$secStr';
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _positionTimer?.cancel();
    _retryTimer?.cancel();
    _playerFocusNode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showEpisodesSheet() {
    _startHideTimer();
    _showAppSheet(
      title: "الحلقات",
      items: widget.episodes ?? [],
      currentIndex: _currentEpIndex,
      isEpisodes: true,
      onSelect: (index) {
        final ep = widget.episodes![index];
        setState(() => _currentEpIndex = index);
        _loadNewMedia(ep['url'] ?? '', ep['title'] ?? 'EP ${index + 1}');
      },
    );
  }

  void _showChannelsSheet() {
    _startHideTimer();
    _showAppSheet(
      title: "القنوات",
      items: widget.channels ?? [],
      currentIndex: _currentChIndex,
      isEpisodes: false,
      onSelect: (index) {
        final ch = widget.channels![index];
        setState(() => _currentChIndex = index);
        _loadNewMedia(ch['url'] ?? '', ch['name'] ?? ch['title'] ?? 'قناة');
      },
    );
  }

  void _showAppSheet({
    required String title,
    required List<dynamic> items,
    required int currentIndex,
    required bool isEpisodes,
    required Function(int) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TVFocusable(
                        onSelect: () => Navigator.pop(context),
                        focusColor: Colors.white54,
                        borderRadius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10),
                Expanded(
                  child: isEpisodes
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final isSelected = i == currentIndex;
                            return TVFocusable(
                              autofocus: isSelected,
                              focusColor: AppColors.primary,
                              borderRadius: 12,
                              onSelect: () {
                                Navigator.pop(context);
                                onSelect(i);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: isSelected ? null : Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final item = items[i];
                            final isSelected = i == currentIndex;
                            final logo =
                                item['logo'] ?? item['stream_icon'] ?? '';
                            return TVFocusable(
                              autofocus: isSelected,
                              focusColor: AppColors.primary,
                              borderRadius: 8,
                              onSelect: () {
                                Navigator.pop(context);
                                onSelect(i);
                              },
                              child: ListTile(
                                leading: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: logo.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            logo,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Iconsax.monitor,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                ),
                                title: Text(
                                  item['name'] ?? item['title'] ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Iconsax.play,
                                        color: AppColors.primary,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isLoading = false,
    bool autofocus = false,
  }) {
    return TVFocusable(
      autofocus: autofocus,
      focusColor: isPrimary ? AppColors.primary : Colors.white,
      borderRadius: 100,
      enableScale: true,
      onSelect: isLoading ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(isPrimary ? 12 : 8),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PlayerRemoteHandler(
        onPlayPause: () {
          _showControlsTemporarily();
          _togglePlay();
        },
        onSeekForward: _seekForward,
        onSeekBackward: _seekBackward,
        onBack: () => Navigator.pop(context),
        onChannelUp: _handleChannelUp,
        onChannelDown: _handleChannelDown,
        onShowEpisodes: (widget.episodes != null && widget.episodes!.isNotEmpty)
            ? _showEpisodesSheet
            : null,
        onShowChannels: (widget.channels != null && widget.channels!.isNotEmpty)
            ? _showChannelsSheet
            : null,
        onToggleControls: _toggleControls,
        child: Stack(
          children: [
            // 1. Native VLC Player
            AndroidView(
              viewType: 'native_vlc_player',
              creationParams: {'url': _currentUrl, 'isLive': widget.isLive},
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),

            // Error Overlay
            if (_hasError)
              Container(
                color: Colors.black87,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.shield_cross,
                      color: AppColors.danger,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TVFocusable(
                      autofocus: true,
                      focusColor: AppColors.primary,
                      onSelect: () => _loadNewMedia(_currentUrl, _currentTitle),
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _loadNewMedia(_currentUrl, _currentTitle),
                        icon: const Icon(Iconsax.refresh, color: Colors.white),
                        label: const Text(
                          "إعادة المحاولة الآن",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_isBuffering && !_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    if (_retryCount > 0) ...[
                      const SizedBox(height: 15),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // 2. UI Controls Overlay and Tap Detector
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.translucent,
                child: _showControls
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 20.0,
                              ),
                              child: Row(
                                children: [
                                  TVFocusable(
                                    focusColor: Colors.white54,
                                    borderRadius: 20,
                                    onSelect: () => Navigator.pop(context),
                                    child: IconButton(
                                      icon: const Icon(
                                        Iconsax.arrow_left,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _currentTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.isLive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "مباشر",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  TVFocusable(
                                    focusColor: Colors.white54,
                                    borderRadius: 20,
                                    onSelect: () {
                                      _startHideTimer();
                                      _channel?.invokeMethod('setAspectRatio', {
                                        'aspectRatio': 'FILL',
                                      });
                                    },
                                    child: IconButton(
                                      icon: const Icon(
                                        Iconsax.maximize_4,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _startHideTimer();
                                        _channel?.invokeMethod(
                                          'setAspectRatio',
                                          {'aspectRatio': 'FILL'},
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Center Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!widget.isLive) ...[
                                  _buildGlassButton(
                                    icon: Iconsax.backward_10_seconds,
                                    iconSize: 28,
                                    onTap: _seekBackward,
                                  ),
                                  const SizedBox(width: 25),
                                ],
                                _buildGlassButton(
                                  icon: _isPlaying
                                      ? Iconsax.pause
                                      : Iconsax.play,
                                  iconSize: 40,
                                  isPrimary: true,
                                  isLoading: _isBuffering,
                                  autofocus: true,
                                  onTap: _togglePlay,
                                ),
                                if (!widget.isLive) ...[
                                  const SizedBox(width: 25),
                                  _buildGlassButton(
                                    icon: Iconsax.forward_10_seconds,
                                    iconSize: 28,
                                    onTap: _seekForward,
                                  ),
                                ],
                              ],
                            ),

                            // Bottom Controls
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (widget.episodes != null &&
                                          widget.episodes!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TVFocusable(
                                            focusColor: Colors.white54,
                                            borderRadius: 20,
                                            onSelect: _showEpisodesSheet,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white24,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Iconsax.sort,
                                                size: 18,
                                              ),
                                              label: const Text(
                                                "الحلقات",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: _showEpisodesSheet,
                                            ),
                                          ),
                                        ),
                                      if (widget.channels != null &&
                                          widget.channels!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: TVFocusable(
                                            focusColor: Colors.white54,
                                            borderRadius: 20,
                                            onSelect: _showChannelsSheet,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white24,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Iconsax.monitor,
                                                size: 18,
                                              ),
                                              label: const Text(
                                                "القنوات",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: _showChannelsSheet,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (!widget.isLive)
                                    Row(
                                      children: [
                                        Text(
                                          _formatTime(_position),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                                  activeTrackColor:
                                                      AppColors.primary,
                                                  inactiveTrackColor:
                                                      Colors.white30,
                                                  thumbColor: Colors.white,
                                                  trackHeight: 4.0,
                                                ),
                                            child: Slider(
                                              min: 0,
                                              max: _duration > 0
                                                  ? _duration.toDouble()
                                                  : 100,
                                              value: _position.toDouble().clamp(
                                                0,
                                                _duration > 0
                                                    ? _duration.toDouble()
                                                    : 100,
                                              ),
                                              onChangeStart: (_) =>
                                                  _isDragging = true,
                                              onChanged: (val) {
                                                setState(
                                                  () => _position = val.toInt(),
                                                );
                                              },
                                              onChangeEnd: (val) {
                                                _seekTo(val);
                                              },
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatTime(_duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
