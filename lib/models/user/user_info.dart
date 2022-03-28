class UserInfo {
  int id;
  String name;
  String email;
  String createdAt;
  String updatedAt;

  UserInfo({
    this.id,
    this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory UserInfo.fromMap(Map<String, dynamic> json) => UserInfo(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );
}
