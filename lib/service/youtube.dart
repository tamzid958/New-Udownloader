import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> get localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<File> localFile(String fileName) async {
  final path = await localPath;
  print(path);
  return File('$path/$fileName');
}

Future<bool> download(String id, String fileType) async {
  final YoutubeExplode yt = YoutubeExplode();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  try {
    var streams;
    String type;
    // Get video metadata.
    Video video = await yt.videos.get(id);

    // Get the video manifest.
    StreamManifest manifest = await yt.videos.streamsClient.getManifest(id);
    if (fileType == "audio") {
      streams = manifest.audioOnly;
      type = "audio";
    } else if (fileType == "video") {
      streams = manifest.muxed;
      type = "video";
    } else {
      return false;
    }

    // Get the audio track with the highest bitrate.
    var audio = streams.first;
    var audioStream = yt.videos.streamsClient.get(audio);

    // Compose the file name removing the unallowed characters in windows.
    var fileName = '${video.title}_$type.${audio.container.name.toString()}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');

    var _file = await localFile(fileName);
    if (_file.existsSync()) {
      _file.deleteSync();
    } else {
      _file.createSync();
    }
    var output = _file.openWrite(mode: FileMode.writeOnly);
    await for (final data in audioStream) {
      output.add(data);
    }
    await output.close();
    yt.close();
    if (type == " audio") {
      final path = await localPath;
      _flutterFFmpeg
          .execute("ffmpeg -I $path/$fileName -vn ${video.title}_$type.mp3")
          .then((rc) => print("FFmpeg process exited with rc $rc"));
    }
    return true;
  } catch (Excecption) {
    print(Excecption.toString());
    return false;
  }
}
