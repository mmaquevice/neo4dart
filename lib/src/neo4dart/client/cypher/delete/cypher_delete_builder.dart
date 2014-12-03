part of neo4dart;

class CypherDeleteBuilder {

  final _logger = new Logger("CypherDeleteBuilder");

  String buildQueryToDeleteNodes(Iterable<int> nodeIds, Type type, {bool force: false}) {

    if (nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query = "";

    if(force) {
      query = '''
              MATCH (p:$type) where ID(p) in [${nodeIds.join(',')}] OPTIONAL MATCH p-[r]-() DELETE p, r
              ''';
    } else {
      query = '''
              MATCH (p:$type) where ID(p) in [${nodeIds.join(',')}] DELETE p
              ''';
    }

    return query;
  }
}
