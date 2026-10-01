class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? createdAt;
  final String? avatar;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Crypto Researcher',
      email: json['email']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
      'avatar': avatar,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? createdAt,
    String? avatar,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
    );
  }
}
