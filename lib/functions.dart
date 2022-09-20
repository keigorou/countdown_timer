String changeToMMSS(int second) {
  if (second >= 60) {
    if ((second % 60) < 10) {
      return "${second ~/ 60}:0${second % 60}";
    } else {
      return "${second ~/ 60}:${second % 60}";
    }
  } else if ((second % 60) < 10) {
    return "0:0${second % 60}";
  } else {
    return "0:${second % 60}";
  }
}