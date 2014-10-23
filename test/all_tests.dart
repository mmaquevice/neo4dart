library neo4dart.all_tests;

import 'neo4dart/client/batch/entity/batch_token_test.dart' as batch_token;
import 'neo4dart/client/batch/batch_token_handler_test.dart' as batch_token_handler;
import 'neo4dart/client/batch/neo_client_batch_test.dart' as neo_client_batch;

import 'package:logging/logging.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  batch_token.main();
  batch_token_handler.main();
  neo_client_batch.main();
}
