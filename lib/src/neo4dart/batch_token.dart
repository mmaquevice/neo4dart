part of neo4dart;

class BatchToken {

  String method;
  String to;
  Map body = {
  };

  BatchToken(this.method, this.to, this.body);

  Map toJson() {
    Map map = new Map();
    map["method"] = method;
    map["to"] = to;
    map["body"] = body;
    return map;
  }

}
