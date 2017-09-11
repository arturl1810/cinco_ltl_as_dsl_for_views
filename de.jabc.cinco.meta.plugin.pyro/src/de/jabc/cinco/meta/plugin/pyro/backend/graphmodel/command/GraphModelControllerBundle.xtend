package de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.command

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel

class GraphModelControllerBundle extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def filename(GraphModel g)'''«g.name.fuEscapeJava»ControllerBundle.java'''
	
	def content(GraphModel g)
	'''
	package info.scce.pyro.core.command;
	
	import de.ls5.dywa.generated.controller.info.scce.pyro.core.BendingPointController;
	import de.ls5.dywa.generated.controller.info.scce.pyro.core.EdgeController;
	import de.ls5.dywa.generated.controller.info.scce.pyro.core.NodeController;
	
	/**
	 * Author zweihoff
	 */
	public class «g.name.fuEscapeJava»ControllerBundle extends ControllerBundle {
	
	de.ls5.dywa.generated.controller.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava»Controller «g.name.escapeJava»Controller;
	«FOR e:g.elementsAndTypesAndEnums»
	    de.ls5.dywa.generated.controller.info.scce.pyro.«g.name.escapeJava».«e.name.fuEscapeJava»Controller «e.name.escapeJava»Controller;
	«ENDFOR»
	«FOR pr:g.nodes.importedPrimeNodes(g).toSet»
    	de.ls5.dywa.generated.controller.info.scce.pyro.«pr.type.graphModel.name.escapeJava».«pr.type.name.fuEscapeJava»Controller «pr.type.name.escapeJava»Controller;
	«ENDFOR»
	
	    public «g.name.fuEscapeJava»ControllerBundle(
	            NodeController nodeController,
	            EdgeController edgeController,
	            BendingPointController bendingPointController,
	            de.ls5.dywa.generated.controller.info.scce.pyro.«g.name.escapeJava».«g.name.escapeJava»Controller «g.name.escapeJava»Controller
        	«FOR e:g.elementsAndTypesAndEnums BEFORE "," SEPARATOR ","»
        	de.ls5.dywa.generated.controller.info.scce.pyro.«g.name.escapeJava».«e.name.fuEscapeJava»Controller «e.name.escapeJava»Controller
        	«ENDFOR»
        	«FOR pr:g.nodes.importedPrimeNodes(g).toSet BEFORE "," SEPARATOR ","»
        	de.ls5.dywa.generated.controller.info.scce.pyro.«pr.type.graphModel.name.escapeJava».«pr.type.name.fuEscapeJava»Controller «pr.type.name.escapeJava»Controller
        	«ENDFOR»
        ) {
	        super(nodeController, edgeController, bendingPointController);
	        this.«g.name.escapeJava»Controller = «g.name.escapeJava»Controller;
	        «FOR e:g.elementsAndTypesAndEnums»
	        	    this.«e.name.escapeJava»Controller = «e.name.escapeJava»Controller;
	        «ENDFOR»
	        «FOR pr:g.nodes.importedPrimeNodes(g).toSet»
	                this.«pr.type.name.fuEscapeJava»Controller = «pr.type.name.escapeJava»Controller;
        	«ENDFOR»
	    }
	
	
	}
	
	'''
	
}