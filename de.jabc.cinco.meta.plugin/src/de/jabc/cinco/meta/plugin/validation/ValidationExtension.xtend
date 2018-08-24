package de.jabc.cinco.meta.plugin.validation

import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import mgl.Node
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IType
import org.eclipse.jdt.core.JavaCore

class ValidationExtension {
	
	protected extension GraphModelExtension = new GraphModelExtension

	//TOREMEMBER kopiert aus de.jabc.cinco.meta.core.mgl.validation.MGLValidator
	/**
	 * Finds the Java class represented by the string parameter.
	 * 
	 * @param parameter String representing the returned class, formatted as "Package.Class" (Fully Qualified Name).
	 */
	def IType findClass(String parameter){
		var IType javaClass = null
		val root = ResourcesPlugin.workspace.root
		val projects = root.projects
		for(project : projects){
			var jproject = JavaCore.create(project) as IJavaProject
			if(jproject.exists){
				try {
						javaClass = jproject.findType(parameter)
						if (javaClass !== null) {
							return javaClass 
						}
					} catch (Exception e) {}
			}
		}
		return javaClass
	
	}
	//TOREMEMBER kopiert aus de.jabc.cinco.meta.core.mgl.validation.MGLValidator
	/**
	 * Returns True iff there is a Java file at the position indicated by parameter.
	 * 
	 * @param parameter String representation of the Class, formatted as "Package.Class".
	 */
	def boolean StringRepresentsAFile(String parameter){
		if(parameter!==null && !parameter.equals("")){
			val correctFile = findClass(parameter)  //find the corresponding java class file
			if(correctFile !== null){
				if(correctFile.exists ){ //checks if class exists 
					return true 
				}
			}
		}
		return false
	}
	/**
	 * Returns True iff there is a Java file at the position indicated by parameter 
	 * and that java file implements the interface indicated by the string interfaceName.
	 * 
	 * @param parameter String representation of the class, formatted as "Package.Class"
	 * @param interfaceName Interface that should be implemented by the class.
	 */
	def boolean stringRepresentsAFileImplementingInterface(String parameter, String interfaceName){
		if(StringRepresentsAFile(parameter)){
			val correctFile = findClass(parameter)
			if(correctFile.newSupertypeHierarchy(null).allInterfaces.map[n|n.elementName].contains(interfaceName)){
				return true
			}
		}
		return false
	}
	
	/**
	 * Returns True iff there is a Java file at the position indicated by parameter 
	 * and that java file extends the class indicated by the string superClassName.
	 * 
	 * @param parameter String representation of the class, formatted as "Package.Class"
	 * @param superClassName superclass that should be extended by the class.
	 */
	def boolean stringRepresentsAFileExtendingClass(String parameter, String superClassName){
		if(StringRepresentsAFile(parameter)){
			val correctFile = findClass(parameter)
			if(correctFile.newSupertypeHierarchy(null).allClasses.map[n|n.elementName].contains(superClassName)){
				return true
			}
		}
		return false
	}
	/**
	 * Returns True iff node has a PostCreateHook with the given hookname as value.
	 * 
	 * @param node to be checked
	 * @param hookName that should be annotated at node
	 * 
	 */
	def postCreateHookCheck(Node node, String hookName){
			val postCreates = node.annotations.filter[name == "postCreate"]
			if(postCreates.exists[value.head==hookName]){
				return true
			}
		return false
	}
	/**
	 * Returns True iff node has a PostMoveHook with the given hookname as value.
	 * 
	 * @param node to be checked
	 * @param hookName that should be annotated at node
	 * 
	 */
	def postMoveHookCheck(Node node, String hookName){
			val postMoves = node.annotations.filter[name == "postMove"]
			if(postMoves.exists[value.head==hookName]){
				return true
			}
		return false
	}
}
