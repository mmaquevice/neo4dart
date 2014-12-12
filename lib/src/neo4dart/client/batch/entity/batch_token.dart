part of neo4dart;

class BatchToken {

  int id;
  String method;
  String to;
  Object body = {
  };
  NeoEntity neoEntity;

  BatchToken(this.method, this.to, this.body, {this.id, this.neoEntity});

  factory BatchToken.createNodeToken(Node node, {int id}) {
    return new BatchToken("POST", "/node",  findFieldsAnnotatedValueByKey(node, Data), id : id, neoEntity: node);
  }

  factory BatchToken.createLabelToken(Node node, int nodeTokenId, {int id}) {
    Type type = reflectClass(node.runtimeType).reflectedType;
    return new BatchToken("POST", "{${nodeTokenId}}/labels", '$type', id: id);
  }

  factory BatchToken.createRelationToken(RelationshipWithNodes relation, BatchToken startToken, BatchToken endToken, {int id}) {

    if ((startToken == null && relation.startNode.id == null) || (endToken == null && relation.endNode.id == null)) {
      throw "Batch token cannot be created.";
    }

    var to = "";
    if (startToken == null) {
      to = "/node/${relation.startNode.id}/relationships";
    } else {
      to = "{${startToken.id}}/relationships";
    }

    var body = {
    };
    if (endToken == null) {
      body = {
          'to' : '/node/${relation.endNode.id}', 'data' : relation.relationship.data, 'type' : '${relation.relationship.type}'
      };
    } else {
      body = {
          'to' : '{${endToken.id}}', 'data' : relation.relationship.data, 'type' : '${relation.relationship.type}'
      };
    }

    return new BatchToken("POST", to, body, id : id, neoEntity: relation.initialRelationship);
  }

  Map toJson() {
    Map map = new Map();
    if (this.id != null) {
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
