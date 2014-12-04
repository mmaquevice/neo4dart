part of neo4dart;

class CypherDeleteBuilder {



  final _logger = new Logger("CypherDeleteBuilder");

  String buildQueryToDeleteNodes(Iterable<int> nodeIds, {bool force: false}) {

    if (nodeIds == null || nodeIds.isEmpty) {
      throw 'Query cannot be built : NodeIds is empty.';
    }

    String query = "";

    if(force) {
      query = '''
              MATCH (p) where ID(p) in [${nodeIds.join(',')}] OPTIONAL MATCH p-[r]-() DELETE p, r
              ''';
    } else {
      query = '''
              MATCH (p) where ID(p) in [${nodeIds.join(',')}] DELETE p
              ''';
    }

    return query;
  }

  String buildQueryToDeleteRelations(Iterable<int> relationIds) {
    if (relationIds == null || relationIds.isEmpty) {
      throw 'Query cannot be built : relationIds is empty.';
    }

    String query = "MATCH ()-[r]-() where ID(r) in [${relationIds.join(',')}] DELETE r";
    return query;
  }
}
