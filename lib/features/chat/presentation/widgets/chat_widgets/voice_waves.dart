
import 'package:audio_wave/audio_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceWaves extends StatefulWidget {
  const VoiceWaves({Key? key , this.animation=true , this.animationDuration=Duration.zero}) : super(key: key);
  final bool animation;
  final Duration animationDuration;
  @override
  State<VoiceWaves> createState() => _VoiceWavesState();
}

class _VoiceWavesState extends State<VoiceWaves> with SingleTickerProviderStateMixin{
  final Color color=const Color(0xff388CFF);
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)..addListener(() {
      setState(() {

      });
    });
   // animationController.forward();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        //widthFactor: animation.value,
        child: AudioWave(
          height: 20,
          spacing: 1.3,
          bars: [
            AudioWaveBar(heightFactor: 0.14, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.14, color: color),
            AudioWaveBar(heightFactor: 0.14, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.14, color: color),
            AudioWaveBar(heightFactor: 0.14, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 1, color: color),
            AudioWaveBar(heightFactor: 0.6, color: color),
            AudioWaveBar(heightFactor: 0.45, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.35, color: color),
            AudioWaveBar(heightFactor: 0.2, color: color),
            AudioWaveBar(heightFactor: 0.14, color: color),
          ],
          animation: false,
        ),
      ),
    );
  }
}
