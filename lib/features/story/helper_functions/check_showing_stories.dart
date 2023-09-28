import 'package:trydos/features/story/data/models/get_stories_model.dart';


bool CheckShowingStories(List<Story> stories) {
  int count = 0;
  for (var e in stories) {
    if (e.isSeen!) {
      count++;
    }
  }

  return (count == stories.length) ? true : false;
}

int firstWhereNotShowed(List<Story> stories) {
  int index = 0;
  stories.forEach((element) {
    if (element.isSeen!) {
      index++;
    }
  });

  if (stories.length == index) return index - 1;
  return index;
}
