class PostTrendingState {
  final bool isLoading;
  final String? topOne;
  final String? secondary;

  PostTrendingState({
    required this.isLoading,
    this.topOne,
    this.secondary,
  });

  factory PostTrendingState.loading() => PostTrendingState(
        isLoading: true,
      );

  PostTrendingState copyWith({
    bool? isLoading,
    String? topOne,
    String? secondary,
  }) =>
      PostTrendingState(
        isLoading: isLoading ?? this.isLoading,
        topOne: topOne ?? this.topOne,
        secondary: secondary ?? this.secondary,
      );
}
