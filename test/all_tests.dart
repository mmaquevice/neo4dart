library neo4dart.all_tests;

import 'neo4dart/client/batch/entity/batch_token_test.dart' as batch_token;
import 'neo4dart/client/batch/neo_client_batch_test.dart' as neo_client;

main() {
  batch_token.main();
  neo_client.main();
}
