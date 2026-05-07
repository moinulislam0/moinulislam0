class BlockedUserModel {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String about;
  final String city;
  final String state;
  final String country;
  final String address;

  const BlockedUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.about,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];
    final source = nestedUser is Map<String, dynamic> ? nestedUser : json;

    return BlockedUserModel(
      id: _readString(source, ['id', 'user_id']),
      name: _readString(source, ['name']),
      username: _readString(source, ['username']),
      avatar: _readString(source, ['avatar']),
      about: _readString(source, ['about']),
      city: _readString(source, ['city']),
      state: _readString(source, ['state']),
      country: _readString(source, ['country']),
      address: _readString(source, ['address', 'location']),
    );
  }

  String get displayName => name.isNotEmpty ? name : 'Unknown User';

  String get displayHandle =>
      username.isNotEmpty ? '@$username' : '@silentwhistle-user';

  String get locationText {
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    if (address.isNotEmpty) {
      return address;
    }

    return 'Location not available';
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }
}
