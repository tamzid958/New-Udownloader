import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> get localPath async {
  final dir = await getExternalStorageDirectory();
  return dir!.path.toString();
}

Future<File> localFile(String fileName) async {
  final path = await localPath;
  print(path);
  return File('$path/$fileName');
}

Future<bool> download(String id, String fileType) async {
  final YoutubeExplode yt = YoutubeExplode();
  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  var streams;
  String type;
  try {
    Video video = await yt.videos.get(id);

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

    var audio = streams.first;
    var audioStream = yt.videos.streamsClient.get(audio);

    var fileName = '${video.title}_$type.${audio.container.name.toString()}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '')
        .replaceAll(' ', '_')
        .replaceAll('!', '');

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
    /*  if (type == "audio") {
      final path = await localPath;
      _flutterFFmpeg
          .execute(
              "ffmpeg -i '$path/$fileName' -vn '$path/$fileNameWithoutExtension.mp3'")
          .then(
            (rc) => print("FFmpeg process exited with rc $rc"),
          );
    } */
    // _flutterFFmpeg.cancel();
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}
