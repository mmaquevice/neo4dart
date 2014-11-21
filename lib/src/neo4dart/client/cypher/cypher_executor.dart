part of neo4dart;

class CypherExecutor {

  final _logger = new Logger("CypherExecutor");

  http.Client client;

  CypherExecutor() {
    client = new http.Client();
  }

  CypherExecutor.withClient(this.client);

  // TODO mma - parametrize props : use literal map
  Future executeCypher(String query, {Map properties}) {

    Map map;
    if(properties == null || properties.isEmpty) {
      map = {
          "statements" : [{
              "statement" : query
          }]
      };
    } else {
      map = {
          "statements" : [{
              "statement" : query,
              "parameters" : {
                "props" : new JsonEncoder().convert(properties)
              }
          }]
      };
    }
    return client.post("http://localhost:7474/db/data/transaction/commit", body : new JsonEncoder().convert(map), headers : {
      'Content-Type' : 'application/json'
    });
  }
}
