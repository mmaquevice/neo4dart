part of neo4dart;

class BatchTokens {

  Set<BatchToken> batchTokens = new Set();

  BatchTokens();

  int findTokenIdFromNode(Node node) {
    if(node == null) {
      return null;
    }

    int tokenId = findTokenIdWith(node.toJson());

    print('Token found : ${tokenId}');

    return findTokenIdWith(node.toJson());
  }

  int findTokenIdWith(Map body) {
    if(batchTokens == null) {
      return null;
    }

    int found;
    batchTokens.forEach((batchToken) {
      if(batchToken != null) {
        print('BODY to test : ${body}');
        print('BODY of list : ${batchToken.body}');
        // TODO mma - find a way to correctly verify equality
        if ('${batchToken.body}' == '${body}') {
          found = batchToken.id;
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
