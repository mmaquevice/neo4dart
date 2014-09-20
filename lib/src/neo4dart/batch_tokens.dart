part of neo4dart;

class BatchTokens {

  Set<BatchToken> batchTokens = new Set();

  Set<Node> nodesWithRelationsConverted = new Set();

  BatchTokens();

  BatchToken findTokenFromNode(Node node) {
    if(node == null) {
      return null;
    }

    BatchToken token = findTokenWith(node.toJson());
    return token;
  }

  BatchToken findTokenWith(Map body) {
    if(batchTokens == null) {
      return null;
    }

    BatchToken found;
    batchTokens.forEach((batchToken) {
      if(batchToken != null) {
        // TODO mma - find a way to correctly verify equality
        if ('${batchToken.body}' == '${body}') {
          found = batchToken;
        }
      }
    });

    return found;
  }

  int findIdNotUsed() {
    int max = -1;
    batchTokens.forEach((batchToken) {
      if(batchToken != null) {
        if (batchToken.id != null) {
          if (batchToken.id > max) {
            max = batchToken.id;
          }
        }
      }
    });
    return max+1;
  }

}
