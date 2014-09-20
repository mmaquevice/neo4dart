part of neo4dart;

class BatchToken {

  int id;
  String method;
  String to;
  Map body = {
  };

  BatchToken(this.method, this.to, this.body);
  BatchToken.withId(this.id, this.method, this.to, this.body);

  Map toJson() {
    Map map = new Map();
    if(this.id != null) {
      map["id"] = id;
    }
    map["method"] = method;
    map["to"] = to;
    map["body"] = body;
    return map;
  }

  String toString() {
    return '${toJson()}';
  }

}
