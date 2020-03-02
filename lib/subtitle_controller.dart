import 'dart:convert';

import 'package:subtitle_wrapper_package/models/subtitle.dart';
import 'package:subtitle_wrapper_package/models/subtitles.dart';
import 'package:http/http.dart' as http;

class SubtitleController {
  String subtitlesContent;
  String subtitleUrl;
  final bool showSubtitles;
  final bool usingComma;

  SubtitleController(
      {this.subtitleUrl,
      this.subtitlesContent,
      this.showSubtitles = true,
      this.usingComma = false});

  Future<Subtitles> getSubtitles() async {
    var separate = usingComma == true ? ',' : '.';
    RegExp regExp = new RegExp(
      r"^((\d{2}):(\d{2}):(\d{2})\" +
          separate +
          r"(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\" +
          separate +
          r"(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*)",
      caseSensitive: false,
      multiLine: true,
    );

    if (subtitlesContent == null && subtitleUrl != null) {
      http.Response response = await http.get(subtitleUrl);
      if (response.statusCode == 200) {
        subtitlesContent = utf8.decode(response.bodyBytes);
      }
    }
    print(subtitlesContent);

    List<RegExpMatch> matches = regExp.allMatches(subtitlesContent).toList();
    List<Subtitle> subtitleList = List();

    matches.forEach((RegExpMatch regExpMatch) {
      int startTimeHours = int.parse(regExpMatch.group(2));
      int startTimeMinutes = int.parse(regExpMatch.group(3));
      int startTimeSeconds = int.parse(regExpMatch.group(4));
      int startTimeMilliseconds = int.parse(regExpMatch.group(5));

      int endTimeHours = int.parse(regExpMatch.group(7));
      int endTimeMinutes = int.parse(regExpMatch.group(8));
      int endTimeSeconds = int.parse(regExpMatch.group(9));
      int endTimeMilliseconds = int.parse(regExpMatch.group(10));
      String text = removeAllHtmlTags(regExpMatch.group(11));

      print(text);

      Duration startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds);
      Duration endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds);

      subtitleList.add(
          Subtitle(startTime: startTime, endTime: endTime, text: text.trim()));
    });
    print(subtitleList);

    Subtitles subtitles = Subtitles(subtitles: subtitleList);
    return subtitles;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"(<[^>]*>)", multiLine: true, caseSensitive: true);
    String newHtmlText = htmlText;
    exp.allMatches(htmlText).toList().forEach((RegExpMatch regExpMathc) {
      print(regExpMathc.group(0));
      if (regExpMathc.group(0) == "<br>") {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '\n');
      } else {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '');
      }
    });
    return newHtmlText;
  }
}
