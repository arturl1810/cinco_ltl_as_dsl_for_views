package de.jabc.cinco.meta.plugin.behavior.validation

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult
import de.jabc.cinco.meta.plugin.behavior.Constants
import de.jabc.cinco.meta.plugin.validation.SimpleValidator
import de.jabc.cinco.meta.plugin.validation.ValidationExtension
import mgl.Annotation
import mgl.NodeContainer
import org.eclipse.emf.ecore.EStructuralFeature

class Validator extends SimpleValidator {

	extension ValidationExtension = new ValidationExtension

	override getProjectAnnotation() {
		return Constants.PROJECT_ANNOTATION
	}

	override checkProjectAnnotation(Annotation annot) {
		// sequential checks fail on first error/warning
		PostCreateHookCheck(annot)
		?: PostMoveHookCheck(annot)
		?: ArgumentCheck(annot)
	}

	/**
	 * This method checks whether there are the corresponding PostCreateHook annotations for the PostCreateHooks generated by the Plugin.
	 * If they are there, the method returns null.
	 * If they are not there, the method returns a warning, that should be shown in the editor. 
	 * @param annotation on which the check is performed  
	 * @return error returned 
	 */
	def ValidationResult<String, EStructuralFeature> PostCreateHookCheck(Annotation annot) {
		val NodeContainer element = annot.annotatedModelElement as NodeContainer
		for (node : element.containableNodes) {
			val String hookClassNameIncludingPackage = Constants.projectPackage(node) + "." +
				Constants.getPostCreateHookClassName(node)
			val Annotation postCreateAnnotation = node.annotations.filter[name == "postCreate"].head
			if (postCreateAnnotation === null ||
				!hookClassNameIncludingPackage.equals(postCreateAnnotation?.getValue()?.get(0))) {
				return newWarning(
					"To use the container behavior annotation you need the corresponding postCreate hooks at all containable nodes." +
						" The postCreate annotation of the node " + node.name + " is missing." +
						" It should be: @postCreate(\"" + hookClassNameIncludingPackage + "\")")
			}
		}
		return null;

	}

	/**
	 * This method checks whether there are the corresponding PostMoveHook annotations for the PostMoveHooks generated by the Plugin.
	 * If they are there, the method returns null.
	 * If they are not there, the method returns a warning, that should be shown in the editor. 
	 * @param annotation on which the check is performed  
	 * @return error returned 
	 */
	def ValidationResult<String, EStructuralFeature> PostMoveHookCheck(Annotation annot) {
		val NodeContainer element = annot.annotatedModelElement as NodeContainer
		for (node : element.containableNodes) {
			val String hookClassNameIncludingPackage = Constants.projectPackage(node) + "." +
				Constants.getPostMoveHookClassName(node)
			val Annotation postMoveAnnotation = node.annotations.filter[name == "postMove"].head
			if (postMoveAnnotation === null ||
				!hookClassNameIncludingPackage.equals(postMoveAnnotation?.getValue()?.get(0))) {
				return newWarning(
					"To use the container behavior annotation you need the corresponding postMove hooks at all containable nodes." +
						" The postMove annotation of the node " + node.name + " is missing." +
						" It should be: @postMove(\"" + hookClassNameIncludingPackage + "\")")
			}
		}
		return null;
	}

	/**
	 * This method checks whether the argument of annotation is a class
	 * and whether it implements the Interface BehaviorProvider 
	 * @param annotation on which the check is performed  
	 * @param element annotated container 
	 * @return error returned 
	 */
	def ValidationResult<String, EStructuralFeature> ArgumentCheck(Annotation annot) {
		if (annot.value.size == 1) {
			if (stringRepresentsAFileImplementingInterface(annot.value.get(0), "BehaviorProvider")) {
				return null
			}
			return newWarning("The argument of the container behavior annotation needs to be a file extending 
				\"/de.jabc.cinco.meta.plugin.behavior.runtime.BehaviorProvider\".")
		}
		return newWarning("The container behavior annotation needs exactly one argument: a file extending 
				\"/de.jabc.cinco.meta.plugin.behavior.runtime.BehaviorProvider\" that
				that specifies the container behavior whenever something left or entered it.")

	}

}
