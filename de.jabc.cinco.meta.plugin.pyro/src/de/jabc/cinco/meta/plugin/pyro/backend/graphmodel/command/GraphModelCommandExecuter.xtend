package de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.command

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.UserDefinedType
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.Edge
import de.jabc.cinco.meta.plugin.pyro.canvas.Shapes
import style.NodeStyle
import style.Styles
import mgl.ReferencedModelElement

class GraphModelCommandExecuter extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def filename(GraphModel g)'''«g.name.fuEscapeJava»CommandExecuter.java'''
	
	def content(GraphModel g,Styles styles)
	'''
	package info.scce.pyro.core.command;
	
	import info.scce.pyro.core.graphmodel.BendingPoint;
	import de.ls5.dywa.generated.entity.info.scce.pyro.core.ModelElementContainer;
	import de.ls5.dywa.generated.entity.info.scce.pyro.core.Node;
	import de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser;
	
	/**
	 * Author zweihoff
	 */
	public class «g.name.fuEscapeJava»CommandExecuter extends CommandExecuter {
	
	    «g.name.fuEscapeJava»ControllerBundle bundle;
	    
	    private info.scce.pyro.rest.ObjectCache objectCache;
	
	    public «g.name.fuEscapeJava»CommandExecuter(«g.name.fuEscapeJava»ControllerBundle bundle, PyroUser user, info.scce.pyro.rest.ObjectCache objectCache) {
	        super(bundle,new BatchExecution(user));
	        this.bundle = bundle;
	        this.objectCache = objectCache;
	    }
	    
	    public void remove«g.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava» entity){
			//for complex props
			«FOR attr:g.attributes.filter[!isPrimitive(g)]»
			if(entity.get«attr.name.escapeJava»()!=null) {
				«IF attr.list»
				entity.get«attr.name.escapeJava»().forEach(n->remove«attr.type.escapeJava»(n));
				«ELSE»
				remove«attr.type.escapeJava»(entity.get«attr.name.escapeJava»());
				«ENDIF»
			}
			«ENDFOR»
			entity.getmodelElements_ModelElement().clear();
			bundle.«g.name.escapeJava»Controller.delete(entity);
		}
	    
		«FOR e:g.nodes»
			public void create«e.name.escapeJava»(long x, long y, ModelElementContainer mec«IF e.prime»,long primeId«ENDIF»){
			    de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» node = bundle.«e.name.escapeJava»Controller.create("«e.name.escapeJava»");
			    «'''node'''.setDefault(e,g,false)»
			    «IF e.prime»
			    «{
			    	val refType = (e.primeReference as ReferencedModelElement).type
			    	val refGraph = refType.graphModel
			    	'''
			    		de.ls5.dywa.generated.entity.info.scce.pyro.«refGraph.name.escapeJava».«refType.name.escapeJava» prime = bundle.«refType.name.escapeJava»Controller.read(primeId);
			    		node.set«(e.primeReference as ReferencedModelElement).name.escapeJava»(prime);
			    	'''
			    }»
			    «ENDIF»
			    super.createNode("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",node,mec,x,y,«{
			    		  	 val nodeStyle = new Shapes(gc,g).styling(e,styles) as NodeStyle
			    		  	 val size = nodeStyle.mainShape.size
			    		  	 '''
			    		  	 «IF size!=null»
			    		  	 «size.width»,«size.height»
			    		  	 «ELSE»
			    		  	 1,1
			    		  	 «ENDIF»
			    		  	 '''
			    		  }»
			    		  «IF e.prime»
	    		  			«{
	    		  				val refType = (e.primeReference as ReferencedModelElement).type
	    		  				val refGraph = refType.graphModel
	    		  		    	'''
	    		  		    		,info.scce.pyro.«refGraph.name.lowEscapeJava».rest.«refType.name.escapeJava».fromDywaEntityProperties(prime,objectCache)
	    		  		    	'''
	    		  			}»
	    		  			«ENDIF»
			    		  );
			}
			public void create«e.name.escapeJava»(long x, long y, ModelElementContainer mec,long id«IF e.prime»,long primeId«ENDIF») {
				de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» node = bundle.«e.name.escapeJava»Controller
				.read(id);
				«IF e.prime»
			    «{
			    	val refType = (e.primeReference as ReferencedModelElement).type
			    	val refGraph = refType.graphModel
			    	'''
			    		de.ls5.dywa.generated.entity.info.scce.pyro.«refGraph.name.escapeJava».«refType.name.escapeJava» prime = bundle.«refType.name.escapeJava»Controller.read(primeId);
			    		node.set«(e.primeReference as ReferencedModelElement).name.escapeJava»(prime);
			    	'''
			    }»
			    «ENDIF»
				super.createNode("«g.name.lowEscapeJava».«e.name.escapeJava»", node, mec, x, y, node.getwidth(), node.getheight()
				«IF e.prime»
				«{
					val refType = (e.primeReference as ReferencedModelElement).type
					val refGraph = refType.graphModel
			    	'''
			    		,info.scce.pyro.«refGraph.name.lowEscapeJava».rest.«refType.name.escapeJava».fromDywaEntityProperties(prime,objectCache)
			    	'''
				}»
				«ENDIF»
				);
			}
			public void move«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» node, long x, long y, ModelElementContainer mec){
				super.moveNode("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",node,mec,x,y);
			}
			public void resize«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» node, long width, long height){
				super.resizeNode("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",node,width,height);
			}
			public void rotate«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» node, long angle){
				super.rotateNode("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",node,angle);
			}
			public void remove«e.name.escapeJava»(
				de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» entity
				«IF e.prime»
				«{
			    	val refType = (e.primeReference as ReferencedModelElement).type
			    	val refGraph = refType.graphModel
			    	'''
		    		,de.ls5.dywa.generated.entity.info.scce.pyro.«refGraph.name.escapeJava».«refType.name.escapeJava» prime
			    	'''
				}»
				«ENDIF»
			){
				//for complex props
				«FOR attr:e.attributes.filter[!isPrimitive(g)]»
				if(entity.get«attr.name.escapeJava»()!=null) {
					«IF attr.list»
					entity.get«attr.name.escapeJava»().forEach(n->remove«attr.type.escapeJava»(n));
					«ELSE»
					remove«attr.type.escapeJava»(entity.get«attr.name.escapeJava»());
					«ENDIF»
				}
				«ENDFOR»
				super.removeNode("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",entity,«IF e.prime»
				«{
					val refType = (e.primeReference as ReferencedModelElement).type
					val refGraph = refType.graphModel
			    	'''
			    		info.scce.pyro.«refGraph.name.lowEscapeJava».rest.«refType.name.escapeJava».fromDywaEntityProperties(prime,objectCache)
			    	'''
				}»
				«ELSE»null«ENDIF»);
			}
	    «ENDFOR»
	    
	    «FOR e:g.edges»
	    	    public void create«e.name.escapeJava»(Node source, Node target,java.util.List<BendingPoint> positions){
	    	        de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» edge = bundle.«e.name.escapeJava»Controller.create("«e.name.escapeJava»");
	    	        «'''edge'''.setDefault(e,g,false)»
	    	        java.util.List<de.ls5.dywa.generated.entity.info.scce.pyro.core.BendingPoint> bendingPoints = new java.util.LinkedList<>();
	        		positions.forEach(p->{
	        			de.ls5.dywa.generated.entity.info.scce.pyro.core.BendingPoint bp = bundle.bendingPointController.create("BendingPoint");
	        			bp.setx(p.getx());
	        			bp.sety(p.gety());
	        			bendingPoints.add(bp);
	        		});
	    	        super.createEdge("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",edge,source,target,bendingPoints);
	    	    }
	    	    public void create«e.name.escapeJava»(Node source, Node target,java.util.List<BendingPoint> positions,long id){
	    	        de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» edge = bundle.«e.name.escapeJava»Controller.read(id);
	    	        super.createEdge("«g.name.lowEscapeJava».«e.name.escapeJava»",edge,source,target,edge.getbendingPoints_BendingPoint());
	    	    }
	    	    public void reconnect«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» edge, Node source, Node target){
	    	        super.reconnectEdge("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",edge,source,target);
	    	    }
	    	    public void update«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» edge, java.util.List<BendingPoint> points){
	    	        super.updateBendingPoints("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",edge,points);
	    	    }
	    	    public void remove«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» entity){
	    	    	//for complex props
	    	    	«FOR attr:e.attributes.filter[!isPrimitive(g)]»
	    	    		if(entity.get«attr.name.escapeJava»()!=null){
	    	    		«IF attr.list»
	    	    		entity.get«attr.name.escapeJava»().forEach(n->remove«attr.type.escapeJava»(n));
	    	    		«ELSE»
	    	    			remove«attr.type.escapeJava»(entity.get«attr.name.escapeJava»());
	    	    		«ENDIF»
	    	    		}
	    	    	«ENDFOR»
	    	    	super.removeEdge("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",entity);
	    	    }
	    «ENDFOR»
	    
	
	    //FOR NODE EDGE GRAPHMODEL TYPE
		«FOR e:g.elementsAndTypes+#[g]»
	    public de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» update«e.name.escapeJava»(«IF !e.isType»de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» entity, «ENDIF»info.scce.pyro.«g.name.lowEscapeJava».rest.«e.name.escapeJava» update){
	        «IF e.isType»
	        de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» entity = bundle.«e.name.escapeJava»Controller.create("«e.name.escapeJava»");
	        «'''entity'''.setDefault(e,g,false)»
	        «ENDIF»
	        
	        //for primitive prop
	        «FOR attr:e.attributes.filter[isPrimitive(g)]»
		        «IF attr.type.getEnum(g)!=null»
		        //for enums
		        if(update.get«attr.name.escapeJava»()!=null) {
		        	entity.set«attr.name.escapeJava»(bundle.«attr.type.escapeJava»Controller.fetchByName(update.get«attr.name.escapeJava»().getdywaName()).iterator().next());
		        }
		        «ELSE»
		        entity.set«attr.name.escapeJava»(update.get«attr.name.escapeJava»());
		        «ENDIF»
	        «ENDFOR»
	        //for complex prop
	        «FOR attr:e.attributes.filter[!isPrimitive(g)]»
	        	«IF attr.list»
	        	java.util.List<de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava»> new«attr.name.escapeJava» = update.get«attr.name.escapeJava»().stream().map(this::update«attr.type.escapeJava»).collect(java.streams.Collectors.toList());
	        	de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava» old«attr.name.escapeJava» = entity.get«attr.name.escapeJava»();
	        	old«attr.name.escapeJava».forEach(this::remove«attr.type.escapeJava»);
	        	entity.set«attr.name.escapeJava»(new«attr.name.escapeJava»);
	        	«ELSE»
	        	de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava» old«attr.name.escapeJava» = entity.get«attr.name.escapeJava»();
	        	if(old«attr.name.escapeJava»!=null) {
	        		entity.set«attr.name.escapeJava»(null);
	        		remove«attr.type.escapeJava»(old«attr.name.escapeJava»);
	        	}
	        	if(update.get«attr.name.escapeJava»()!=null) {
	        		de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava» new«attr.name.escapeJava» = update«attr.type.escapeJava»(update.get«attr.name.escapeJava»());
	        		entity.set«attr.name.escapeJava»(new«attr.name.escapeJava»);
	        	}
	        	«ENDIF»
	        «ENDFOR»
	        «IF !e.isType»
	        super.updateProperties("«g.name.lowEscapeDart».«e.name.fuEscapeDart»",info.scce.pyro.«g.name.lowEscapeJava».rest.«e.name.fuEscapeJava».fromDywaEntityProperties(entity,objectCache));
	        «ENDIF»
	        return entity;
	    }
	    
	     
		«ENDFOR»
	   
	   «FOR e:g.types.filter(UserDefinedType)»
	   public void remove«e.name.escapeJava»(de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«e.name.escapeJava» entity){
	   			//for enums
	   			«FOR attr:e.attributes.filter[isPrimitive(g)].filter[type.getEnum(g)!=null]»
	   			if(entity.get«attr.name.escapeJava»()!=null){
		   			«IF attr.list»
		   			entity.get«attr.name.escapeJava»().clear();
		   			«ELSE»
		   			entity.set«attr.name.escapeJava»(null);
		   			«ENDIF»
		   		}
	   			«ENDFOR»
	   	    	//remove all complex fieds
	   	    	«FOR attr:e.attributes.filter[!isPrimitive(g)]»
	   	    	if(entity.get«attr.name.escapeJava»()!=null){
	   	    		«IF attr.list»
	   	    		java.util.List<de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava»> cp«attr.name.escapeJava» = new java.util.LinkedList(entity.get«attr.name.escapeJava»());
	   	    		entity.get«attr.name.escapeJava»().clear();
	   	    		cp«attr.name.escapeJava».forEach(this::remove«attr.type.escapeJava»);
	   	    		«ELSE»
	   	    		de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«attr.type.escapeJava» cp«attr.name.escapeJava» = entity.get«attr.name.escapeJava»();
	   	    		entity.set«attr.name.escapeJava»(null);
	   	    		remove«attr.type.escapeJava»(cp«attr.name.escapeJava»);
	   	    		«ENDIF»
	   	    	}
	   	    	«ENDFOR»
	   	    	bundle.«e.name.escapeJava»Controller.delete(entity);
	   }
	   «ENDFOR»
	

	}
	
	'''
	
	def setDefault(CharSequence s,ModelElement t,GraphModel g,boolean isController)
	'''
	«IF t instanceof GraphModel»
		«s».setscale(1.0);
		«s».setconnector("normal");
		«s».setheight(600l);
		«s».setwidth(1000l);
		«s».setrouter(null);
	«ENDIF»
	«IF t instanceof Node»
	«s».setwidth(0l);
	«s».setheight(0l);
	«s».setx(0l);
	«s».setangle(0l);
	«s».sety(0l);
		«IF t instanceof NodeContainer»
		«ENDIF»
	«ENDIF»
	«IF t instanceof Edge»
	«ENDIF»
	«FOR attr:t.attributes.filter[!isPrimitive(g)].filter[list]»
«««	«s».set«attr.name.escapeJava»(new java.util.LinkedList<>());
	«ENDFOR»
	//primitive init
	«FOR attr:t.attributes.filter[isPrimitive(g)]»
		«IF attr.list»
«««		«s».set«attr.name.escapeJava»(new java.util.LinkedList<>());
		«ELSE»
			«IF attr.type.getEnum(g)!=null»
			«s».set«attr.name.escapeJava»(«attr.type.getEnumDefault(g,isController)»);
			«ELSE»
			«s».set«attr.name.escapeJava»(«attr.type.primitiveDefault»);
			«ENDIF»
		«ENDIF»
	«ENDFOR»
	'''
	
	def getPrimitiveDefault(String string) {
		switch(string){
			case "EBoolean": return '''false'''
			case "EInt": return '''0l'''
			case "EDouble": return '''0.0'''
			default: return '''null'''
		}
	}
	
	def getEnumDefault(String string,GraphModel g,boolean isController)
	'''«IF !isController»bundle.«ENDIF»«string»Controller.fetchByName("«string.getEnum(g).literals.get(0)»").iterator().next()'''
	
	
}