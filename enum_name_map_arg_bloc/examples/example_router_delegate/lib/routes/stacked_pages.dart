import 'app_pages.dart';

enum AppPageStack {
  tredingPost,
  detailTredingPost,
}

late final Map<AppPageStack, List<Enum>> stackedPages = {
  AppPageStack.tredingPost: [
    AppPages.Post_Published,
    AppPages.Post_Trending,
  ],
  AppPageStack.detailTredingPost: [
    AppPages.Post_Published,
    AppPages.Post_Trending,
    AppPages.Post_Detail,
  ],
};
