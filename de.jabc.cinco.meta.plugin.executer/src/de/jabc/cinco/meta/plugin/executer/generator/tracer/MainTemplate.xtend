package de.jabc.cinco.meta.plugin.executer.generator.tracer

import static extension de.jabc.cinco.meta.core.utils.eapi.ContainerEAPI.createFolder

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.Node
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.NullProgressMonitor
import mgl.ReferencedModelElement

abstract class MainTemplate {
	
	protected ExecutableGraphmodel graphmodel
	
	new(ExecutableGraphmodel graphmodel){
		this.graphmodel=graphmodel;
	}
	
	def CharSequence create()
	{
		return create(this.graphmodel);
	}
	
	abstract def CharSequence create(ExecutableGraphmodel graphmodel);
	
	abstract def String fileName();
	
	def String getProjectName(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.name+"ES";
	}
	
	static def String getPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".esdsl";
	}
	
	def String getCApiPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".esdsl.api.c"+graphmodel.graphModel.name.toLowerCase+"es";
	}
	
	def String getSourceCApiPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".api.c"+graphmodel.graphModel.name.toLowerCase;
	}
	
	def String getSourceApiPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+"."+graphmodel.graphModel.name.toLowerCase;
	}
	
	def String getApiPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".esdsl."+graphmodel.graphModel.name.toLowerCase+"es";
	}
	
	static def String getTracerPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".esdsl.tracer";
	}
	
	def String getRunnerPackage(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.package+".esdsl.runner";
	}
	
	def String getNsUri(ExecutableGraphmodel graphmodel){
		return graphmodel.graphModel.nsURI+"/esdsl";
	}
	
	def boolean getIsPrime(Node node)
	{
		return node.primeReference != null;	
	}
	
	def String primeAttrName(Node node)
	{
		return node.primeReference.name;
	}
	
	def String primeAttrType(Node node)
	{	
		var type = node.primeReference;
		if(type instanceof ReferencedModelElement){
			return type.type.name;
		}
		return type.class.name;
	}
	
	static def generateFile(MainTemplate template,String folderFQN,IProject project)
	{
		if(!folderFQN.nullOrEmpty)
		{
			var folderPath = folderFQN.replaceAll("\\.","/")
			var folder = project.createFolder(folderPath)			
			ProjectCreator.createFile(template.fileName(),folder,template.create().toString,new NullProgressMonitor())
		}else{
			ProjectCreator.createFile(template.fileName(),project,template.create().toString,new NullProgressMonitor())
		}
		
	}
	
	def generate(String folderFQN,IProject project)
	{
		generateFile(this,folderFQN,project)
	}
}