part of neo4dart;

class CypherResponse {

  List<String> columns = new List();
  List<Map<String, dynamic>> rows = new List();

  CypherResponse(this.columns, this.rows);
}
