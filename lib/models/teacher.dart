class Teacher {
  String name;
  String surname;
  int age;
  bool female;

  Teacher(this.name, this.surname, this.age, this.female);

  Teacher.fromMap(Map<String, dynamic> m)
      : name = m["name"],
        surname = m["surname"],
        age = m["age"],
        female = m["female"];

  Map toMap() {
    return{
    "name" : name,
    "surname" : surname,
    "age" : age,
    "female" : female,
    };
  }
}
