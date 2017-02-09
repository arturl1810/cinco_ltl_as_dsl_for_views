package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import mgl.Attribute
import mgl.ReferencedEClass
import mgl.ReferencedType

class CGraphModel extends Templateable{
	
	override create(TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
		import de.ls5.dywa.generated.entity.*;
		import de.ls5.dywa.generated.controller.*;
		import de.ls5.cinco.pyro.transformation.api.*;
		
		import javax.inject.Inject;
		import java.util.ArrayList;
		import java.util.Date;
		import java.util.List;
		import java.util.stream.Collectors;
		
		/**
		 * Created by Pyro CINCO Meta Plugin.
		 */
		public interface C«tc.graphModel.name.toFirstUpper» extends CGraphModel{
			
		    public String getCName();
		    
		    @Override
		    public List<CModelElement> getModelElements();
		    
		    «FOR StyledNode sn:tc.nodes»
			    public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller();
			    
			    public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController();
			    
			    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id);
		    «ENDFOR»
		    
		    «FOR StyledEdge sn:tc.edges»
			    public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller();
			    
			    public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController();
			    
			    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower»);
			    
			    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id);
		    «ENDFOR»
		    
		    «FOR ReferencedType primeRef : ModelParser.getPrimeReferencedModelElements(tc.graphModel,false)»
		    	public «(primeRef as ReferencedEClass).type.name.toFirstUpper»Controller get«(primeRef as ReferencedEClass).type.name.toFirstUpper»Controller();
		    «ENDFOR»
		    
		    public PyroMoveNodeCommandController getPyroMoveNodeCommandController();
			
			public PyroResizeNodeCommandController getPyroResizeNodeCommandController();
			
			public PyroRotateNodeCommandController getPyroRotateNodeCommandController();
			
			public PyroReconnectEdgeCommandController getPyroReconnectEdgeCommandController();
		
			public PyroVertexEdgeCommandController pyroVertexEdgeCommandController();
			
			public PyroRotateNodeCommandController pyroRotateNodeCommandController(); 
			
			public PyroRemoveNodeCommandController getPyroRemoveNodeCommandController();
			
			public PyroCreateNodeCommandController getPyroCreateNodeCommandController();
			
			public PyroRemoveEdgeCommandController getPyroRemoveEdgeCommandController();
			
			public PyroCreateEdgeCommandController getPyroCreateEdgeCommandController();
		    
		    public PointController getPointController();
		
		    public void setPointController(PointController pointController);
		    
		    «FOR StyledNode sn:tc.nodes»
		    	«CContainer.createNewNode(sn.modelElement)»
		    «ENDFOR»
		
		    «FOR Attribute attr: tc.graphModel.attributes»
		   		«CModelElement.createAttribute(attr,tc.graphModel,tc.enums,tc.graphModel)»
		    «ENDFOR»
		}
	'''
}