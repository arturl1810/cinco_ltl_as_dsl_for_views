package de.jabc.cinco.meta.plugin.modelchecking.validation


import org.eclipse.emf.ecore.EObject
import mgl.UserDefinedType
import mgl.Attribute
import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult
import mgl.impl.ComplexAttributeImpl
import mgl.GraphModel
import mgl.impl.PrimitiveAttributeImpl
import mgl.EDataTypeType
import org.eclipse.emf.ecore.EStructuralFeature
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator
import mgl.Node
import mgl.Edge
import mgl.Annotation
import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import mgl.ModelElement
import java.util.Arrays
import de.jabc.cinco.meta.plugin.modelchecking.provider.ModelCheckingProposalProvider

class ModelCheckingValidator implements IMetaPluginValidator{
	
	extension GraphModelExtension = new GraphModelExtension
	
	var EObject checkObject = null
	
	override checkAll(EObject eObject){
		checkObject = eObject
		var ValidationResult<String, EStructuralFeature> result 
		
		//Annotation
		
		if (eObject instanceof Annotation){
			result = eObject.checkAnnotationWithoutModelcheck
			if (result !== null){
					return result
			}
			
			result = eObject.checkHasValidNumberOfArguments
			if (result !== null){
					return result
			}
			
			result = eObject.checkHasValidOptions
			if (result !== null){
					return result
			}
			
			result = eObject.checkAnnotationOnValidElement
			if (result !== null){
					return result
			}	
		}
		
		
		// Attribute
		
		if (eObject instanceof Attribute){	
			
			//Formulas Attribute
			if (eObject.hasAnnotation("mcFormulas")){
				
				
				//Errors
				
				result = eObject.checkFormulasAttributeIsList
				
				if (result !== null){
					return result
				}
				
				result = eObject.checkFormulasIsGraphModelAttribute
				
				if (result !== null){
					return result
				}
				
				result = eObject.checkFormulasAttributeCorrectType
				
				if (result !== null){
					return result
				}
				
				result = eObject.checkFormulasAttributeReadOnly
				
				if (result !== null){
					return result
				}
				
				
				
				//Warnings
				
								
				result = eObject.checkFormulasAttributeHidden
				if (result !== null){
					return result
				}	
				
				result = eObject.checkFormulasHasBooleanAttribute
				if(result !== null){
					return result
				}
				
				result = eObject.checkIsFirstFormulasAttribut
				
				if (result !== null){
					return result
				}	
				
					
			}
		
		}
		return null
	}
	
	//Annotation Checks
	
	def checkAnnotationWithoutModelcheck(Annotation annotation){
		if (annotation.modelCheckingAnnotation){
			var ModelElement modelElement
			if (annotation.parent instanceof Attribute){
				modelElement = (annotation.parent as Attribute).modelElement
			}
			else if(annotation.parent instanceof ModelElement){
				modelElement = annotation.parent as ModelElement
			}			
			if (!modelElement?.graphModel.annotations.map[name].contains("modelchecking")){
				return newError("To use this Annotation the graphmodel needs to be annotated with @modelchecking.")
			}
		}	
			
	}

	
	def checkAnnotationOnValidElement(Annotation annotation){
		switch(annotation.name){
			case "mcAtomicProposition":{
				var element = (annotation.parent as Attribute).modelElement
				if (!(element instanceof Node) && !(element instanceof UserDefinedType)){
					return newError("Atomic Propositions are only allowed in Nodes/Containers and UserDefinedTypes")
				}
				if (!((annotation.parent as Attribute) instanceof PrimitiveAttributeImpl)){
					return newError("@mcAtomicProposition is only allowed on primitive attributes like EString, EInt, ...")
				}
			}
			case "mcEdgeLabel":{
				var element = (annotation.parent as Attribute).modelElement
				if (!(element instanceof Edge) && !(element instanceof UserDefinedType)){
					return newError("Edge Labels are only allowed in Edges and UserDefinedTypes")
				}
				if (!((annotation.parent as Attribute) instanceof PrimitiveAttributeImpl)){
					return newError("@mcEdgeLabel is only allowed on primitive attributes like EString, EInt, ...")
				}
			}
		}
	}
	
	def checkHasValidNumberOfArguments(Annotation annotation){
		switch(annotation.name){
			case "modelchecking":{
				if (annotation.value.size > 1){
					return newError("Invalid number of arguments.")
				}
			} 
			case "mcStartNode", case "mcSupportNode", case "mcAtomicProposition", case "mcEdgeLabel", case "mcFormulas":{
				if (annotation.value.size > 0){
					return newError("Invalid number of arguments.")
				}
			}
			case  "mcFulfillmentConstraint", case "mcDefault", case "mc", case "mcHighlightColor": {
				if (annotation.value.size != 1){
					return newError("Invalid number of arguments.")
				}
			}
		}		
	}
	
	def checkHasValidOptions(Annotation annotation){
		if (annotation.modelCheckingAnnotation && annotation.name != "modelchecking"){
			val acceptedStrings = (new ModelCheckingProposalProvider)
				.getAcceptedStrings(annotation)			
			val unknown = annotation.value.filter[
				!acceptedStrings.map[replace("\"","")].contains(it)
			]
			if (!unknown.empty){
				if (unknown.size == 1 && unknown.get(0) !== null){
					return newError(Arrays.toString(unknown) + " is an unknown values. Only use " + Arrays.toString(acceptedStrings)+ ".")
				}else{
					return newError(Arrays.toString(unknown) + " are unknown values. Only use " + Arrays.toString(acceptedStrings)+ ".")
				}
			}
		}
	}
	
	def checkValidNumberOfAnnotations(Annotation annotation){
		if (annotation.modelCheckingAnnotation){
			val parent = annotation.parent
			if (parent.annotations.filter[name == annotation.name].size > 1){
				return newError("Only one @" + annotation.name + " annotation is allowed.")
			}	
		}		
	}
	
	//Formulas Attribute
	
	def checkFormulasAttributeIsList(Attribute attr){
		if (attr.lowerBound != 0 || attr.upperBound != -1){
			return newError("The mcFormulas attribute needs to be a list with lowerBound = 0 and infinite upperBound")
		}
		null
	}
	
	def checkFormulasAttributeCorrectType(Attribute attr){
	
		if (attr instanceof ComplexAttributeImpl && (attr as ComplexAttributeImpl).type instanceof UserDefinedType){
			
			val attrType = (attr as ComplexAttributeImpl).type as UserDefinedType	
			
			val hasTwoStringAttributes = attrType.attributes.filter[
												lowerBound == 0 && upperBound == 1 	
												&& it instanceof PrimitiveAttributeImpl
												&& (it as PrimitiveAttributeImpl).type == EDataTypeType.ESTRING
								 			].size>1
			if (!hasTwoStringAttributes){
				return newError(
					"The type of the @mcFormulas attribute needs to have two attributes of type EString and optional one attribute of type EBoolean. "+
					"E.g. use the following UserDefinedType:\n\n" +
					"type Formula{\n"+
					"\tattr EString as expression\n"+
					"\tattr EString as description\n"+
					"\tattr EBoolean as toCheck\n"+
					"}"
				)	
			} 	
		}		
	}
	
	def checkIsFirstFormulasAttribut(Attribute attr){
		if (attr.eContainer instanceof GraphModel){
			var model = attr.eContainer as GraphModel
			var index = 0
			var formulasFound = false
			while (!formulasFound && index < model.attributes.size){
				if(model.attributes.get(index).annotations.map[name].contains("mcFormulas")){
					formulasFound = true
				}else{
					index++
				}
			}
			
			if (formulasFound && attr.equals(model.attributes.get(index))){
				return null
			}else{
				return newWarning("There is already a mcFormulas attribute. Only the first will be used.")
			}
		}
		null
	}
	
	def checkFormulasIsGraphModelAttribute(Attribute attr){
		if (!(attr.eContainer instanceof GraphModel)){
			return newError("mcFormulas attribute has to be a direct GraphModel attribute.")
		}
		null
	}
	
	def checkFormulasAttributeReadOnly(Attribute attr){
		if (!attr.annotations.map[name].contains("readOnly")){
			return newError("mcFormulas attribute has to be annotated with @readOnly.")
		}
		null
	}
	
	def checkFormulasAttributeHidden(Attribute attr){
		if (!attr.annotations.map[name].contains("propertiesViewHidden")){
			return newWarning("mcFormulas attribute should be annotated with @propertiesViewHidden.")
		}
		null
	}
	
	def checkFormulasHasBooleanAttribute(Attribute attr){
		if (attr instanceof ComplexAttributeImpl && (attr as ComplexAttributeImpl).type instanceof UserDefinedType){
			val attrType = (attr as ComplexAttributeImpl).type as UserDefinedType	
			val hasBoolAttr = attrType.attributes.filter[
												lowerBound == 0 && upperBound == 1 	
												&& it instanceof PrimitiveAttributeImpl
												&& (it as PrimitiveAttributeImpl).type == EDataTypeType.EBOOLEAN
								 			].size > 0
			if (!hasBoolAttr && startNodesExist(attrType.typesOpposite))	{
				return newWarning(
					"To safe the check-option also add an attribute of type EBoolean."
				)
			}			
		}
	}
	
	//Util Methods
	
	def isModelCheckingAnnotation(Annotation annotation){
		var annotations = #[
			"modelchecking",
			"mcDefault",
			"mcHighlightColor",
			"mcFulfillmentConstraint",
			"mcStartNode",
			"mcSupportNode",
			"mcAtomicProposition",
			"mcEdgeLabel",
			"mcFormulas",
			"mc"			
		]
		annotations.contains(annotation.name)
	}
	
	def startNodesExist(GraphModel model){
		model.nodes.exists[hasAnnotation("mcStartNode")]
	}
	
	def newError(String message) {
		ValidationResult.newError(message, checkObject.eClass.getEStructuralFeature("name"))
	}
	
	def newInfo(String message) {
		ValidationResult.newInfo(message, checkObject.eClass.getEStructuralFeature("name"))
	}
	
	def newWarning(String message) {
		ValidationResult.newWarning(message, checkObject.eClass.getEStructuralFeature("name"))
	}
	
}