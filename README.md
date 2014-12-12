Neo4dart
========

Neo4dart is a [Dart](https://www.dartlang.org) library acting as a driver for
[Neo4j](http://neo4j.com/).

[![Build Status](https://drone.io/github.com/mmaquevice/neo4dart/status.png)](https://drone.io/github.com/mmaquevice/neo4dart/latest)

## Features

* Basic CRUD operations

## Installation

Add Neo4dart to your project's `pubspec.yaml` file and run pub get:

    dependencies:
      neo4dart: '0.0.4'

## Convention

If you want to use the driver, all you have to do is to adopt the following conventions :

* A node must be annotated by `@Node()`, its properties with `@Data()` and it should have an `int id` public field.

```dart
@Node()
class Person {

  int id;

  @Data()
  String name;
  @Data()
  String address;
}
```

* A relation can be added via the annotation `@Relationship()`

```dart
class Person extends Node {
...

  @Relationship("works with")
  List<Person> coworkers;
}
```

* A relation with dynamic data can be added via the annotation `@RelationshipVia()`. In this case the relation has to be an entity extending `Relation`. Its properties must be annotated `@Data()`.

```dart
class Love extends Relation {

  @StartNode()
  Person personWhoLoves;
  @EndNode()
  Person personLoved;

  @Data()
  String since;
}


class Person extends Node {
...

  @RelationshipVia("is in love with")
  Love love;
}
```

## Usage

All the methods to use for basic operations can be found in the following classes : `NeoServiceFind`, `NeoServiceInsert`, `NeoServiceUpdate`, `NeoServiceDelete`.
