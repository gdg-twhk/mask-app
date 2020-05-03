import 'package:flutter/material.dart';

class BlinkingButton extends StatefulWidget {
  final Function onPressed;
  final bool enableBlink;

  const BlinkingButton({
    Key key,
    @required this.onPressed,
    this.enableBlink = true,
  }) : super(key: key);

  @override
  _BlinkingButtonState createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<BlinkingButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.enableBlink
          ? FadeTransition(
              opacity: _animationController,
              child: _button(),
            )
          : _button(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _button() {
    return Material(
      elevation: 12.0,
      borderRadius: BorderRadius.all(
        Radius.circular(36.0),
      ),
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(Icons.info_outline),
      ),
    );
  }
}
