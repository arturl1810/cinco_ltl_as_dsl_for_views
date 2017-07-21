import 'command.dart';
import 'core.dart';
import 'message.dart';




abstract class CommandGraph {
  Map<int,IdentifiableElement> modelMap;

  List<CompoundCommand> commandStack;

  List<CompoundCommand> undoneCommandStack;

  GraphModel currentGraphModel;


  CommandGraph(GraphModel this.currentGraphModel,{Map jsog})
  {
    modelMap = new Map();

    if(jsog==null){
      this.commandStack = new List();
      this.undoneCommandStack = new List();
    } else {
      if(jsog.containsKey("commandStack")) {
        for(var c in jsog["commandStack"]){
          this.commandStack.add(CompoundCommand.fromJSOG(c));
        }
      } else {
        this.commandStack = new List();
      }
      if(jsog.containsKey("undoneCommandStack")) {
        for(var c in jsog["undoneCommandStack"]){
          this.undoneCommandStack.add(CompoundCommand.fromJSOG(c));
        }
      } else {
        this.undoneCommandStack = new List();
      }
    }
    collectElements(this.currentGraphModel);
  }



  void collectElements(ModelElementContainer mec)
  {
    modelMap.putIfAbsent(mec.dywaId,() => mec);
    mec.modelElements.forEach((n) {
      if(n is ModelElementContainer){
        collectElements(n);
      }
      else{
        modelMap.putIfAbsent(n.dywaId,() => n);
      }
    });
  }

  /// action triggered by the server
  /// after a valid command has been propagated
  /// and the local business models has to be modified
  /// if propagation is enabled, the canvas is updated as well
  void _execCreateNodeCommand(CreateNodeCommand cmd,bool propagate)
  {
    Node newNode = execCreateNodeType(cmd.type);
    //set position
    newNode.x = cmd.x;
    newNode.y = cmd.y;
    ModelElementContainer mec = modelMap[cmd.containerId];
    //set containment
    newNode.container = mec;
    mec.modelElements.add(newNode);
    if(propagate) {
      // call canvas
      execCreateNodeCommandCanvas(cmd);
    }
  }

  Node execCreateNodeType(String type);

  void execCreateNodeCommandCanvas(CreateNodeCommand cmd);

  /// actions triggered by the js canvas
  /// creating commands that are send to the server
  CreateNodeCommand _createNodeCommand(String type,int x,int y,int containerId)
  {
    CreateNodeCommand cmd = new CreateNodeCommand();
    cmd.containerId = containerId;
    cmd.x = x;
    cmd.y = y;
    cmd.type = type;
    return cmd;
  }

  CompoundCommandMessage sendCreateNodeCommand(String type,int x,int y,int containerId,PyroUser user)
  {
    return _send(_createNodeCommand(type,x,y,containerId),user);
  }

  RemoveNodeCommand _invertCreateNodeCommand(CreateNodeCommand cmd)
  {
    //create remove node command
    //exec command with propagation
    return _removeNodeCommand(cmd.delegateId,cmd.containerId,cmd.x,cmd.y,cmd.type);
  }

  void _execRemoveNodeCommand(RemoveNodeCommand cmd,bool propagate)
  {
    Node node  = modelMap[cmd.delegateId];
    node.container.modelElements.remove(node);
    node.container = null;
    if(propagate) {
      // call canvas
      execRemoveNodeCommandCanvas(cmd);
    }
  }

  void execRemoveNodeCommandCanvas(RemoveNodeCommand cmd);

  RemoveNodeCommand _removeNodeCommand(int nodeId,int containerId,int x,int y,String type)
  {
    RemoveNodeCommand cmd = new RemoveNodeCommand();
    cmd.delegateId = nodeId;
    cmd.containerId = containerId;
    cmd.x = x;
    cmd.y = y;
    cmd.type = type;
    return cmd;
  }

  CompoundCommandMessage sendRemoveNodeCommand(int nodeId,int containerId,int x,int y,String type,PyroUser user,{Set edgeCache})
  {
    var queue = new List<Command>();
    if(edgeCache==null){
      edgeCache = new Set<Edge>();
    }
    Node node = modelMap[nodeId];
    if(node is Container) {
      node.modelElements.forEach((n){
        queue.addAll(sendRemoveNodeCommand(n.dywaId,node.dywaId,n.x,n.y,"${currentGraphModel.runtimeType.toString().toLowerCase()}.${n.runtimeType.toString()}",user,edgeCache: edgeCache).cmd.queue);
      });
    }
    var ccm = _send(_removeNodeCommand(nodeId,containerId,x,y,type),user);
    ccm.cmd.queue.insertAll(0,queue);
    node.outgoing.forEach((e){
      if(edgeCache.add(e)){
        ccm.cmd.queue.add(_removeEdgeCommand(e.dywaId,e.source.dywaId,e.target.dywaId,"${currentGraphModel.runtimeType.toString().toLowerCase()}.${e.runtimeType.toString()}"));
      }
    });
    node.incoming.forEach((e){
      if(edgeCache.add(e)){
        ccm.cmd.queue.add(_removeEdgeCommand(e.dywaId,e.source.dywaId,e.target.dywaId,"${currentGraphModel.runtimeType.toString().toLowerCase()}.${e.runtimeType.toString()}"));
      }
    });
    return ccm;
  }

  CreateNodeCommand _invertRemoveNodeCommand(RemoveNodeCommand cmd)
  {
    return _createNodeCommand(cmd.type,cmd.x,cmd.y,cmd.containerId);
  }

  void _execMoveNode(MoveNodeCommand cmd,bool propagate)
  {
    Node node = modelMap[cmd.delegateId];
    node.x = cmd.x;
    node.y = cmd.y;
    if(cmd.containerId!=node.container.dywaId) {
      //remove from old container
      node.container.modelElements.remove(node);
      //add to new container
      ModelElementContainer mec = modelMap[cmd.containerId];
      node.container = mec;
      mec.modelElements.add(node);
    }
    if(propagate) {
      // call canvas
      execMoveNodeCanvas(cmd);
    }

  }

  void execMoveNodeCanvas(MoveNodeCommand cmd);

  MoveNodeCommand _moveNodeCommand(int id,int newX,int newY,int containerId)
  {
    MoveNodeCommand cmd = new MoveNodeCommand();
    cmd.delegateId = id;
    cmd.containerId = containerId;
    Node node = modelMap[id];
    cmd.x = newX;
    cmd.oldX = node.x;
    cmd.y = newY;
    cmd.oldY = node.y;
    return cmd;
  }

  CompoundCommandMessage sendMoveNodeCommand(int id,int newX,int newY,int containerId,PyroUser user)
  {
    return _send(_moveNodeCommand(id,newX,newY,containerId),user);
  }

  MoveNodeCommand _invertMoveNodeCommand(MoveNodeCommand cmd)
  {
    return _moveNodeCommand(cmd.delegateId,cmd.oldX,cmd.oldY,cmd.containerId);
  }

  void _execResizeNodeCommand(ResizeNodeCommand cmd,bool propagate)
  {
    Node node = modelMap[cmd.delegateId];
    node.width = cmd.width;
    node.height = cmd.height;
    if(propagate) {
      // call canvas
      execResizeNodeCommandCanvas(cmd);
    }
  }

  void execResizeNodeCommandCanvas(ResizeNodeCommand cmd);


  ResizeNodeCommand _resizeNodeCommand(int id,int newWidth,int newHeight)
  {
    ResizeNodeCommand cmd = new ResizeNodeCommand();
    Node node = modelMap[id];
    cmd.delegateId = id;
    cmd.width = newWidth;
    cmd.oldWidth = node.width;
    cmd.height = newHeight;
    cmd.oldHeight = node.height;
    return cmd;
  }

  CompoundCommandMessage sendResizeNodeCommand(int id,int newWidth,int newHeight,PyroUser user)
  {
    return _send(_resizeNodeCommand(id,newWidth,newHeight),user);
  }

  ResizeNodeCommand _invertResizeNode(ResizeNodeCommand cmd)
  {
    return _resizeNodeCommand(cmd.delegateId,cmd.oldWidth,cmd.oldHeight);
  }

  void _execRotateNodeCommand(RotateNodeCommand cmd,bool propagate)
  {
    Node node = modelMap[cmd.delegateId];
    node.angle = cmd.angle;
    if(propagate) {
      // call canvas
      execRotateNodeCommandCanvas(cmd);
    }
  }

  void execRotateNodeCommandCanvas(RotateNodeCommand cmd);

  RotateNodeCommand _rotateNodeCommand(int id,int newAngle)
  {
    RotateNodeCommand cmd = new RotateNodeCommand();
    cmd.delegateId = id;
    cmd.angle = newAngle;
    Node node = modelMap[id];
    cmd.oldAngle = node.angle;
    return cmd;
  }

  CompoundCommandMessage sendRotateNodeCommand(int id,int newAngle,PyroUser user)
  {
    return _send(_rotateNodeCommand(id,newAngle),user);
  }

  RotateNodeCommand _invertRotateNodeCommand(RotateNodeCommand cmd)
  {
    return _rotateNodeCommand(cmd.delegateId,cmd.oldAngle);
  }

  void _execCreateEdgeCommand(CreateEdgeCommand cmd,bool propagate)
  {
    Edge edge = execCreateEdgeType(cmd.type);
    Node source = modelMap[cmd.sourceId];
    Node target = modelMap[cmd.targetId];
    // set source
    edge.source = source;
    source.outgoing.add(edge);
    // set target
    edge.target = target;
    target.incoming.add(edge);
    // set container
    edge.container = source.container;
    source.container.modelElements.add(edge);
    if(propagate) {
      // call canvas
      execCreateEdgeCommandCanvas(cmd);
    }
  }

  Edge execCreateEdgeType(String type);

  void execCreateEdgeCommandCanvas(CreateEdgeCommand cmd);

  CreateEdgeCommand _createEdgeCommand(String type,int targetId,int sourceId)
  {
    CreateEdgeCommand cmd = new CreateEdgeCommand();
    cmd.sourceId = sourceId;
    cmd.targetId = targetId;
    cmd.type = type;
    return cmd;
  }

  CompoundCommandMessage sendCreateEdgeCommand(String type,int targetId,int sourceId,PyroUser user)
  {
    return _send(_createEdgeCommand(type,targetId,sourceId),user);
  }

  RemoveEdgeCommand _invertCreateEdgeCommand(CreateEdgeCommand cmd)
  {
    return _removeEdgeCommand(cmd.delegateId,cmd.sourceId,cmd.targetId,cmd.type);
  }

  void _execRemoveEdgeCommand(RemoveEdgeCommand cmd,bool propagate)
  {
    Edge edge = modelMap[cmd.delegateId];
    edge.source.outgoing.remove(edge);
    edge.target.incoming.remove(edge);
    edge.container.modelElements.remove(edge);
    if(propagate) {
      // call canvas
      execRemoveEdgeCommandCanvas(cmd);
    }
  }

  void execRemoveEdgeCommandCanvas(RemoveEdgeCommand cmd);

  RemoveEdgeCommand _removeEdgeCommand(int id,int sourceId,int targetId,String type)
  {
    RemoveEdgeCommand cmd = new RemoveEdgeCommand();
    cmd.delegateId = id;
    cmd.sourceId = sourceId;
    cmd.targetId = targetId;
    return cmd;
  }

  CompoundCommandMessage sendRemoveEdgeCommand(int id,int sourceId,int targetId,String type,PyroUser user)
  {
    return _send(_removeEdgeCommand(id,sourceId,targetId,type),user);
  }

  CreateEdgeCommand _invertRemoveEdgeCommand(RemoveEdgeCommand cmd)
  {
    return _createEdgeCommand(cmd.type,cmd.sourceId,cmd.targetId);
  }

  void _execReconnectEdgeCommand(ReconnectEdgeCommand cmd,bool propagate)
  {
    Edge edge = modelMap[cmd.delegateId];
    if(cmd.sourceId != edge.source.dywaId) {
      edge.source.outgoing.remove(edge);
      Node newSource = modelMap[cmd.sourceId];
      newSource.outgoing.add(edge);
      edge.source = newSource;
      //reset container
      if(edge.container.dywaId!=newSource.container.dywaId) {
        edge.container.modelElements.remove(edge);
        edge.container = newSource.container;
      }
    }
    if(cmd.targetId != edge.target.dywaId) {
      edge.target.incoming.remove(edge);
      Node newTarget = modelMap[cmd.targetId];
      newTarget.incoming.add(edge);
      edge.target = newTarget;
    }
    if(propagate) {
      // call canvas
      execReconnectEdgeCommandCanvas(cmd);
    }

  }

  void execReconnectEdgeCommandCanvas(ReconnectEdgeCommand cmd);

  ReconnectEdgeCommand _reconnectEdgeCommand(int edgeId,int newSourceId,int newTargetId)
  {
    ReconnectEdgeCommand cmd = new ReconnectEdgeCommand();
    cmd.delegateId = edgeId;
    Edge edge = modelMap[cmd.delegateId];
    cmd.sourceId = newSourceId;
    cmd.oldSourceId = edge.source.dywaId;
    cmd.targetId = newTargetId;
    cmd.oldTargetId = edge.target.dywaId;
    return cmd;
  }

  CompoundCommandMessage sendReconnectEdgeCommand(int edgeId,int newSourceId,int newTargetId,PyroUser user)
  {
    return _send(_reconnectEdgeCommand(edgeId,newSourceId,newTargetId),user);
  }

  ReconnectEdgeCommand _invertReconnectEdgeCommand(ReconnectEdgeCommand cmd)
  {
    return _reconnectEdgeCommand(cmd.delegateId,cmd.oldSourceId,cmd.oldTargetId);
  }

  void _execUpdateBendPoint(UpdateBendPointCommand cmd,bool propagate)
    {
      Edge edge = modelMap[cmd.delegateId];
      edge.bendingPoints.clear();
      cmd.positions.forEach((n){
        BendingPoint bp = new BendingPoint();
        bp.x = n.x;
        bp.y = n.y;
        edge.bendingPoints.add(bp);
      });
      if(propagate) {
        // call canvas
        execUpdateBendPointCanvas(cmd);
      }
    }
  
    void execUpdateBendPointCanvas(UpdateBendPointCommand cmd);


    UpdateBendPointCommand updateBendPointCommand(int edgeId,List positions)
    {
      UpdateBendPointCommand cmd = new UpdateBendPointCommand();
      cmd.delegateId = edgeId;
      cmd.positions = positions;
      return cmd;
    }
  
    CompoundCommandMessage sendUpdateBendPointCommand(int edgeId,List positions,PyroUser user)
    {
      return _send(updateBendPointCommand(edgeId,positions),user);
    }
  
    UpdateBendPointCommand _invertUpdateBendPointCommand(UpdateBendPointCommand cmd)
    {
      return updateBendPointCommand(cmd.delegateId,cmd.positions);
    }


  Command _invertCommand(Command cmd)
  {
    if(cmd is CreateNodeCommand)return _invertCreateNodeCommand(cmd);
    if(cmd is UpdateBendPointCommand)return _invertUpdateBendPointCommand(cmd);
    if(cmd is CreateEdgeCommand)return _invertCreateEdgeCommand(cmd);
    if(cmd is MoveNodeCommand)return _invertMoveNodeCommand(cmd);
    if(cmd is RemoveNodeCommand)return _invertRemoveNodeCommand(cmd);
    if(cmd is RemoveEdgeCommand)return _invertRemoveEdgeCommand(cmd);
    if(cmd is ResizeNodeCommand)return _invertResizeNode(cmd);
    if(cmd is RotateNodeCommand)return _invertRotateNodeCommand(cmd);
    if(cmd is ReconnectEdgeCommand)return _invertReconnectEdgeCommand(cmd);
    return null;
  }

  void _execCommand(Command cmd,bool propagate)
  {
    if(cmd is CreateNodeCommand) _execCreateNodeCommand(cmd,propagate);
    if(cmd is UpdateBendPointCommand) _execUpdateBendPoint(cmd,propagate);
    if(cmd is CreateEdgeCommand) _execCreateEdgeCommand(cmd,propagate);
    if(cmd is MoveNodeCommand) _execMoveNode(cmd,propagate);
    if(cmd is RemoveNodeCommand) _execRemoveNodeCommand(cmd,propagate);
    if(cmd is RemoveEdgeCommand) _execRemoveEdgeCommand(cmd,propagate);
    if(cmd is ResizeNodeCommand) _execResizeNodeCommand(cmd,propagate);
    if(cmd is RotateNodeCommand) _execRotateNodeCommand(cmd,propagate);
    if(cmd is ReconnectEdgeCommand) _execReconnectEdgeCommand(cmd,propagate);
  }

  void _execCommandCanvas(Command cmd)
  {
    if(cmd is CreateNodeCommand) execCreateNodeCommandCanvas(cmd);
    if(cmd is UpdateBendPointCommand) execUpdateBendPointCanvas(cmd);
    if(cmd is CreateEdgeCommand) execCreateEdgeCommandCanvas(cmd);
    if(cmd is MoveNodeCommand) execMoveNodeCanvas(cmd);
    if(cmd is RemoveNodeCommand) execRemoveNodeCommandCanvas(cmd);
    if(cmd is RemoveEdgeCommand) execRemoveEdgeCommandCanvas(cmd);
    if(cmd is ResizeNodeCommand) execResizeNodeCommandCanvas(cmd);
    if(cmd is RotateNodeCommand) execRotateNodeCommandCanvas(cmd);
    if(cmd is ReconnectEdgeCommand) execReconnectEdgeCommandCanvas(cmd);
  }


  CompoundCommandMessage undo(PyroUser user)
  {
    //take last executed command
    CompoundCommand cc = commandStack.last;
    //invert command
    CompoundCommand undoCC = new CompoundCommand();
    cc.queue.reversed.forEach((c) => undoCC.queue.add(_invertCommand(c)));
    //send command
    return new CompoundCommandMessage(currentGraphModel.dywaId,UNDO_MESSAGE_TYPE,cc,user.dywaId);
  }

  void _receiveValidUndo(CompoundCommand cc)
  {
    // add to undone commands
    undoneCommandStack.add(cc);
    // remove from stack
    commandStack.remove(cc);
    // execute the valid undo command
    // on the business model
    cc.queue.forEach((c){
      _execCommand(c,true);
    });
  }

  void _receiveInvalidUndo(CompoundCommand cc)
  {
    // show message
  }

  CompoundCommandMessage redo(PyroUser user)
  {
    if(undoneCommandStack.isNotEmpty){
      //take the last undone command
      CompoundCommand cc = undoneCommandStack.last;
      return new CompoundCommandMessage(currentGraphModel.dywaId,REDO_MESSAGE_TYPE,cc,user.dywaId);
    }
    return null;
  }

  void _receiveValidRedo(CompoundCommand cc)
  {
    // put the redone command back to the command stack
    commandStack.add(cc);
    // remove the redone command from the undone
    undoneCommandStack.removeLast();
    // execute the valid redo command
    // on the business model
    cc.queue.forEach((c){
      _execCommand(c,true);
    });
  }

  void _receiveInvalidRedo(CompoundCommand cc)
  {
    // show message
  }

  void _addToQueue(CompoundCommand cc)
  {
    this.commandStack.add(cc);
    this.undoneCommandStack.clear();
  }

  void _receiveMyValidCommand(CompoundCommand cc)
  {
    // execute valid commands on the business model
    cc.queue.forEach((c){
      _execCommand(c,false);
    });
    //add to stack
    _addToQueue(cc);
  }

  void _receiveOtherValidCommand(CompoundCommand cc)
  {
    // execute valid commands on the business model
    cc.queue.forEach((c){
      _execCommand(c,true);
    });
    //add to stack
    _addToQueue(cc);
  }

  void _receiveMyInvalidCommand(CompoundCommand cc)
  {
    //propagate to the canvas the inverted commands
    cc.queue.forEach((n){
      // invert command
      Command c = _invertCommand(n);
      // execute inverted command only on canvas
      // since it has not been persisted in the local
      // business model
      _execCommandCanvas(c);
    });
  }

  CompoundCommandMessage _send(Command cmd,PyroUser user)
  {
    return new CompoundCommandMessage(currentGraphModel.dywaId,BASIC_MESSAGE_TYPE,new CompoundCommand(first: cmd),user.dywaId);
  }


  void receiveCommand(CompoundCommandMessage ccm)
  {
    switch(ccm.type) {
      case BASIC_ANSWER_TYPE:_receiveOtherValidCommand(ccm.cmd);break;
      case BASIC_INVALID_ANSWER_TYPE:_receiveMyInvalidCommand(ccm.cmd);break;
      case BASIC_VALID_ANSWER_TYPE:_receiveMyValidCommand(ccm.cmd);break;
      case UNDO_VALID_ANSWER_TYPE:_receiveValidUndo(ccm.cmd);break;
      case UNDO_INVALID_ANSWER_TYPE:_receiveInvalidUndo(ccm.cmd);break;
      case REDO_VALID_ANSWER_TYPE:_receiveValidRedo(ccm.cmd);break;
      case REDO_INVALID_ANSWER_TYPE:_receiveInvalidRedo(ccm.cmd);break;
    }
  }



}
