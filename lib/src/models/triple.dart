class Triple<A, B, C> {
  final A first;
  final B second;
  final C third;

  Triple(this.first, this.second, this.third);

  @override
  String toString() {
    return 'Pair{first: $first, second: $second}';
  }
}
