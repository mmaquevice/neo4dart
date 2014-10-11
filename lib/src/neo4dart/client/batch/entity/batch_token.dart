part of neo4dart;

class BatchToken {

  int id;
  String method;
  String to;
  Map body = {
  };

  BatchToken(this.method, this.to, this.body, {this.id});

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

  bool operator ==(o) => o is BatchToken && o.method == method && o.to == to && '${o.body}' == '$body';
  int get hashCode => hash2(method.hashCode, to.hashCode);

  String toString() {
    return '${toJson()}';
  }

}
