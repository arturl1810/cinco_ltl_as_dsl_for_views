package de.jabc.cinco.meta.plugin.modelchecking.util

import mgl.GraphModel
import mgl.impl.ComplexAttributeImpl
import mgl.UserDefinedType
import mgl.impl.PrimitiveAttributeImpl
import mgl.EDataTypeType
import mgl.Annotatable
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FulfillmentConstraint
import mgl.ModelElement
import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension

class ModelCheckingExtension {
	
	extension GraphModelExtension = new GraphModelExtension
	
	//HighlightMethods
	
	def getHighlightColor(GraphModel model){
		var colorOption = model.annotations.
			filter[name == "mcHighlightColor"]
			.map[value]
			.flatten
			.filter[startsWith("Color.")].head
		if (colorOption !== null){
			switch (colorOption){
				case "Color.RED": return "RED"
				case "Color.BLUE": return "BLUE"
				case "Color.BLACK": return "BLACK"
				case "Color.CYAN" : return "CYAN"
				case "Color.GRAY" : return "GRAY"
				case "Color.ORANGE" : return "ORANGE"
				case "Color.WHITE" : return "WHITE"
				case "Color.YELLOW" : return "YELLOW"
				default : return "GREEN"
			}
		}
		return "GREEN"
	}
	
	//nameMethods
	
	def toOnlyFirstUpper(String text){
		text?.toLowerCase.toFirstUpper
	}
	
	
	//Provider Methods
	
	
	def getProviderPath(GraphModel model){
		model.annotations.filter[
			name == "modelchecking"
		].head?.value.head
	}
	
	def providerExists(GraphModel model){
		getProviderPath(model) !== null
	}
	
	//Formula Methods
	
	def getFormulaAttribute(GraphModel model){
		model.attributes.filter[hasAnnotation("mcFormulas")].head
	}
	
	def getFormulasAttributeName(GraphModel model){
		return model.getFormulaAttribute?.name.toFirstUpper
	}
	
	def getFormulasType(GraphModel model){
		val formulaAttribute = model.formulaAttribute
		if(formulaAttribute !== null && formulaAttribute instanceof ComplexAttributeImpl) 
		(formulaAttribute as ComplexAttributeImpl).type as UserDefinedType
	}
	
	def getFormulasTypeName(GraphModel model){
		model.formulasType?.name
	}
	
	def getFormulaStringAttributes (GraphModel model){
		model.formulasType?.attributes.filter[
			lowerBound == 0 && upperBound == 1 	
			&& it instanceof PrimitiveAttributeImpl
			&& (it as PrimitiveAttributeImpl).type == EDataTypeType.ESTRING
		]
	}
	
	def getExpressionAttributeName (GraphModel model){
		model.formulaStringAttributes?.head?.name
	}
	
	def getDescriptionAttributeName(GraphModel model){
		model.formulaStringAttributes?.get(1)?.name
	}
	
	def getCheckAttribute(GraphModel model){
		model.formulasType?.attributes.filter[
			lowerBound == 0 && upperBound == 1
			&& it instanceof PrimitiveAttributeImpl
			&& (it as PrimitiveAttributeImpl).type == EDataTypeType.EBOOLEAN
		].head
	}
	
	def getCheckAttributeName (GraphModel model){
		model.checkAttribute?.name
	}
	
	def checkAttributeExists(GraphModel model){
		model.checkAttribute !== null
	}
	
	def formulasExist(GraphModel model){
		model.getFormulaAttribute !== null
	}

	def getStartNodes(GraphModel model){
		model.nodes.filter[hasAnnotation("mcStartNode")]
	}
	
	def getFulfillmentConstraint(GraphModel model){
		switch(model.getAnnotationValues("mcFulfillmentConstraint").head){
			case "DEFAULT" : return FulfillmentConstraint.ALL_NODES
			case "ANY" : return FulfillmentConstraint.ANY_STARTNODE
			case "EACH" : return FulfillmentConstraint.EACH_STARTNODE
			default: return FulfillmentConstraint.defaultValue
		}
	}
	
	def isStartNode(ModelElement element){
		element.hasInheritedAnnotation("mcStartNode")
	}
	
	def boolean isSupportNode(ModelElement element){
		element.hasInheritedAnnotation("mcSupportNode")
	}
	
	def hasOption(Annotatable element, String option){
		hasOption(element, "mc", option)
	}
	
	def hasOption(Annotatable element, String annotation, String option){
		element.getAnnotationValues(annotation).contains(option)		
	}
	
	def boolean hasInheritedAnnotation(ModelElement element, String annotation){
		if (element !== null){
			if (element.hasAnnotation(annotation)) return true;
			
			return element.superType.hasInheritedAnnotation(annotation)
		}
		false
	}
	
	def getAttributesWithAnnotation(ModelElement element, String annotation){
		element.allAttributes.filter[hasAnnotation(annotation)].toList
	}
	
	def getUserDefinedTypeAttributes(ModelElement element){
		element.allAttributes.filter[type instanceof UserDefinedType]
	}
	
	def getAnnotationValues(Annotatable element, String annotation){
		element.annotations.filter[
			name == annotation
		].flatMap[value].toList
	}
}
