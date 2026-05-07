class ReplyCommentModel {
  String? content;
  String? parentId;

  ReplyCommentModel({this.content, this.parentId});

  ReplyCommentModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    parentId = json['parent_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['parent_id'] = this.parentId; 
    return data;
  }
}