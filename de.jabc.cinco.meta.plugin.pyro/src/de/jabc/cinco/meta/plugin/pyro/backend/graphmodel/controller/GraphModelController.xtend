package de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.controller

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import mgl.GraphModel
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.ModelElement
import de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.command.GraphModelCommandExecuter
import mgl.NodeContainer

class GraphModelController extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def filename(GraphModel g)'''«g.name.fuEscapeJava»Controller.java'''
	
	def content(GraphModel g)
	'''
	package info.scce.pyro.core;
	
	import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroFolderController;
	import de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController;
	import de.ls5.dywa.generated.entity.info.scce.pyro.core.*;
	import info.scce.pyro.core.command.types.*;
	import info.scce.pyro.core.rest.types.CreateGraphModel;
	import info.scce.pyro.core.command.«g.name.fuEscapeJava»CommandExecuter;
	import info.scce.pyro.core.command.«g.name.fuEscapeJava»ControllerBundle;
	import info.scce.pyro.«g.name.lowEscapeJava».rest.«g.name.fuEscapeJava»;
	
	import javax.ws.rs.core.Response;
	
	@javax.transaction.Transactional
	@javax.ws.rs.Path("/«g.name.lowEscapeJava»")
	public class «g.name.fuEscapeJava»Controller {
	
	    @javax.inject.Inject
	    private PyroFolderController folderController;
	
		@javax.inject.Inject
		private PyroUserController subjectController;
		
		@javax.inject.Inject
		private de.ls5.dywa.generated.controller.info.scce.pyro.core.BendingPointController bendingPointController;
		
		@javax.inject.Inject
		private de.ls5.dywa.generated.controller.info.scce.pyro.core.EdgeController edgeController;
	
		@javax.inject.Inject
		private de.ls5.dywa.generated.controller.info.scce.pyro.core.NodeController nodeController;
		
		@javax.inject.Inject
		private de.ls5.dywa.generated.controller.info.scce.pyro.core.ModelElementContainerController modelElementContainerController;
	
	
		@javax.inject.Inject
		private info.scce.pyro.rest.ObjectCache objectCache;
		
		«FOR e:g.elementsAndTypesAndEnums+#[g]»
			@javax.inject.Inject
			private de.ls5.dywa.generated.controller.info.scce.pyro.«g.name.escapeJava».«e.name.fuEscapeJava»Controller «e.name.escapeJava»Controller;
		«ENDFOR»
	
	
		@javax.ws.rs.POST
		@javax.ws.rs.Path("create/private")
		@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		@javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		@org.jboss.resteasy.annotations.GZIP
		public Response createGraphModel(CreateGraphModel graph) {
	
	        final PyroFolder folder = folderController.read(graph.getparentId());
	        if(folder==null){
	            return Response.status(Response.Status.BAD_REQUEST).build();
	        }
	
		    final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«g.name.fuEscapeJava» newGraph =  «g.name.escapeJava»Controller.create("«g.name.fuEscapeJava»_"+graph.getfilename());
		    newGraph.setfilename(graph.getfilename());
		    «new GraphModelCommandExecuter(gc).setDefault('''newGraph''',g,g,false)»
		    
	        folder.getgraphModels_GraphModel().add(newGraph);
	
			return Response.ok(«g.name.fuEscapeJava».fromDywaEntity(newGraph,objectCache)).build();
		}
		
		@javax.ws.rs.GET
		@javax.ws.rs.Path("read/{id}/private")
		@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		@org.jboss.resteasy.annotations.GZIP
		public Response load(@javax.ws.rs.PathParam("id") long id) {
	
			final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava» graph = «g.name.escapeJava»Controller.read(id);
			if (graph == null) {
				return Response.status(Response.Status.BAD_REQUEST).build();
			}
			return Response.ok(«g.name.escapeJava».fromDywaEntity(graph, objectCache))
					.build();
	
		}
		
		@javax.ws.rs.GET
		@javax.ws.rs.Path("remove/{id}/{parentId}/private")
		@javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		@org.jboss.resteasy.annotations.GZIP
		public Response removeGraphModel(@javax.ws.rs.PathParam("id") final long id,@javax.ws.rs.PathParam("parentId") final long parentId) {
			final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController
					.read((Long) org.apache.shiro.SecurityUtils.getSubject()
							.getPrincipal());
			//find parent
			final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava» gm = «g.name.escapeJava»Controller.read(id);
			final PyroFolder parent = folderController.read(parentId);
			if(gm==null||parent==null){
				return Response.status(Response.Status.NOT_FOUND).build();
			}
			//cascade remove
			if(parent.getgraphModels_GraphModel().contains(gm)){
				parent.getgraphModels_GraphModel().remove(gm);
				«g.name.escapeJava»ControllerBundle bundle = new «g.name.escapeJava»ControllerBundle(
					 nodeController,
					 edgeController,
					 bendingPointController,
					 «g.name.escapeJava»Controller
					 «FOR e:g.elementsAndTypesAndEnums BEFORE "," SEPARATOR ","»
					 «e.name.escapeJava»Controller
					 «ENDFOR»
					
				);
				«g.name.escapeJava»CommandExecuter executer = new «g.name.escapeJava»CommandExecuter(bundle,subject,objectCache);
				removeContainer(gm,executer);
				return Response.ok("OK").build();
			}
			return Response.status(Response.Status.BAD_REQUEST).build();
	
		}
	
		private void removeContainer(ModelElementContainer container,«g.name.escapeJava»CommandExecuter executer) {
			java.util.List<ModelElement> modelElements = new java.util.LinkedList<>(container.getmodelElements_ModelElement());
			modelElements.forEach((n)->{
				«FOR e:g.edges»
				if(n instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava»){
					executer.remove«e.name.escapeJava»((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava») n);
				}
				«ENDFOR»
			});
			modelElements.forEach((n)->{
				«FOR e:g.nodes»
				if(n instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava»){
					«IF e instanceof NodeContainer»
					removeContainer((Container) n,executer);
					«ELSE»
					executer.remove«e.name.escapeJava»((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava») n);
					«ENDIF»
				}
				«ENDFOR»
			});
			«FOR e:g.nodes.filter(NodeContainer) + #[g]»
			if(container instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava»){
				executer.remove«e.name.escapeJava»((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava») container);
			}
			«ENDFOR»
		}
		
		@javax.ws.rs.POST
		    @javax.ws.rs.Path("message/{graphModelId}/private")
		    @javax.ws.rs.Produces(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		    @javax.ws.rs.Consumes(javax.ws.rs.core.MediaType.APPLICATION_JSON)
		    @org.jboss.resteasy.annotations.GZIP
		    public Response receiveMessage(@javax.ws.rs.PathParam("graphModelId") long graphModelId, Message m) {
		
		        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser subject = subjectController.read((Long)org.apache.shiro.SecurityUtils.getSubject().getPrincipal());
		        final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava» graph = «g.name.escapeJava»Controller.read(graphModelId);
		        if(subject==null||graph==null){
		            return Response.status(Response.Status.BAD_REQUEST).build();
		        }
		        if(m instanceof CompoundCommandMessage){
		            return executeCommand((CompoundCommandMessage) m,subject,graph);
		        }
		        else if(m instanceof GraphPropertyMessage){
		            final GraphPropertyMessage gpm = (GraphPropertyMessage) m;
		            graph.setconnector(gpm.getGraph().getconnector());
		            graph.setrouter(gpm.getGraph().getrouter());
		            graph.setwidth(gpm.getGraph().getwidth());
		            graph.setheight(gpm.getGraph().getheight());
		            graph.setscale(gpm.getGraph().getscale());
		            //propagate
		            return Response.ok("OK").build();
		        }
		        else if (m instanceof PropertyMessage) {
					return executePropertyUpdate((PropertyMessage) m,subject);
				} else if (m instanceof ProjectMessage) {
					return Response.ok("OK").build();
				}
		
		        return Response.status(Response.Status.BAD_REQUEST).build();
		    }
		    
		private Response executePropertyUpdate(PropertyMessage pm,PyroUser user) {
	        «g.name.escapeJava»ControllerBundle bundle = buildBundle();
		    «g.name.escapeJava»CommandExecuter executer = new «g.name.escapeJava»CommandExecuter(bundle,user,objectCache);
		    «FOR e:g.elements + #[g]»
		    if (pm.getDelegate() instanceof info.scce.pyro.«g.name.lowEscapeJava».rest.«e.name.escapeJava»){
		         de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» target = «e.name.escapeJava»Controller.read(pm.getDelegate().getDywaId());
		         executer.update«e.name.escapeJava»(target, (info.scce.pyro.«g.name.lowEscapeJava».rest.«e.name.escapeJava») pm.getDelegate());
		         return Response.ok(pm).build();
		    }
		    «ENDFOR»
		    return Response.status(Response.Status.BAD_REQUEST).build();
		}
		
		private «g.name.escapeJava»ControllerBundle buildBundle(){
		        return new «g.name.escapeJava»ControllerBundle(
		                nodeController,
		                edgeController,
		                bendingPointController,
		                «g.name.escapeJava»Controller
		                «FOR e:g.elementsAndTypesAndEnums BEFORE "," SEPARATOR ","»
		                «e.name.escapeJava»Controller
		                «ENDFOR»
		        );
		}
	
	    private Response executeCommand(CompoundCommandMessage ccm, PyroUser user, de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava» graph) {
	        //setup batch execution
	        «g.name.escapeJava»ControllerBundle bundle = buildBundle();
	        «g.name.escapeJava»CommandExecuter executer = new «g.name.escapeJava»CommandExecuter(bundle,user,objectCache);
	        //execute command
	        try{
		        for(Command c:ccm.getCmd().getQueue()){
		            if(c instanceof CreateNodeCommand){
		                CreateNodeCommand cm = (CreateNodeCommand) c;
		                ModelElementContainer mec = modelElementContainerController.read(cm.getContainerId());
		                «g.nodes.map['''
		                if(cm.getDelegateId()!=0){
		                     executer.create«name.escapeJava»(cm.getX(),cm.getY(),mec,cm.getDelegateId());
		                } else {
		                	executer.create«name.escapeJava»(cm.getX(),cm.getY(),mec);
		                }
		                '''.checkType(it,g)].join»
		            }
		            else if(c instanceof MoveNodeCommand){
		                MoveNodeCommand cm = (MoveNodeCommand) c;
		                Node node = nodeController.read(cm.getDelegateId());
		                ModelElementContainer mec = modelElementContainerController.read(cm.getContainerId());
		                «g.nodes.map['''executer.move«name.escapeJava»(«it.cast(g)»node,cm.getX(),cm.getY(),mec);'''.checkType(it,g)].join»
		            }
		            else if(c instanceof ResizeNodeCommand){
		                ResizeNodeCommand cm = (ResizeNodeCommand) c;
		                Node node = nodeController.read(cm.getDelegateId());
		                «g.nodes.map['''executer.resize«name.escapeJava»(«it.cast(g)»node,cm.getWidth(),cm.getHeight());'''.checkType(it,g)].join»
		            }
		            else if(c instanceof RotateNodeCommand){
		                RotateNodeCommand cm = (RotateNodeCommand) c;
		                Node node = nodeController.read(cm.getDelegateId());
		                «g.nodes.map['''executer.rotate«name.escapeJava»(«it.cast(g)»node,cm.getAngle());'''.checkType(it,g)].join»
		            }
		            else if(c instanceof RemoveNodeCommand){
		                RemoveNodeCommand cm = (RemoveNodeCommand) c;
		                Node node = nodeController.read(cm.getDelegateId());
		                «g.nodes.map['''executer.remove«name.escapeJava»(«it.cast(g)»node);'''.checkType(it,g)].join»
		            }
		            else if(c instanceof CreateEdgeCommand){
		                CreateEdgeCommand cm = (CreateEdgeCommand) c;
		                Node source = nodeController.read(cm.getSourceId());
		                Node target = nodeController.read(cm.getTargetId());
		                «g.edges.map['''
		                if(cm.getDelegateId()!=0){
                            executer.create«name.escapeJava»(source,target,cm.getPositions(),cm.getDelegateId());
                        } else {
			                executer.create«name.escapeJava»(source,target,cm.getPositions());
                        }
		                '''.checkType(it,g)].join»
		            }
		            else if(c instanceof ReconnectEdgeCommand){
		                ReconnectEdgeCommand cm = (ReconnectEdgeCommand) c;
		                Edge edge = edgeController.read(cm.getDelegateId());
		                Node source = nodeController.read(cm.getSourceId());
		                Node target = nodeController.read(cm.getTargetId());
		                «g.edges.map['''executer.reconnect«name.escapeJava»(«it.cast(g)»edge,source,target);'''.checkType(it,g)].join»
		            }
		            else if(c instanceof RemoveEdgeCommand){
		                RemoveEdgeCommand cm = (RemoveEdgeCommand) c;
		                Edge edge = edgeController.read(cm.getDelegateId());
		                «g.edges.map['''executer.remove«name.escapeJava»(«it.cast(g)»edge);'''.checkType(it,g)].join»
		            }
		            else if(c instanceof UpdateBendPointCommand){
		                UpdateBendPointCommand cm = (UpdateBendPointCommand) c;
		                Edge edge = edgeController.read(cm.getDelegateId());
		                «g.edges.map['''executer.update«name.escapeJava»(«it.cast(g)»edge,cm.getPositions());'''.checkType(it,g)].join»
		            }
		            else {
						return Response.status(Response.Status.BAD_REQUEST).build();
		            }
		        }
	        } catch(Exception e) {
	        	//send rollback
	        	System.out.print(e.getMessage());
	        	java.util.List<Command> reversed = new java.util.LinkedList<>(ccm.getCmd().getQueue());
				java.util.Collections.reverse(reversed);
	        	ccm.getCmd().setQueue(reversed);
	        	if(ccm.getType().equals("basic")){
					ccm.setType("basic_invalid_answer");
				} else if(ccm.getType().equals("undo")){
					ccm.setType("undo_invalid_answer");
				} else if(ccm.getType().equals("redo")){
					ccm.setType("redo_invalid_answer");
				}
	        	return Response.ok(ccm).build();
	        }
			CompoundCommandMessage response = new CompoundCommandMessage();
			if(ccm.getType().equals("basic")){
				response.setType("basic_valid_answer");
			} else if(ccm.getType().equals("undo")){
				response.setType("undo_valid_answer");
			} else if(ccm.getType().equals("redo")){
				response.setType("redo_valid_answer");
			}
			CompoundCommand cc = new CompoundCommand();
			cc.setQueue(executer.getBatch().getCommands());
			response.setCmd(cc);
			response.setGraphModelId(graph.getDywaId());
			response.setSenderDywaId(user.getDywaId());
	        //propagate batch
	        //response batch
			return Response.ok(response).build();
	    }
	
	
	}
	
	'''
	
	def cast(ModelElement e,GraphModel g)'''(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava»)'''
	
	def checkType(CharSequence s,ModelElement e,GraphModel g)
	'''
	if(c.getType().equals("«g.name.lowEscapeDart».«e.name.fuEscapeDart»")) {
		«s»
	}
	'''
}