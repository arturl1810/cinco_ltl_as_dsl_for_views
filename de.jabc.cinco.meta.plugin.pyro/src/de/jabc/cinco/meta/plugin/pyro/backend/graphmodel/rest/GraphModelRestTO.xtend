package de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.rest

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.Type
import mgl.GraphModel
import mgl.ContainingElement
import mgl.Node
import mgl.GraphicalModelElement
import mgl.NodeContainer
import mgl.Edge
import mgl.ModelElement
import mgl.Attribute

class GraphModelRestTO extends Generatable{
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def filename(Type t)'''«t.name.fuEscapeJava».java'''
	
	def content(ModelElement t,GraphModel g)
	'''
	package info.scce.pyro.«g.name.lowEscapeJava».rest;
	
	/**
	 * Author zweihoff
	 */
	
	@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
	@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
	@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
	public class «t.name.fuEscapeJava» extends info.scce.pyro.core.graphmodel.«t.extending()»
	{
		«t.attributes.map[attributeDeclaration(g)].join("\n")»
	
	    public static «t.name.fuEscapeJava» fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«t.name.fuEscapeJava» entity, info.scce.pyro.rest.ObjectCache objectCache) {
			«t.parse(g,false)»
	    }
	    public static «t.name.fuEscapeJava» fromDywaEntityProperties(final de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.escapeJava».«t.name.fuEscapeJava» entity, info.scce.pyro.rest.ObjectCache objectCache) {
			«t.parse(g,true)»
	    }
	}
	'''
	
	def parse(ModelElement t,GraphModel g,boolean onlyProperties)
	'''
	if(objectCache.containsRestTo(entity)){
		return objectCache.getRestTo(entity);
	}
	final «t.name.fuEscapeJava» result;
	result = new «t.name.fuEscapeJava»();
	objectCache.putRestTo(entity, result);
	result.setDywaId(entity.getDywaId());
	result.setDywaName(entity.getDywaName());
	result.setDywaVersion(entity.getDywaVersion());
	result.set__type("«g.name.lowEscapeDart».«t.name.fuEscapeDart»");
    «IF !onlyProperties»
		«IF t instanceof ContainingElement»
    result.setmodelElements(entity.getmodelElements_ModelElement().stream().map((n)->{
	    	«FOR containable:g.elements.filter(GraphicalModelElement)»
	    	if(n instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«containable.name.fuEscapeJava»){
		return «containable.name.fuEscapeJava».fromDywaEntity((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«containable.name.fuEscapeJava»)n,objectCache);
		}
	        «ENDFOR»
		throw new IllegalStateException("Unknown Modelelement "+n.getDywaId());
		}).collect(java.util.stream.Collectors.toList()));
		«ENDIF»
		«IF t instanceof GraphicalModelElement»
		«t.serializeContainer("container",g)»
		«ENDIF»
		«IF t instanceof GraphModel»
		result.setscale(entity.getscale());
		result.setwidth(entity.getwidth());
		result.setheight(entity.getheight());
		result.setrouter(entity.getrouter());
		result.setconnector(entity.getconnector());
		result.setfilename(entity.getfilename());
		«ENDIF»
		«IF t instanceof Node»
			result.setwidth(entity.getwidth());
			result.setheight(entity.getheight());
			result.setangle(entity.getangle());
			result.setx(entity.getx());
			result.sety(entity.gety());
			«t.serializeEdges("incoming",g)»
			«t.serializeEdges("outgoing",g)»
		«ENDIF»
		«IF t instanceof Edge»
			result.setbendingPoints(entity.getbendingPoints_BendingPoint().stream().map(n->info.scce.pyro.core.graphmodel.BendingPoint.fromDywaEntity((de.ls5.dywa.generated.entity.info.scce.pyro.core.BendingPoint)n)).collect(java.util.stream.Collectors.toList()));
			«t.serializeConnection("targetElement",g)»
			«t.serializeConnection("sourceElement",g)»
		«ENDIF»
	«ENDIF»
	//additional attributes
	«t.attributes.map[attributeSerialization(g)].join("\n")»
    return result;
	'''
	
	def attributeSerialization(mgl.Attribute attr,GraphModel g)
	'''
	if(entity.get«attr.name.escapeJava»()!=null){
	«IF attr.isList»
		«IF attr.isPrimitive(g)»
			«IF attr.type.getEnum(g)!=null»
			result.set«attr.name.escapeJava»(entity.get«attr.name.escapeJava»().stream().map(n->info.scce.pyro.core.graphmodel.PyroEnum.fromDywaEntity.fromDywaEntity(n)).collect(java.util.stream.Collectors.toList())););
			«ELSE»
			result.set«attr.name.escapeJava»(entity.get«attr.name.escapeJava»());
			«ENDIF»
		«ELSE»
			result.set«attr.name.escapeJava»(entity.get«attr.name.escapeJava»().stream().map(n->«attr.type.fuEscapeJava».fromDywaEntity(n,objectCache)).collect(java.util.stream.Collectors.toList())););
		«ENDIF»
	«ELSE»
		«IF attr.isPrimitive(g)»
			«IF attr.type.getEnum(g)!=null»
			result.set«attr.name.escapeJava»(info.scce.pyro.core.graphmodel.PyroEnum.fromDywaEntity(entity.get«attr.name.escapeJava»(),"«g.name.lowEscapeDart».«attr.type.fuEscapeDart»"));
			«ELSE»
			result.set«attr.name.escapeJava»(entity.get«attr.name.escapeJava»());
			«ENDIF»
		«ELSE»
		result.set«attr.name.escapeJava»(«attr.type.fuEscapeJava».fromDywaEntity(entity.get«attr.name.escapeJava»(),objectCache));
		«ENDIF»
	«ENDIF»
	}
	'''
	
	
	def attributeDeclaration(mgl.Attribute attr,GraphModel g)
	'''
	private «attr.javaType(g)» «attr.name.escapeJava»;
	
	@com.fasterxml.jackson.annotation.JsonProperty("«attr.name.escapeJava»")
	public «attr.javaType(g)» get«attr.name.escapeJava»() {
	    return this.«attr.name.escapeJava»;
	}
	
	@com.fasterxml.jackson.annotation.JsonProperty("«attr.name.escapeJava»")
	public void set«attr.name.escapeJava»(final «attr.javaType(g)» «attr.name.escapeJava») {
	    this.«attr.name.escapeJava» = «attr.name.escapeJava»;
	}
	'''
	
	def javaType(Attribute attribute, GraphModel g){
		var res = ""
		if(attribute.isList){
			res += "java.util.List<"
		}
		if(attribute.isPrimitive(g)){
			res += attribute.getToJavaType(g)
		}
		else{
			res += attribute.type.fuEscapeJava
		}
		if(attribute.isList){
			res += ">"
		}
		res
	}
	
	def getToJavaType(Attribute attr,GraphModel g) {
		if(attr.type.getEnum(g)!=null){
			return "info.scce.pyro.core.graphmodel.PyroEnum"
		}
		switch(attr.type){
			case "EBoolean": return '''boolean'''
			case "EInt": return '''long'''
			case "EDouble": return '''double'''
			default: return '''String'''
			
		}
	}
	
	def serializeEdges(Node n,String attr,GraphModel g)
	'''
	result.set«attr»(entity.get«attr»_Edge().stream().map((n)->{
	«FOR edge:g.elements.filter(Edge)»
		            if(n instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«edge.name.fuEscapeJava»){
		                return «edge.name.fuEscapeJava».fromDywaEntity((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«edge.name.fuEscapeJava»)n,objectCache);
		            }
    «ENDFOR»
		            throw new IllegalStateException("Unknown Modelelement "+n.getDywaId());
		        }).collect(java.util.stream.Collectors.toList()));
	'''
	
	def serializeContainer(GraphicalModelElement n,String attr,GraphModel g)
	'''
	«FOR container:g.elements.filter(NodeContainer)+#[g]»
	if(entity.getcontainer()  instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«container.name.fuEscapeJava»){
		 result.set«attr»(«container.name.fuEscapeJava».fromDywaEntity((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«container.name.fuEscapeJava»)entity.getcontainer() ,objectCache));
	}
    «ENDFOR»

	'''
	
	def serializeConnection(Edge e,String attr,GraphModel g)
	'''
	«FOR node:g.elements.filter(Node)»
	if(entity.get«attr»() instanceof de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«node.name.fuEscapeJava»){
		 result.set«attr»(«node.name.fuEscapeJava».fromDywaEntity((de.ls5.dywa.generated.entity.info.scce.pyro.«g.name.fuEscapeJava».«node.name.fuEscapeJava»)entity.get«attr»(),objectCache));
	}
    «ENDFOR»

	'''
	
	
}