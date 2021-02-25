extension ListEx<E> on List<E> {
  List<Y> transform<Y>(Y Function(int, E) fx) {
    List<Y> rl = [];
    int i = 0;
    this.forEach((e) {
      rl.add(fx(i, e));
      i++;
    });
    return rl;
  }
}
