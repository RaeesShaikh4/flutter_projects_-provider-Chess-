class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  Position operator +(Position other) {
    return Position(row + other.row, col + other.col);
  }

  Position operator -(Position other) {
    return Position(row - other.row, col - other.col);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() {
    return '($row, $col)';
  }

  // Convert to algebraic notation (e.g., "e4")
  String toAlgebraic() {
    if (!isValid) return '';
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  // Create from algebraic notation
  static Position fromAlgebraic(String notation) {
    if (notation.length != 2) throw ArgumentError('Invalid algebraic notation');
    final col = notation[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(notation[1]);
    return Position(row, col);
  }
}

