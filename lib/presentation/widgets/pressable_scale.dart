import 'package:flutter/material.dart';

/// Wraps [child] with a subtle press-down scale micro-interaction, used on
/// primary CTAs/quick actions instead of a plain `InkWell` ripple.
///
/// Purely visual: it watches pointer-down/up via [Listener] rather than
/// claiming the tap gesture itself, so [child]'s own `onPressed`/`onTap`
/// (e.g. a `FilledButton`) keeps firing exactly once -- wrapping a button
/// in this widget never double-invokes its action.
class PressableScale extends StatefulWidget {
  final Widget child;

  /// Disables the press animation (mirrors the child button's disabled
  /// state) without needing to duplicate its onPressed here.
  final bool enabled;

  const PressableScale({super.key, required this.child, this.enabled = true});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: _pressed ? 120 : 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
