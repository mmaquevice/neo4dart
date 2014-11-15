part of neo4dart;

class CypherExecutor {

  final _logger = new Logger("CypherExecutor");

  http.Client client;

  CypherExecutor() {
    client = new http.Client();
  }

  CypherExecutor.withClient(this.client);

  Future executeCypher(String query) {

    Map map = {
      "statements" : [{
        "statement" : query
      }]
    };
    return client.post("http://localhost:7474/db/data/transaction/commit", body : new JsonEncoder().convert(map), headers : {
      'Content-Type' : 'application/json'
    });
  }
}
