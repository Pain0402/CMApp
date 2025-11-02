class FilterOptions {
  final Set<int> genreIds;

  const FilterOptions({this.genreIds = const {}});

  FilterOptions copyWith({Set<int>? genreIds}) {
    return FilterOptions(genreIds: genreIds ?? this.genreIds);
  }
}
