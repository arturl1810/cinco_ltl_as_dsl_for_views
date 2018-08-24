package de.jabc.cinco.meta.plugin.validation

import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator
import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult
import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import mgl.Annotation
import mgl.Edge
import mgl.Node
import mgl.NodeContainer
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature

/**
 * Simplificated framework to check mgl-files for your plugin.
 * Just implement the methods you need, return a ValidationResult in 
 * case of an error, warning or info and null otherwise.
 * Aditionally implement the init function and set the projectAnnotation String
 * that the validator can recognize your annotation.
 */
abstract class SimpleValidator implements IMetaPluginValidator{
	
	protected extension GraphModelExtension = new GraphModelExtension
	protected extension ValidationExtension = new ValidationExtension
	
	var EObject checkObject = null
	var ValidationResult<String, EStructuralFeature> result = null
	
	/**
	 * runs all check methods that are proposed by this class and hands over the first error, warning or info found.
	 */
	
	override checkAll(EObject eObject) {
		this.checkObject = eObject
		init
		//Node
		if(eObject instanceof Node){
			result = checkNode(eObject)
			if(result!==null){
				return result;
			}
			if(eObject.hasAnnotation(getProjectAnnotation)){
				result = checkNodeWithProjectAnnotation(eObject)
				if(result!==null){
					return result;
				}
			}
			//Container Node
			if(eObject instanceof NodeContainer){
				result = checkContainer(eObject)
				if(result!==null){
					return result;
				}
				if(eObject.hasAnnotation(getProjectAnnotation)){
					result = checkContainerWithProjectAnnotation(eObject)
					if(result!==null){
						return result;
					}
				}
			}else{ //non Container Node
				if(!(eObject instanceof NodeContainer)){
					result = checkNonContainer(eObject)
					if(result!==null){
						return result;
					}
					if(eObject.hasAnnotation(getProjectAnnotation)){
						result = checkNonContainerWithProjectAnnotation(eObject)
						if(result!==null){
							return result;
						}
					}
				}
			}
		}
		//Edge
		if(eObject instanceof Edge){
			result = checkEdge(eObject)
			if(result!==null){
				return result;
			}
			if(eObject.hasAnnotation(getProjectAnnotation)){
				result = checkEdgeWithProjectAnnotation(eObject)
				if(result!==null){
					return result;
				}
			}
		}
		//Annotation
		if(eObject instanceof Annotation){
			result = checkAnnotation(eObject)
			if(result!==null){
				return result;
			}
			if(eObject.name.equals(getProjectAnnotation)){
				result = checkProjectAnnotation(eObject)
				if(result!==null){
					return result;
				}
			}
		}
		//eObject
		result = checkObject(eObject)
		if(result!==null){
			return result;
		}
		return null;	
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
	
	/**
	 * This method has to return the your project annotation, that should be recognized by the validator.
	 * If you want to use any of the validation Functions that include the Annotation, you have to set it here.
	 * Otherwise the return value can be an arbitrary String.
	 * The return value must not be null.
	 */
	def abstract String getProjectAnnotation()
	
	/**
	 * Called first in the checkAll method.
	 */
	def void init(){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes.
	 */
	def private ValidationResult<String, EStructuralFeature> checkNode(Node node){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes, when the name of one of their annotations matches the projectAnnotation field.
	 */
	def ValidationResult<String, EStructuralFeature> checkNodeWithProjectAnnotation(Node node){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Edges.
	 */
	def ValidationResult<String, EStructuralFeature> checkEdge(Edge edge){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Edges, when the name of one of their annotations matches the projectAnnotation field.
	 */
	def ValidationResult<String, EStructuralFeature> checkEdgeWithProjectAnnotation(Edge edge){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes that are also Containers.
	 */
	def ValidationResult<String, EStructuralFeature> checkContainer(NodeContainer cont){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes that are also Containers, when the name of one of their annotations matches the projectAnnotation field.
	 */
	def ValidationResult<String, EStructuralFeature> checkContainerWithProjectAnnotation(NodeContainer cont){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes that are no Containers.
	 */
	def ValidationResult<String, EStructuralFeature> checkNonContainer(Node node){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Nodes that are no Containers, when the name of one of their annotations matches the projectAnnotation field.
	 */
	def ValidationResult<String, EStructuralFeature> checkNonContainerWithProjectAnnotation(Node node){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Annotations.
	 */
	def ValidationResult<String, EStructuralFeature> checkAnnotation(Annotation annot){
		//to be overridden in SubClasses
	}
	/**
	 * Called on Annotations, when their name matches the projectAnnotation field.
	 */
	def ValidationResult<String, EStructuralFeature> checkProjectAnnotation(Annotation annot){
		//to be overridden in SubClasses
	}
	/**
	 * Called on all EObjects.
	 */
	def ValidationResult<String, EStructuralFeature> checkObject(EObject element){
		//to be overridden in SubClasses
	}
}
