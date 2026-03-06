// ═══════════════════════════════════════════════════════════════
//  ForaTV - TV Remote / D-Pad Focus Navigation Helper
//  Provides focus support for TV, Desktop, and all platforms
//  Supports: D-Pad, Remote Control, Keyboard arrows, Tab
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Check if current platform is a TV / Desktop (large screen)
bool get isTV {
  try {
    return Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS;
  } catch (_) {
    return false;
  }
}

/// A focusable wrapper widget that highlights when focused (for TV/remote)
/// Works with D-Pad navigation, keyboard arrows, and remote controls
class TVFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final VoidCallback? onLongPress;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? focusColor;
  final double focusBorderWidth;
  final double borderRadius;
  final bool enableScale;

  const TVFocusable({
    super.key,
    required this.child,
    this.onSelect,
    this.onLongPress,
    this.autofocus = false,
    this.focusNode,
    this.focusColor,
    this.focusBorderWidth = 2.5,
    this.borderRadius = 14,
    this.enableScale = true,
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus && widget.enableScale) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.gameButtonA ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        widget.onSelect?.call();
        return KeyEventResult.handled;
      }
      // Long press simulation with menu key
      if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
        widget.onLongPress?.call();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.primary;

    Widget child = Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocusChange: _onFocusChange,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        onTap: widget.onSelect,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _isFocused
                ? Border.all(color: focusColor, width: widget.focusBorderWidth)
                : Border.all(
                    color: Colors.transparent,
                    width: widget.focusBorderWidth,
                  ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: focusColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.enableScale) {
      child = ScaleTransition(scale: _scaleAnimation, child: child);
    }

    return child;
  }
}

/// A focusable text field for TV - shows virtual keyboard when selected
class TVFocusableTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextDirection? textDirection;
  final bool obscure;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? focusColor;

  const TVFocusableTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.textDirection,
    this.obscure = false,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.focusColor,
  });

  @override
  State<TVFocusableTextField> createState() => _TVFocusableTextFieldState();
}

class _TVFocusableTextFieldState extends State<TVFocusableTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: _isFocused
            ? Border.all(color: focusColor, width: 2.5)
            : Border.all(color: Colors.transparent, width: 2.5),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: focusColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscure,
            textDirection: widget.textDirection,
            autofocus: widget.autofocus,
            style: const TextStyle(color: Color(0xFFEAEAF0)),
            decoration: InputDecoration(
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF6B6B80),
                size: 22,
              ),
              suffixIcon: widget.suffixIcon,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6B6B80),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper for bottom navigation that handles D-Pad left/right to switch tabs
class TVBottomNavWrapper extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final int itemCount;
  final Widget child;

  const TVBottomNavWrapper({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.itemCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (currentIndex > 0) {
              onIndexChanged(currentIndex - 1);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (currentIndex < itemCount - 1) {
              onIndexChanged(currentIndex + 1);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// D-Pad aware scrollable grid wrapper
/// Handles D-Pad arrow keys for smooth grid navigation
class TVGridNavigator extends StatelessWidget {
  final ScrollController? scrollController;
  final Widget child;

  const TVGridNavigator({
    super.key,
    this.scrollController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: child,
    );
  }
}

/// A focusable list item for bottom sheets, categories, etc.
class TVFocusableListItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onSelect;
  final bool autofocus;
  final FocusNode? focusNode;

  const TVFocusableListItem({
    super.key,
    required this.child,
    required this.onSelect,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<TVFocusableListItem> createState() => _TVFocusableListItemState();
}

class _TVFocusableListItemState extends State<TVFocusableListItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final focusColor = Theme.of(context).colorScheme.primary;

    return Focus(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            widget.onSelect();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: _isFocused
                ? Border.all(color: focusColor, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.circular(14),
            color: _isFocused ? focusColor.withValues(alpha: 0.08) : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A wrapper for the entire app to handle global remote key events
/// like Back button, Menu, etc.
class TVRemoteHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const TVRemoteHandler({
    super.key,
    required this.child,
    this.onBack,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
        const SingleActivator(LogicalKeyboardKey.browserBack):
            const DismissIntent(),
        const SingleActivator(LogicalKeyboardKey.goBack): const DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.maybePop(context);
              }
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Player remote control handler for controlling playback via D-Pad
class PlayerRemoteHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onBack;
  final VoidCallback? onChannelUp;
  final VoidCallback? onChannelDown;
  final VoidCallback? onShowEpisodes;
  final VoidCallback? onShowChannels;
  final VoidCallback? onToggleControls;

  const PlayerRemoteHandler({
    super.key,
    required this.child,
    required this.onPlayPause,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onBack,
    this.onChannelUp,
    this.onChannelDown,
    this.onShowEpisodes,
    this.onShowChannels,
    this.onToggleControls,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final key = event.logicalKey;

        // Play/Pause - Center/Enter/Play button
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.mediaPlayPause ||
            key == LogicalKeyboardKey.space) {
          onPlayPause();
          return KeyEventResult.handled;
        }

        // Seek forward - Right arrow / Fast Forward
        if (key == LogicalKeyboardKey.arrowRight ||
            key == LogicalKeyboardKey.mediaFastForward) {
          onSeekForward();
          return KeyEventResult.handled;
        }

        // Seek backward - Left arrow / Rewind
        if (key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.mediaRewind) {
          onSeekBackward();
          return KeyEventResult.handled;
        }

        // Channel Up / Next - Arrow Up or Channel Up
        if (key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.channelUp) {
          onChannelUp?.call();
          return KeyEventResult.handled;
        }

        // Channel Down / Previous - Arrow Down or Channel Down
        if (key == LogicalKeyboardKey.arrowDown ||
            key == LogicalKeyboardKey.channelDown) {
          onChannelDown?.call();
          return KeyEventResult.handled;
        }

        // Back button
        if (key == LogicalKeyboardKey.escape ||
            key == LogicalKeyboardKey.browserBack ||
            key == LogicalKeyboardKey.goBack) {
          onBack();
          return KeyEventResult.handled;
        }

        // Media Stop
        if (key == LogicalKeyboardKey.mediaStop) {
          onBack();
          return KeyEventResult.handled;
        }

        // Menu / Info button - Show episodes or channels
        if (key == LogicalKeyboardKey.contextMenu ||
            key == LogicalKeyboardKey.f1) {
          onShowEpisodes?.call();
          return KeyEventResult.handled;
        }

        // Guide button - Show channels
        if (key == LogicalKeyboardKey.f2) {
          onShowChannels?.call();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// A focusable dropdown button for TV remote
class TVFocusableDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget? hint;
  final bool autofocus;
  final Color? dropdownColor;

  const TVFocusableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.autofocus = false,
    this.dropdownColor,
  });

  @override
  State<TVFocusableDropdown<T>> createState() => _TVFocusableDropdownState<T>();
}

class _TVFocusableDropdownState<T> extends State<TVFocusableDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final focusColor = Theme.of(context).colorScheme.primary;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // Trigger the dropdown
            return KeyEventResult.ignored; // Let the dropdown handle it
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: _isFocused
              ? Border.all(color: focusColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: focusColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            hint: widget.hint,
            isExpanded: true,
            dropdownColor: widget.dropdownColor,
            iconEnabledColor: const Color(0xFF6B6B80),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
      ),
    );
  }
}
