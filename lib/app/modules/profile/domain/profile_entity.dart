final class ProfileEntity {
  ProfileEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    if (name.trim().isEmpty || name.length > 120) {
      throw ArgumentError.value(name, 'name');
    }
    if (phoneNumber.length > 32) {
      throw ArgumentError.value(phoneNumber, 'phoneNumber');
    }
    if (email != null && email!.length > 254) {
      throw ArgumentError.value(email, 'email');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not precede createdAt.');
    }
  }

  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;
}
