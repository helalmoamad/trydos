import 'package:audio_wave/audio_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceWavesInRecording extends StatefulWidget {
  const VoiceWavesInRecording({Key? key}) : super(key: key);

  @override
  State<VoiceWavesInRecording> createState() => _VoiceWavesInRecordingState();
}

class _VoiceWavesInRecordingState extends State<VoiceWavesInRecording> {
  final Color color = const Color(0xff388CFF);
  @override
  Widget build(BuildContext context) {
    return AudioWave(
      height: 20,
      width: 39.w,
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
      ],
      animation: true,
    );
  }
}
