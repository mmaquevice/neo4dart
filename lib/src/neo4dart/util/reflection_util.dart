part of neo4dart;


Node convertToNode(Type type, ResponseEntity response) {

  ClassMirror classMirror = reflectClass(type);
  List<String> parameters = _getConstructorParameters(type, false);
  Map<Symbol, dynamic> valuesByParameter = _getDataValuesFromParameters(parameters, response.data);

  List<String> optionalParameters = _getConstructorParameters(type, true);
  Map<Symbol, dynamic> optionalValuesByParameter = _getDataValuesFromParameters(optionalParameters, response.data);

  InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), new List.from(valuesByParameter.values), optionalValuesByParameter);
  instanceMirror.setField(new Symbol('id'), response.neoId);
  return instanceMirror.reflectee;
}

List<String> _getConstructorParameters(Type type, bool optional) {

  List<String> parametersToReturn = new List();

  ClassMirror mirror = reflectClass(type);
  List<DeclarationMirror> constructors = new List.from(mirror.declarations.values.where((declare) {
    return declare is MethodMirror && declare.isConstructor;
  }));

  constructors.forEach((constructor) {
    if (constructor is MethodMirror) {
      List<ParameterMirror> parameters = constructor.parameters;
      parameters.forEach((parameter) {
        if (optional && parameter.isOptional || !optional && !parameter.isOptional) {
          parametersToReturn.add(MirrorSystem.getName(parameter.simpleName));
        }
      });
    }
  });

  return parametersToReturn;
}

Map<Symbol, dynamic> _getDataValuesFromParameters(List parameters, Map data) {

  Map<Symbol, dynamic> valueByParameter = new Map();

  parameters.forEach((parameter) {
    if (data.containsKey(parameter)) {
      valueByParameter[new Symbol(parameter)] = data[parameter];
    }
  });

  return valueByParameter;
}
