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
//    todo  remember to break when meat first story not seen
//    else break;
  });

  if (stories.length == index) return 0;
  return index;
}

int lastWhereNotShowed(List<Story> stories)
{
  stories.lastIndexWhere((element) => element.isSeen==false);
  int index = 0;
  stories.forEach((element) {
    if (element.isSeen!) {
      index++;
    }
//    todo  remember to break when meat first story not seen
//    else break;
  });

  if (stories.length == index) return index - 1;
  return index;

}

int firstWhereNotShowedStoryCollection(List<Story> stories) {
  int index = 0;
  stories.forEach((element) {
    if (element.isSeen!) {
      index++;
    }
//    todo  remember to break when meat first story not seen
//    else break;
  });

  if (stories.length == index) return index ;
  return index-1;
}