import '../model/command.dart';
class CommandPropertyDeserializer
{
  static Command deserialize(dynamic jsog)
  {
    switch(jsog['dywaRuntimeType']) {
      case 'info.scce.pyro.core.command.types.CreateNodeCommand': return CreateNodeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.MoveNodeCommand': return MoveNodeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.RemoveNodeCommand': return RemoveNodeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.ResizeNodeCommand': return ResizeNodeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.RotateNodeCommand': return RotateNodeCommand.fromJSOG(jsog);

      case 'info.scce.pyro.core.command.types.CreateEdgeCommand': return CreateEdgeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.ReconnectEdgeCommand': return ReconnectEdgeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.RemoveEdgeCommand': return RemoveEdgeCommand.fromJSOG(jsog);
      case 'info.scce.pyro.core.command.types.UpdateBendPointCommand': return UpdateBendPointCommand.fromJSOG(jsog);

    }
    throw new Exception("Unknown command: ${jsog}");
  }
}
