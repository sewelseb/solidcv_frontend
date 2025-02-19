import 'dart:io';

class Certificate {
  String? id;
  String? title;
  String? type;
  String? grade;
  String? curriculum;
  String? description;
  String? publicationDate;
  String? imagelink;
  File? file;
  String? ipfsHash;
  String? documentIPFSUrl;

  Certificate({this.id, this.title, this.type, this.grade, this.curriculum, this.description, this.publicationDate, this.imagelink, this.file, this.ipfsHash, this.documentIPFSUrl});

  Certificate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    grade = json['grade'];
    curriculum = json['curriculum'];
    description = json['description'];
    publicationDate = json['publicationDate'];
    imagelink = json['imagelink'];
    file = json['file'];
    ipfsHash = json['ipfsHash'];
    documentIPFSUrl = json['documentIPFSUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'grade': grade,
      'curriculum': curriculum,
      'description': description,
      'publicationDate': publicationDate,
      'imagelink': imagelink,
      'file': file,
      'ipfsHash': ipfsHash,
      'documentIPFSUrl': documentIPFSUrl,
    };
  }
}