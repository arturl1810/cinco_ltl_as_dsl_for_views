import '../deserializer/command_property_deserializer.dart';
import '../model/core.dart';
import 'package:FlowGraphTool/model/dispatcher.dart';

abstract class Command {
  int delegateId;
  String type;

  Map toJSOG();
}

class CompoundCommand {
  List<Command> queue;
  CompoundCommand({Command first})
  {
    queue = new List();
    if(first!=null) {
      queue.add(first);
    }
  }

  static CompoundCommand fromJSOG(jsog)
  {
    CompoundCommand cc = new CompoundCommand();
    cc.queue = jsog['queue'].map((n) => CommandPropertyDeserializer.deserialize(n)).toList();
    return cc;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['queue'] = queue.map((n) => n.toJSOG()).toList();
    return map;
  }

}



abstract class NodeCommand extends Command{
  int dywaVersion;
  String dywaName;
}

abstract class EdgeCommand extends Command {
  int dywaVersion;
  String dywaName;
}
/// Node Commands
class CreateNodeCommand extends NodeCommand {
  int x;
  int y;
  int width;
  int height;
  int containerId;
  int primeId;
  IdentifiableElement primeElement;

  static CreateNodeCommand fromJSOG(Map jsog)
  {
    CreateNodeCommand cmd = new CreateNodeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];
    cmd.type = jsog['type'];

    cmd.x = jsog['x'];
    cmd.y = jsog['y'];
    if(jsog.containsKey('primeId')){
      cmd.primeId = jsog['primeId'];
    }
    if(jsog.containsKey('primeElement')){
      cmd.primeElement = GraphModelDispatcher.dispatchElement(jsog['primeElement']);
    }
    cmd.height = jsog['height'];
    cmd.width = jsog['width'];
    cmd.containerId = jsog['containerId'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.CreateNodeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['x'] = x;
    map['y'] = y;
    map['width'] = width;
    map['height'] = height;
    map['primeId'] = primeId;
    if(primeElement!=null){
      map['primeElement'] = primeElement.toJSOG(new Map());
    }
    map['containerId'] = containerId;
    return map;
  }
}

class MoveNodeCommand extends NodeCommand {
  int oldX;
  int oldY;
  int oldContainerId;
  int x;
  int y;
  int containerId;

  static MoveNodeCommand fromJSOG(Map jsog)
  {
    MoveNodeCommand cmd = new MoveNodeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.x = jsog['x'];
    cmd.y = jsog['y'];
    cmd.containerId = jsog['containerId'];

    cmd.oldX = jsog['oldX'];
    cmd.oldY = jsog['oldY'];
    cmd.oldContainerId = jsog['oldContainerId'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.MoveNodeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['x'] = x;
    map['y'] = y;
    map['containerId'] = containerId;

    map['oldX'] = oldX;
    map['oldY'] = oldY;
    map['oldContainerId'] = oldContainerId;
    return map;
  }
}

class RemoveNodeCommand extends NodeCommand {
  int x;
  int y;
  int width;
  int height;
  int containerId;
  int primeId;
  IdentifiableElement primeElement;

  static RemoveNodeCommand fromJSOG(Map jsog)
  {
    RemoveNodeCommand cmd = new RemoveNodeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.x = jsog['x'];
    cmd.y = jsog['y'];
    if(jsog.containsKey('primeId')){
      cmd.primeId = jsog['primeId'];
    }
    if(jsog.containsKey('primeElement')){
      cmd.primeElement = GraphModelDispatcher.dispatchElement(jsog['primeElement']);
    }
    cmd.height = jsog['height'];
    cmd.width = jsog['width'];
    cmd.containerId = jsog['containerId'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.RemoveNodeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['x'] = x;
    map['y'] = y;
    map['primeId'] = primeId;
    if(primeElement!=null){
      map['primeElement'] = primeElement.toJSOG(new Map());
    }
    map['width'] = width;
    map['height'] = height;
    map['containerId'] = containerId;

    return map;
  }
}

class ResizeNodeCommand extends NodeCommand {
  int oldWidth;
  int oldHeight;
  int width;
  int height;
  String direction;

  static ResizeNodeCommand fromJSOG(Map jsog)
  {
    ResizeNodeCommand cmd = new ResizeNodeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.oldWidth = jsog['oldWidth'];
    cmd.oldHeight = jsog['oldHeight'];
    cmd.width = jsog['width'];
    cmd.height = jsog['height'];
    cmd.direction = jsog['directtion'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.ResizeNodeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['oldWidth'] = oldHeight;
    map['oldHeight'] = oldWidth;
    map['width'] = width;
    map['height'] = height;
    map['direction'] = direction;

    return map;
  }
}

class RotateNodeCommand extends NodeCommand {
  int oldAngle;
  int angle;

  static RotateNodeCommand fromJSOG(Map jsog)
  {
    RotateNodeCommand cmd = new RotateNodeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.oldAngle = jsog['oldAngle'];
    cmd.angle = jsog['angle'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.RotateNodeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['oldAngle'] = oldAngle;
    map['angle'] = angle;

    return map;
  }
}

/// Edge Commands
class CreateEdgeCommand extends EdgeCommand {
  int sourceId;
  int targetId;
  List<BendingPoint> positions;

  static CreateEdgeCommand fromJSOG(Map jsog)
  {
    CreateEdgeCommand cmd = new CreateEdgeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.sourceId = jsog['sourceId'];
    cmd.targetId = jsog['targetId'];
    cmd.positions = new List();
    for(var b in jsog['positions']) {
      cmd.positions.add(new BendingPoint(jsog: b));
    }
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.CreateEdgeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['sourceId'] = sourceId;
    map['targetId'] = targetId;
    
    map['positions'] = positions.map((b)=>b.toJSOG(new Map())).toList();

    return map;
  }
}

class RemoveEdgeCommand extends EdgeCommand {
  int sourceId;
  int targetId;
  List<BendingPoint> positions;

  static RemoveEdgeCommand fromJSOG(Map jsog)
  {
    RemoveEdgeCommand cmd = new RemoveEdgeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];

    cmd.positions = new List();
    for(var b in jsog['positions']) {
      cmd.positions.add(new BendingPoint(jsog: b));
    }

    cmd.sourceId = jsog['sourceId'];
    cmd.targetId = jsog['targetId'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.RemoveEdgeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['sourceId'] = sourceId;
    map['targetId'] = targetId;
    map['positions'] = positions.map((b)=>b.toJSOG(new Map())).toList();
    return map;
  }
}

class ReconnectEdgeCommand extends EdgeCommand {
  int oldSourceId;
  int oldTargetId;
  int sourceId;
  int targetId;

  static ReconnectEdgeCommand fromJSOG(Map jsog)
  {
    ReconnectEdgeCommand cmd = new ReconnectEdgeCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.dywaVersion = jsog['dywaVersion'];
    cmd.dywaName = jsog['dywaName'];

    cmd.sourceId = jsog['sourceId'];
    cmd.targetId = jsog['targetId'];
    cmd.oldSourceId = jsog['oldSourceId'];
    cmd.oldTargetId = jsog['oldTargetId'];
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.ReconnectEdgeCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;

    map['sourceId'] = sourceId;
    map['targetId'] = targetId;

    map['oldSourceId'] = oldSourceId;
    map['oldTargetId'] = oldTargetId;

    return map;
  }
}


class UpdateBendPointCommand extends Command {
  List<BendingPoint> positions;
  List<BendingPoint> oldPositions;

  UpdateBendPointCommand() {
    positions = new List();
    oldPositions = new List();
  }

  static UpdateBendPointCommand fromJSOG(Map jsog)
  {
    UpdateBendPointCommand cmd = new UpdateBendPointCommand();
    cmd.delegateId = jsog['delegateId'];
    cmd.type = jsog['type'];
    cmd.positions = new List();
    for(var value in jsog['positions']) {
      cmd.positions.add(new BendingPoint(jsog: value));
    }
    cmd.oldPositions = new List();
    for(var value in jsog['oldPositions']) {
      cmd.oldPositions.add(new BendingPoint(jsog: value));
    }
    return cmd;
  }

  Map toJSOG()
  {
    Map map = new Map();
    map['dywaRuntimeType']="info.scce.pyro.core.command.types.UpdateBendPointCommand";
    map['delegateId'] = delegateId;
    map['type'] = type;
    
    map['positions'] = positions.map((n)=>n.toJSOG(new Map())).toList();
    map['oldPositions'] = oldPositions.map((n)=>n.toJSOG(new Map())).toList();

    return map;
  }
  
}
