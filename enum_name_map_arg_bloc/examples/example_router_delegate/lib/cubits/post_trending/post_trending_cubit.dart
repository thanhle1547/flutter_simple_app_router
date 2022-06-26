import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_data/mock_data.dart';

import 'post_trending_state.dart';

class PostTrendingCubit extends Cubit<PostTrendingState> {
  PostTrendingCubit() : super(PostTrendingState.loading()) {
    _loadData();
  }

  void _loadData() {
    emit(state.copyWith(
      isLoading: false,
      topOne: 'One',
      secondary: 'Two',
    ));
  }
}
