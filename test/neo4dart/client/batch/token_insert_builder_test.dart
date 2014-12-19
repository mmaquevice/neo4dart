library neo4dart.client.batch.token_insert_builder_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.client.batch.token_insert_builder_test");

  group('buildTokens', () {

    group('nodes and relations (simple)', () {

      test('ok - 1 node', () {

          var node = new Person("Claude", city: "Gagny");

          BatchInsertBuilder builder = new BatchInsertBuilder();
          Set<BatchToken> tokens = builder.buildTokens([node]);

          List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"}, id: 0),
          new BatchToken("POST", "{0}/labels", "Person", id: 2)];

          expect(tokens, unorderedEquals(expected));
      });

      test('ok - 2 nodes', () {
        Set nodes = new Set();
        nodes.add(new Person("Claude", city: "Gagny"));
        nodes.add(new Person("Liliane", city: "Gagny"));

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens(nodes);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                     new BatchToken("POST", "/node", {"name" : "Liliane", "city": "Gagny"}, id: 2),
                                     new BatchToken("POST", "{2}/labels", "Person", id: 3)];

        expect(tokens, unorderedEquals(expected));
      });

      test('ok - if [node.id is set] then [node is not converted into token]', () {
        Set nodes = new Set();
        nodes.add(new Person("Claude", city: "Gagny"));

        var eduardo = new Person("Eduardo", city: "Gagny");
        eduardo.id = 100;
        nodes.add(eduardo);

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens(nodes);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Claude", "city": "Gagny"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1)];

        expect(tokens, unorderedEquals(expected));
      });

      test('ok - inDepth set to true', () {
          Person tintin = new Person("Tintin", city: "Tibet");
          var milou = new Person("Milou", city: "BoneLand");
          var haddock = new Person("Haddock", city: "Boat");
          tintin.coworkers = [milou, haddock];
          var tournesol = new Person("Tournesol", city: "Laboratory");
          haddock.coworkers = [tournesol];

          BatchInsertBuilder builder = new BatchInsertBuilder();
          Set<BatchToken> tokens = builder.buildTokens([tintin], inDepth: true);

          List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                       new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                       new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                       new BatchToken("POST", "{2}/labels", "Person", id: 3),
                                       new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}, id: 4),
                                       new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 5),
                                       new BatchToken("POST", "{5}/labels", "Person", id: 6),
                                       new BatchToken("POST", "/node", {"name" : "Tournesol", "city": "Laboratory"}, id: 7),
                                       new BatchToken("POST", "{7}/labels", "Person", id: 8),
                                       new BatchToken("POST", "{5}/relationships", {'to': '{7}', 'data': null, 'type': 'works with'}, id: 9),
                                       new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': null, 'type': 'works with'}, id: 10)];

          expect(tokens, unorderedEquals(expected));
      });

      test('ok - inDepth set to false', () {
       Person tintin = new Person("Tintin", city: "Tibet");
       var milou = new Person("Milou", city: "BoneLand");
       var haddock = new Person("Haddock", city: "Boat");
       tintin.coworkers = [milou, haddock];
       var tournesol = new Person("Tournesol", city: "Laboratory");
       haddock.coworkers = [tournesol];

       BatchInsertBuilder builder = new BatchInsertBuilder();
       Set<BatchToken> tokens = builder.buildTokens([tintin], inDepth: false);

       List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                    new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                    new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                    new BatchToken("POST", "{2}/labels", "Person", id: 3),
                                    new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}),
                                    new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 5),
                                    new BatchToken("POST", "{5}/labels", "Person", id: 6),
                                    new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': null, 'type': 'works with'}, id: 7)];

       expect(tokens, unorderedEquals(expected));
      });

      test('ok - if [nodes exist] then [relation token refers to their ids]', () {
        Person tintin = new Person("Tintin", city: "Tibet");
        tintin.id = 1;
        var milou = new Person("Milou", city: "BoneLand");
        milou.id = 2;
        var haddock = new Person("Haddock", city: "Boat");
        tintin.coworkers = [milou, haddock];

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens([tintin]);

        List<BatchToken> expected = [new BatchToken("POST", "/node/${tintin.id}/relationships", {'to': '/node/${milou.id}', 'data': null, 'type': 'works with'}),
                                     new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 1),
                                     new BatchToken("POST", "{1}/labels", "Person", id: 2),
                                     new BatchToken("POST", "/node/${tintin.id}/relationships", {'to': '{1}', 'data': null, 'type': 'works with'})];

        expect(tokens, unorderedEquals(expected));
      });

      test('ok - nodes and relations', () {
        Person tintin = new Person("Tintin", city: "Tibet");
        Person milou = new Person("Milou", city: "BoneLand");
        tintin.coworkers = [milou];

        Person haddock = new Person("Haddock", city: "Boat");
        Person tournesol = new Person("Tournesol", city: "Laboratory");
        haddock.coworkers = [tournesol];

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens([tintin, haddock]);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                     new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                     new BatchToken("POST", "{2}/labels", "Person", id: 3),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}, id: 4),
                                     new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 5),
                                     new BatchToken("POST", "{5}/labels", "Person", id: 6),
                                     new BatchToken("POST", "/node", {"name" : "Tournesol", "city": "Laboratory"}, id: 7),
                                     new BatchToken("POST", "{7}/labels", "Person", id: 8),
                                     new BatchToken("POST", "{5}/relationships", {'to': '{7}', 'data': null, 'type': 'works with'}, id: 9)];

        expect(tokens, unorderedEquals(expected));
      });
    });

    group('nodes and relations (via)', () {

      test('ok - inDepth set to true', () {
        Person romeo = new Person("Romeo", city: "Roma");
        Person julieta = new Person("Julieta", city: "Venizia");
        Person liliana = new Person("Liliana", city: "Friul");

        romeo.eternalLovers.add(new Love(romeo, julieta, "so so", "1345"));
        romeo.eternalLovers.add(new Love(romeo, liliana, "so so so", "1346"));

        Person eduardo = new Person("Eduardo", city: "Moscow");
        liliana.eternalLovers.add(new Love(liliana, eduardo, "so so so so", "1919"));

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens([romeo], inDepth: true);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                     new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                     new BatchToken("POST", "{2}/labels", "Person", id: 3),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}, id: 4),
                                     new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 5),
                                     new BatchToken("POST", "{5}/labels", "Person", id: 6),
                                     new BatchToken("POST", "/node", {"name" : "Eduardo", "city": "Moscow"}, id: 7),
                                     new BatchToken("POST", "{7}/labels", "Person", id: 8),
                                     new BatchToken("POST", "{5}/relationships", {'to': '{7}', 'data': {'howMuch': 'so so so so', 'since': 1919}, 'type': 'secretly loves'}, id: 9),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': {'howMuch': 'so so so', 'since': 1346}, 'type': 'secretly loves'}, id: 10)];

        expect(tokens, unorderedEquals(expected));
      });

      test('ok - inDepth set to false', () {
        Person romeo = new Person("Romeo", city: "Roma");
        Person julieta = new Person("Julieta", city: "Venizia");
        Person liliana = new Person("Liliana", city: "Friul");

        romeo.eternalLovers.add(new Love(romeo, julieta, "so so", "1345"));
        romeo.eternalLovers.add(new Love(romeo, liliana, "so so so", "1346"));

        Person eduardo = new Person("Eduardo", city: "Moscow");
        liliana.eternalLovers.add(new Love(liliana, eduardo, "so so so so", "1919"));

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens([romeo], inDepth: false);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                     new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                     new BatchToken("POST", "{2}/labels", "Person", id: 3),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}, id: 4),
                                     new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 5),
                                     new BatchToken("POST", "{5}/labels", "Person", id: 6),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': {'howMuch': 'so so so', 'since': 1346}, 'type': 'secretly loves'}, id: 7)];

        expect(tokens, unorderedEquals(expected));
      });

      test('ok - if [relation.id is set] then [relation is not converted into token]', () {
        Person romeo = new Person("Romeo", city: "Roma");
        Person julieta = new Person("Julieta", city: "Venizia");

        Love love = new Love(romeo, julieta, "so so", "1345");
        love.id = 100;
        romeo.eternalLovers.add(love);

        BatchInsertBuilder builder = new BatchInsertBuilder();
        Set<BatchToken> tokens = builder.buildTokens([romeo]);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                     new BatchToken("POST", "{0}/labels", "Person", id: 1),
                                     new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                     new BatchToken("POST", "{2}/labels", "Person", id: 3)];

        expect(tokens, unorderedEquals(expected));
      });
    });
  });
}
