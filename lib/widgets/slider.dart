import 'package:flutter/material.dart';

class DelaySlider extends StatefulWidget {
  // 遅延時間
  final int? delay;
  // 保存時の動作
  final void Function(int?) onSave;

  const DelaySlider({super.key, this.delay, required this.onSave});
  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class _DelaySliderState extends State<DelaySlider> {
  // 現在の遅延時間
  int? delay;
  // 保存状態
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          setState(() {
            saved = false;
          });
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
                widget.onSave(delay);
                setState(() {
                  saved = true;
                });
              },
        enableFeedback: true,
      ),
    );
  }
}
