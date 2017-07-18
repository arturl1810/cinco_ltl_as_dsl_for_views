import 'core.dart';
import 'dart:convert';
import 'command.dart';
import '../deserializer/property_deserializer.dart';

const String BASIC_MESSAGE_TYPE = "basic";
const String UNDO_MESSAGE_TYPE = "undo";
const String REDO_MESSAGE_TYPE = "redo";

const String BASIC_ANSWER_TYPE = "basic_answer";
const String BASIC_VALID_ANSWER_TYPE = "basic_valid_answer";
const String BASIC_INVALID_ANSWER_TYPE = "basic_invalid_answer";
const String UNDO_VALID_ANSWER_TYPE = "undo_valid_answer";
const String UNDO_INVALID_ANSWER_TYPE = "undo_invalid_answer";
const String REDO_VALID_ANSWER_TYPE = "redo_valid_answer";
const String REDO_INVALID_ANSWER_TYPE = "redo_invalid_answer";

abstract class Message {
  String messageType;
  int senderDywaId;
  
  static Message fromJSOG(Map jsog)
  {
    if(jsog['messageType'] == 'project'){
      return ProjectMessage.fromJSOG(jsog['value']);
    }
    if(jsog['messageType'] == 'property'){
      return PropertyMessage.fromJSOG(jsog['value']);
    }
    if(jsog['messageType'] == 'command'){
      return CompoundCommandMessage.fromJSOG(jsog['value']);
    }
    return null;
  }

  static Message fromJSON(String s)
  {
    return fromJSOG(JSON.decode(s));
  }

  String toJSON()
  {
    return JSON.encode(this.toJSOG());
  }
  Map toJSOG();
}

class ProjectMessage extends Message {
  String messageType = "project";
  PyroProject project;

  static ProjectMessage fromJSOG(Map jsog)
  {
    ProjectMessage pm = new ProjectMessage();
    pm.senderDywaId = jsog["senderDywaId"];
    pm.project = PyroProject.fromJSOG(cache:new Map(),jsog: jsog['project']);
    return pm;
  }

  Map toJSOG()
  {
    Map jsog = new Map();
    jsog["senderDywaId"] = senderDywaId;
    jsog['messageType'] = 'project';
    jsog['project'] = project.toJSOG(new Map());
    return jsog;
  }

}

abstract class GraphMessage extends Message {
  int graphModelId;
}

class PropertyMessage extends GraphMessage {
	
  String messageType = "property";
  String graphModelType;
  IdentifiableElement delegate;

  PropertyMessage(int graphModelId,this.graphModelType,this.delegate,int senderDywaId){
    super.senderDywaId = senderDywaId;
    super.graphModelId = graphModelId;
  }

  static PropertyMessage fromJSOG(Map jsog)
  {
    PropertyMessage pm = new PropertyMessage(
        jsog['graphModelId'],
        jsog['graphModelType'],
        PropertyDeserializer.deserialize(jsog['delegate'],jsog['graphModelType']),
        jsog["senderDywaId"]);

    return pm;
  }

  Map toJSOG()
  {
    Map jsog = new Map();
    jsog['messageType'] = 'property';
    jsog['graphModelId'] = graphModelId;
    jsog["senderDywaId"] = senderDywaId;
    jsog['graphModelType'] = graphModelType;
    jsog['delegate'] = delegate.toJSOG(new Map());
    return jsog;
  }
}

class CompoundCommandMessage extends GraphMessage {
  String messageType = "command";
  CompoundCommand cmd;
  String type;
  CompoundCommandMessage(int grapModelId, this.type,this.cmd,int senderDywaId){
    super.senderDywaId = senderDywaId;
    super.graphModelId = graphModelId;
  }

  static CompoundCommandMessage fromJSOG(Map jsog)
  {
    CompoundCommandMessage ccm = new CompoundCommandMessage(
        jsog['graphModelId'],
        jsog['type'],
        CompoundCommand.fromJSOG(jsog['cmd']),
        jsog["senderDywaId"]
    );
    return ccm;
  }

  Map toJSOG()
  {
    Map jsog = new Map();
    jsog['messageType'] = 'command';
    jsog['graphModelId'] = graphModelId;
    jsog["senderDywaId"] = senderDywaId;
    jsog['cmd'] = cmd.toJSOG();
    jsog['type'] = type;
    return jsog;
  }
}

class ValidCreatedMessage extends Message{
  int dywaId;
  String dywaName;
  String dywaVersion;

  ValidCreatedMessage(int senderDywaId,this.dywaId){
    super.senderDywaId = senderDywaId;
  }

  @override
  Map toJSOG() {
    Map jsog = new Map();
    jsog['messageType'] = 'node_created';
    jsog['dywaId'] = dywaId;
    jsog['dywaName'] = dywaName;
    jsog['dywaVersion'] = dywaVersion;
    jsog["senderDywaId"] = senderDywaId;
    return jsog;
  }
}

class ValidMessage extends Message {


  ValidMessage(int senderDywaId){
    super.senderDywaId = senderDywaId;
  }

  @override
  Map toJSOG() {
    Map jsog = new Map();
    jsog['messageType'] = 'valid_message';
    jsog["senderDywaId"] = senderDywaId;
    return jsog;
  }
}
