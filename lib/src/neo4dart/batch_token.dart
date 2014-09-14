part of neo4dart;

class BatchToken {

  int id;
  String method;
  String to;
  Map body = {
  };

  BatchToken(this.id, this.method, this.to);

  Map toJson() {
    Map map = new Map();
    map["id"] = id;
    map["method"] = method;
    map["to"] = to;
    map["body"] = body;
    return map;
  }

}
