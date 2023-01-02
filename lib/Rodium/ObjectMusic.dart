class User {
  int? id;
  String? user_name;
  String? profile_picture;
  bool? isFollowing;
  User({
    id,
    user_name,
    profile_picture,
    isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        user_name: json["user_name"],
        profile_picture: json["profile_picture"],
        isFollowing: json["is_following"],
      );
}
