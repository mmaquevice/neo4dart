part of neo4dart;

class NeoClient {

  final _logger = new Logger("NeoClient");

  http.Client _client;

  NeoClient() {
    _client = new http.Client();
  }

  NeoClient.withClient(this._client);

}
