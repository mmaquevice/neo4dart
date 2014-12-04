Neo4dart
========

Neo4dart is a [Dart](https://www.dartlang.org) library acting as a driver for 
[Neo4j](http://neo4j.com/).

[![Build Status](https://drone.io/github.com/matth3o/neo4dart/status.png)](https://drone.io/github.com/matth3o/neo4dart/latest)

## Features

* Basic CRUD operations

## Installation 

Add Neo4dart to your project's `pubspec.yaml` file and run pub get:

    dependencies:
      neo4dart: '0.0.1'
      
## Convention

If you want to use the driver, all you have to do is to adopt the following conventions :

* A node must extends `Node` and it must have a `toJson()` method representing his data

```dart
class Person extends Node {

  String name;
  String address;

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    map["address"] = address;
    return map;
  }
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

* A relation with dynamic data can be added via the annotation `@RelationshipVia()`. In this case the relation has to be an entity extending `Relation`. The data inserted in neo4j will be those returned by the `toJson()` method.

```dart
class Love extends Relation {

  @StartNode()
  Person personWhoLoves;
  @EndNode()
  Person personLoved;
  
  String since;

  Map toJson() {
    Map map = new Map();
      map["since"] = since;    
    return map;
  }
}


class Person extends Node {
...

  @RelationshipVia("is in love with")
  Love love;
}
```

## Usage

All the methods to use for basic operations can be found in the following classes : `NeoServiceFind`, `NeoServiceInsert`, `NeoServiceUpdate`, `NeoServiceDelete`.
