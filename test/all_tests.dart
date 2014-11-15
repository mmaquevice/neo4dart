library neo4dart.all_tests;

import 'neo4dart/client/batch/entity/batch_token_test.dart' as batch_token;
import 'neo4dart/client/batch/token_insert_builder_test.dart' as batch_token_handler;

import 'neo4dart/client/get/neo_client_get_test.dart' as neo_client_get;

import 'neo4dart/service/insert/neo_service_insert_test.dart' as neo_service;
import 'neo4dart/service/find/neo_service_find_test.dart' as neo_service_find;

import 'package:logging/logging.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  batch_token.main();
  batch_token_handler.main();

  neo_client_get.main();

  neo_service.main();

  neo_service_find.main();
}
