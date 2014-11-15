part of neo4dart;

class NeoClient {

  final _logger = new Logger("NeoClient");

  http.Client client;

  NeoClient() {
    client = new http.Client();
  }

  NeoClient.withClient(this.client);
}
