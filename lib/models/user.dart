enum UserRole { guest, user, admin }

class User {
  final String uid;
  final String email;
  final String? name;
  final UserRole role;

  User({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
  });

  factory User.guest() {
    return User(
      uid: 'guest',
      email: 'guest',
      role: UserRole.guest,
    );
  }
}