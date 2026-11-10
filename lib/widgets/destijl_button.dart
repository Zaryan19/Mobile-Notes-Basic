import 'package:flutter/material.dart';
import '../theme/destijl_theme.dart';

/// Brutalist De Stijl tactile button with 0px corner radius,
/// 2dp solid black borders, and hard 0-blur drop shadow with mechanical press effect.
class DeStijlButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final double shadowOffset;
  final bool isSquare;
  final double? width;
  final double? height;

  const DeStijlButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor = DeStijlTheme.white,
    this.foregroundColor = DeStijlTheme.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.borderWidth = DeStijlTheme.borderWidth,
    this.shadowOffset = 4.0,
    this.isSquare = false,
    this.width,
    this.height,
  });

  /// Factory constructor for Primary Blue CTA button (e.g., FAB or Confirm)
  factory DeStijlButton.primaryBlue({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double? width,
    double? height,
    bool isSquare = false,
  }) {
    return DeStijlButton(
      key: key,
      child: child,
      onPressed: onPressed,
      backgroundColor: DeStijlTheme.primaryBlue,
      foregroundColor: DeStijlTheme.white,
      padding: padding,
      width: width,
      height: height,
      isSquare: isSquare,
    );
  }

  /// Factory constructor for Primary Red Destructive button (e.g., Delete)
  factory DeStijlButton.primaryRed({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12.0),
    double? width,
    double? height,
    bool isSquare = false,
  }) {
    return DeStijlButton(
      key: key,
      child: child,
      onPressed: onPressed,
      backgroundColor: DeStijlTheme.primaryRed,
      foregroundColor: DeStijlTheme.white,
      padding: padding,
      width: width,
      height: height,
      isSquare: isSquare,
    );
  }

  /// Factory constructor for Primary Yellow Accent button
  factory DeStijlButton.primaryYellow({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12.0),
    double? width,
    double? height,
    bool isSquare = false,
  }) {
    return DeStijlButton(
      key: key,
      child: child,
      onPressed: onPressed,
      backgroundColor: DeStijlTheme.primaryYellow,
      foregroundColor: DeStijlTheme.black,
      padding: padding,
      width: width,
      height: height,
      isSquare: isSquare,
    );
  }

  @override
  State<DeStijlButton> createState() => _DeStijlButtonState();
}

class _DeStijlButtonState extends State<DeStijlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOffset = _isPressed ? 1.0 : widget.shadowOffset;
    final translateOffset = _isPressed ? widget.shadowOffset - 1.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
        }
      },
      child: Transform.translate(
        offset: Offset(translateOffset, translateOffset),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.zero, // STRICTLY 0px
            border: Border.all(
              color: DeStijlTheme.black,
              width: widget.borderWidth,
            ),
            boxShadow: effectiveOffset > 0
                ? [
                    BoxShadow(
                      color: DeStijlTheme.black,
                      offset: Offset(effectiveOffset, effectiveOffset),
                      blurRadius: 0.0,
                    ),
                  ]
                : null,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: widget.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: widget.foregroundColor,
                size: 20.0,
              ),
              child: Center(
                widthFactor: widget.width == null ? 1.0 : null,
                heightFactor: widget.height == null ? 1.0 : null,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

