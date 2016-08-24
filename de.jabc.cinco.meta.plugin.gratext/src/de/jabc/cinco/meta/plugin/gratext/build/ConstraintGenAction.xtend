package de.jabc.cinco.meta.plugin.gratext.build

import java.util.stream.Stream
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.jface.action.IAction
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IActionDelegate

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.resp
import static de.jabc.cinco.meta.core.utils.job.JobFactory.job

import static extension de.jabc.cinco.meta.core.utils.WorkspaceUtil.createResource
import static extension java.util.stream.StreamSupport.stream
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor
import mgl.GraphModel
import mgl.Node
import mgl.NodeContainer

class ConstraintGenAction implements IActionDelegate {
	
	static String GENFOLDER_NAME = "conview-gen"
	
	ISelection selection;
	IProject project;
	GraphModelDescriptor desc
	
	IFolder genFolder;
	IFolder modelGenFolder;
	
	override run(IAction action) {
		job("Constraint View Builder")
			.consume(5, "Initializing...")
			.task([init])
			.consume(95, "Generating...")
			.taskForEach([modelFiles],[run],[name])
			.schedule
	}
	
	def init() {
		project = selectedFiles.findFirst.get.project
		val fldr = project.getFolder(GENFOLDER_NAME)
		if (fldr.exists) [|
			fldr.delete(true, true, null)
		].printException
		genFolder = resp(project).createFolder(GENFOLDER_NAME)
	}
	
	def run(IFile modelFile) {
		createModelGenFolder(modelFile)
		desc = new GraphModelDescriptor(modelFile.resource.contents.get(0) as GraphModel)
		desc.nonAbstractNodes.forEach[genFile]
	}
	
	def genFile(Node node) {
		resp(modelGenFolder).createFile(
			node.name, node.genContent.toString)
	}
	
	def genContent(Node node) '''
		«node.name»«node.genTypeTag»«node.genHierarchy»
		«node.genContainableView»
		«switch node {NodeContainer: node.genContainerView}»
	'''
	
	def genContainerView(NodeContainer cont) '''
		
		=== CAN CONTAIN ==============================
		
		«desc.nonAbstractNodes
			.filter[!isDisabled]
			.filter[desc.resp(cont).canContain(it)]
			.sortBy[name]
			.map['''  + «name»«genContainableHierarchy(cont)»''']
			.join('\n')»
		
		=== CANNOT CONTAIN ===========================
		
		«desc.nonAbstractNodes
			.filter[!isDisabled]
			.filter[!desc.resp(cont).canContain(it)]
			.sortBy[name]
			.map['''  - «name»«genContainableHierarchy(cont)»''']
			.join('\n')»
			
		
		=== EXPLANATION ==============================
		 
		The containment table above provides an overview on containment constraints
		regarding the node named in line 1. The following conditions apply:
		 
		 > A file with a containment table is generated only for nodes that can
		   somehow be created by the user (i.e. non-abstract nodes that are not
		   annotated with @disable(create))
		   
		 > Each table row lists a non-abstract node followed by the respective
		   type hierarchy, while the latter might comprise abstract nodes.
		   
		 > The type hierarchy provides some additional information about containments
		   in order to enable the identification of possible misconception.
		   
		Example: the following table snippet shows that 'SomeType' is a container
		that extends the non-abstract node 'SupType', which extends the abstract node
		'SupSupType'. 'Type' can be contained in 'SomeContainer' that extends the
		non-abstract node 'SupContainer', which extends the abstract node
		'SupSupContainer'. The (+) at 'SupContainer' shows that 'SomeType' can be
		contained in it. The (-) at 'SupSupContainer' shows that 'SomeType' cannot
		be contained in it. 
		
		-----------------------------------------------------------------------
		SomeType[container]		<  SupType  <  SupSupType[abs]
		
		=== CAN BE CONTAINED IN ======================
		
		 + SomeContainer		<  SupContainer(+)  <  SupSupContainer[abs](-)
		-----------------------------------------------------------------------
	'''
	
	def genContainableView(Node node) '''
		
		=== CAN BE CONTAINED IN ======================
		
		«desc.nonAbstractContainers
			.filter[!isDisabled]
			.filter[desc.resp(it).canContain(node)]
			.sortBy[name]
			.map['''  + «name»«genContainerHierarchy(it)»''']
			.join('\n')»
		
		=== CANNOT BE CONTAINED IN ===================
		
		«desc.nonAbstractContainers
			.filter[!isDisabled]
			.filter[!desc.resp(it).canContain(node)]
			.sortBy[name]
			.map['''  - «name»«genContainerHierarchy(it)»''']
			.join('\n')»
	'''
	
	def genHierarchy(Node node) {
		if (node.extends != null)
			'''«'\t\t'»  <  «node.extends.genHierarchyRecurse»'''
	}
	
	def genHierarchyRecurse(Node node) {
		switch node {
			case node.extends != null :
				'''«node.genHierarchyEntry»  <  «node.extends.genHierarchyEntry»'''
			default: '''«node.genHierarchyEntry»'''
		}
	}
	
	def genHierarchyEntry(Node node)
		'''«node.name»«node.genIsAbstractTag»'''
	
	def CharSequence genContainableHierarchy(Node node, NodeContainer cont) {
		if (node.extends != null) 
			'''«node.name.genTabs»  <  «node.extends.genContainableHierarchyRecurse(cont)»'''
	}
	
	def CharSequence genContainableHierarchyRecurse(Node node, NodeContainer cont) {
		switch node {
			case node.extends != null :
				'''«node.genContainableHierarchyEntry(cont)»  <  «node.extends.genContainableHierarchyRecurse(cont)»'''
			default: '''«node.genContainableHierarchyEntry(cont)»'''
		}
	}
	
	def genContainableHierarchyEntry(Node node, NodeContainer cont)
		'''«node.name»«node.genIsAbstractTag»(«node.genIsContainableTag(cont)»)'''
	
	def CharSequence genContainerHierarchy(NodeContainer cont, Node node) {
		if (cont.extends != null) 
			'''«cont.name.genTabs»  <  «(cont.extends as NodeContainer).genContainerHierarchyRecurse(node)»'''
	}
	
	def CharSequence genContainerHierarchyRecurse(NodeContainer cont, Node node) {
		switch cont {
			case cont.extends != null :
				'''«cont.genContainerHierarchyEntry(node)»  <  «(cont.extends as NodeContainer).genContainerHierarchyRecurse(node)»'''
			default: '''«cont.genContainerHierarchyEntry(node)»'''
		}
	}
		
	def genContainerHierarchyEntry(NodeContainer cont, Node node)
		'''«cont.name»«cont.genIsAbstractTag»(«node.genIsContainableTag(cont)»)'''
	
	def genIsAbstractTag(Node node) {
		if (node.isAbstract) '[abs]' else ''
	}
	
	def genIsContainableTag(Node node, NodeContainer cont) {
		if (desc.resp(cont).canContain(node)) '+' else '-'
	}
	
	def genTypeTag(Node node) {
		switch node {
			NodeContainer: '[container]'
			default: '[node]'
		}
	}
	
	def genTabs(String name) {
		var tabs = '\t'
		for (i : 0 ..< 6-(name.length-1)/4) {
			tabs += '\t'
		}
		return tabs
	}
	
	def createModelGenFolder(IFile modelFile) {
		modelGenFolder = resp(genFolder).createFolder(modelFile.projectRelativePath.removeFileExtension.lastSegment)
	}
	
	def createFolder(IPath path) {
		project.getFolder(path).createResource(null)
	}
	
	def getResource(IFile file) {
		new ResourceSetImpl().getResource(
			URI.createPlatformResourceURI(file.fullPath.toOSString, true), true)
	}
	
	def Stream<IFile> getSelectedFiles() {
		switch selection {
			IStructuredSelection case !selection.empty:
				([|selection.iterator] as Iterable<IFile>).spliterator.stream(false)
			default: Stream.empty
		}
	}
	
	def Stream<IFile> getModelFiles() {
		resp(project).getFiles(["mgl".equals(fileExtension)]).stream
	}
	
	def isDisabled(Node node) {
		node.annotations.stream.anyMatch([
			"disable".equals(name) && value.contains("create")])
	}
	
	override selectionChanged(IAction action, ISelection selection) {
		this.selection = selection
	}
	
	static def printException(() => void proc) {
		try {
			proc.apply
		} catch (Exception e) {
			e.printStackTrace
		}
	}
}