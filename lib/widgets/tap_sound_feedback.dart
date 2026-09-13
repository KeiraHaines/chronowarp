import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '../services/tap_sound.dart';

/// Observes taps without competing with buttons or scrolling gestures.
class TapSoundFeedback extends StatefulWidget {
  const TapSoundFeedback({super.key, required this.child, this.onTapSound});
  final Widget child;
  final VoidCallback? onTapSound;
  @override
  State<TapSoundFeedback> createState() => _TapSoundFeedbackState();
}

class _TapSoundFeedbackState extends State<TapSoundFeedback> {
  final _starts = <int, PointerDownEvent>{};
  final _rating = <int, bool>{};
  void _down(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    final result = HitTestResult();
    GestureBinding.instance.hitTestInView(result, event.position, event.viewId);
    final actionable = result.path.any((entry) {
      final target = entry.target;
      if (target is RenderSemanticsGestureHandler) return target.onTap != null;
      if (target is RenderSemanticsAnnotations) {
        return target.properties.button == true &&
            target.properties.enabled != false;
      }
      return false;
    });
    if (actionable) {
      _starts[event.pointer] = event;
      _rating[event.pointer] = result.path.any(
        (e) => e.target is _RateSoundMarker,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _down,
    onPointerMove: (event) {
      final start = _starts[event.pointer];
      if (start != null && (event.position - start.position).distance > 12) {
        _starts.remove(event.pointer);
        _rating.remove(event.pointer);
      }
    },
    onPointerCancel: (event) {
      _starts.remove(event.pointer);
      _rating.remove(event.pointer);
    },
    onPointerUp: (event) {
      final start = _starts.remove(event.pointer);
      final rating = _rating.remove(event.pointer) ?? false;
      if (start != null &&
          event.timeStamp - start.timeStamp <
              const Duration(milliseconds: 500)) {
        if (widget.onTapSound != null) {
          widget.onTapSound!();
        } else {
          unawaited(TapSound.play(rating: rating));
        }
      }
    },
    child: widget.child,
  );
}

/// Retains the original bright click for rating controls.
class RateSound extends SingleChildRenderObjectWidget {
  const RateSound({super.key, required super.child});
  @override
  RenderProxyBox createRenderObject(BuildContext context) => _RateSoundMarker();
}

class _RateSoundMarker extends RenderProxyBox {}
