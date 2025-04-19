abstract class BaseModel {
  String id;

  BaseModel({required this.id});

  Map<String, dynamic> toMap();

  // Change to abstract method
  BaseModel fromMap(Map<String, dynamic> map, String id);
}
