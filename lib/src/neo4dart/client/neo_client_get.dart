part of neo4dart;

class NeoClientGet extends NeoClient {

  final _logger = new Logger("NeoClientGet");

  http.Client _client;

  NeoClientGet() {
    _client = new http.Client();
  }

  NeoClientGet.withClient(this._client);

  Future findNodesByType(Type type) {

    String label = _convertTypeToLabel(type);
    String url = "http://localhost:7474/db/data/label/${label}/nodes";

    return _client.get(url).then((response) => _convertResponseToNodes(response, type));
  }

  String _convertTypeToLabel(Type type) {
    ClassMirror classMirror = reflectClass(type);
    Symbol symbol = classMirror.simpleName;
    return MirrorSystem.getName(symbol);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {

    String label = _convertTypeToLabel(type);

    if(properties.isEmpty) {
      throw new StateError('Properties are empty');
    }

    String propertyKey = properties.keys.first;
    String propertyValue = "\"${properties[propertyKey]}\"";

    String url = "http://localhost:7474/db/data/label/${label}/nodes?${propertyKey}=${propertyValue}";

    return _client.get(url).then((response) => _convertResponseToNodes(response, type));
  }

  List<Node> _convertResponseToNodes(var response, Type typeToConvertInto) {
    _logger.info("Response status : ${response.statusCode}");

    if (response.statusCode == 200) {
      _logger.info("Response body : ${response.body}");

      var bodyJson = new JsonDecoder().convert(response.body);
      List<Node> nodes = new List();
      for (var nodeJson in bodyJson) {
        nodes.add(_convertToNode(typeToConvertInto, nodeJson));
      }
      return nodes;
    } else {
      throw "Error requesting neo4j : status ${response.statusCode}";
    }
  }

  Node _convertToNode(Type type, Map nodeJson) {

    ClassMirror classMirror = reflectClass(type);
    List<String> parameters = _getConstructorParameters(type);
    List<String> values = _getDataValuesFromParameters(parameters, nodeJson['data']);

    InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), values);
    instanceMirror.setField(new Symbol('id'), _extractNodeId( nodeJson['self']));
    return instanceMirror.reflectee;
  }

  String _extractNodeId(String self) {
    String idNode = self.split('/').last;
    if (idNode.isEmpty) {
      throw "Node id cannot be retrieved from : ${self}.";
    }
    return idNode;
  }

  List<String> _getConstructorParameters(Type type) {

    List<String> parametersToReturn = new List();

    ClassMirror mirror = reflectClass(type);
    List<DeclarationMirror> constructors = new List.from(mirror.declarations.values.where((declare) {
      return declare is MethodMirror && declare.isConstructor;
    }));

    constructors.forEach((constructor) {
      if (constructor is MethodMirror) {
        List<ParameterMirror> parameters = constructor.parameters;
        parameters.forEach((parameter) {
          if (!parameter.isOptional) {
            parametersToReturn.add(MirrorSystem.getName(parameter.simpleName));
          }
        });
      }
    });

    return parametersToReturn;
  }

  List<String> _getDataValuesFromParameters(List parameters, Map data) {

    List<String> values = new List();

    parameters.forEach((parameter) {
      if (data.containsKey(parameter)) {
        values.add(data[parameter]);
      } else {
        throw "Data does not contain parameter <${parameter}>.";
      }
    });

    return values;
  }

}
