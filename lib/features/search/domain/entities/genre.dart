class Genre {
  final int id; // Thay đổi từ String sang int
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromMap(Map<String, dynamic> map) {
    return Genre(
      id: map['genre_id'] ?? 0, // Cập nhật tên cột
      name: map['name'] ?? 'Unknown',
    );
  }
}
