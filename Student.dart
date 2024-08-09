import 'dart:convert';
import 'dart:io';

class Course {
  String courseName;
  List<double> scores;

  Course({required this.courseName, required this.scores});

  Map<String, dynamic> toJson() => {
    'course_name': courseName,
    'scores': scores,
  };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['course_name'],
      scores: List<double>.from(json['scores']),
    );
  }
}

class Student {
  String id;
  String name;
  List<Course> courses;

  Student({required this.id, required this.name, required this.courses});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'courses': courses.map((course) => course.toJson()).toList(),
  };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      courses: (json['courses'] as List)
          .map((course) => Course.fromJson(course))
          .toList(),
    );
  }
}

Future<List<Student>> readData(String fileName) async {
  try {
    final file = File(fileName);
    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((json) => Student.fromJson(json)).toList();
    }
  } catch (e) {
    print('Error reading file: $e');
  }
  return [];
}

Future<void> writeData(String fileName, List<Student> students) async {
  try {
    final file = File(fileName);
    final jsonData = json.encode(students.map((student) => student.toJson()).toList());
    await file.writeAsString(jsonData);
  } catch (e) {
    print('Error writing to file: $e');
  }
}

void displayStudents(List<Student> students) {
  for (var student in students) {
    print('ID: ${student.id}, Name: ${student.name}');
    for (var course in student.courses) {
      print('  Course: ${course.courseName}, Scores: ${course.scores}');
    }
  }
}

void addStudent(List<Student> students) {
  stdout.write('nhập ID sinh viên: ');
  String id = stdin.readLineSync()!;
  stdout.write('nhập tên sinh viên: ');
  String name = stdin.readLineSync()!;

  List<Course> courses = [];
  while (true) {
    stdout.write("Nhập Tên khóa học (hoặc 'hoàn thành' để kết thúc): ");
    String courseName = stdin.readLineSync()!;
    if (courseName.toLowerCase() == 'done') {
      break;
    }
    stdout.write('Nhập điểm cách nhau bằng dấu cách: ');
    List<double> scores = stdin.readLineSync()!
        .split(' ')
        .map((score) => double.parse(score))
        .toList();
    courses.add(Course(courseName: courseName, scores: scores));
  }

  students.add(Student(id: id, name: name, courses: courses));
  print('Sinh viên được thêm thành công!');
}

void editStudent(List<Student> students) {
  stdout.write('Nhập Mã sinh viên để chỉnh sửa: ');
  String id = stdin.readLineSync()!;
  for (var student in students) {
    if (student.id == id) {
      stdout.write('Enter new name (current: ${student.name}): ');
      student.name = stdin.readLineSync()!;
      return;
    }
  }
  print('Không tìm thấy sinh viên!');
}

void searchStudent(List<Student> students) {
  stdout.write('Nhập mã số sinh viên hoặc tên để tìm kiếm: ');
  String keyword = stdin.readLineSync()!.toLowerCase();
  for (var student in students) {
    if (student.id.toLowerCase().contains(keyword) ||
        student.name.toLowerCase().contains(keyword)) {
      print('ID: ${student.id}, Name: ${student.name}');
      return;
    }
  }
  print('Không tìm thấy sinh viên!');
}

void displayHighestScoreStudent(List<Student> students) {
  double highestScore = -1;
  Student? topStudent;
  for (var student in students) {
    for (var course in student.courses) {
      double maxScore = course.scores.reduce((a, b) => a > b ? a : b);
      if (maxScore > highestScore) {
        highestScore = maxScore;
        topStudent = student;
      }
    }
  }
  if (topStudent != null) {
    print(
        'Student with highest score: ID: ${topStudent.id}, Name: ${topStudent.name}, Highest Score: $highestScore');
  } else {
    print('Không tìm thấy sinh viên!');
  }
}

void main() async {
  String fileName = 'student.json';
  List<Student> students = await readData(fileName);

  while (true) {
    print('\nHệ thống quản lý sinh viên');
    print('1.  Hiển thị toàn bộ sinh viên');
    print('2.  Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên theo Tên hoặc ID');
    print('5. Hiển thị sinh viên có điểm thi môn cao nhất');
    print('6. Exit');

    stdout.write('Enter your choice: ');
    String choice = stdin.readLineSync()!;

    switch (choice) {
      case '1':
        displayStudents(students);
        break;
      case '2':
        addStudent(students);
        await writeData(fileName, students);
        break;
      case '3':
        editStudent(students);
        await writeData(fileName, students);
        break;
      case '4':
        searchStudent(students);
        break;
      case '5':
        displayHighestScoreStudent(students);
        break;
      case '6':
        exit(0);
      default:
        print('Lựa chọn không hợp lệ! Vui lòng thử lại.');
    }
  }
}
