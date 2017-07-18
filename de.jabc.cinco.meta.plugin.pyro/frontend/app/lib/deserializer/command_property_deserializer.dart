import '../model/command.dart';
class CommandPropertyDeserializer
{
  static Command deserialize(dynamic jsog)
  {
    switch(jsog['commandType']) {
      case 'CreateNode': return CreateNodeCommand.fromJSOG(jsog);
      case 'MoveNode': return MoveNodeCommand.fromJSOG(jsog);
      case 'RemoveNode': return RemoveNodeCommand.fromJSOG(jsog);
      case 'ResizeNode': return ResizeNodeCommand.fromJSOG(jsog);
      case 'RotateNode': return RotateNodeCommand.fromJSOG(jsog);

      case 'CreateEdge': return CreateEdgeCommand.fromJSOG(jsog);
      case 'ReconnectEdge': return ReconnectEdgeCommand.fromJSOG(jsog);
      case 'RemoveEdge': return RemoveEdgeCommand.fromJSOG(jsog);
      case 'UpdateBendpoints': return UpdateBendPointCommand.fromJSOG(jsog);

    }
    throw new Exception("Unknown command: ${jsog}");
  }
}
