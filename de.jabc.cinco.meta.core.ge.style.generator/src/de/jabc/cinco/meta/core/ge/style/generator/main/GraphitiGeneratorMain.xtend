package de.jabc.cinco.meta.core.ge.style.generator.main

import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramEditorTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramTypeProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.EmfFactoryTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.FeatureProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.FileExtensionContent
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphModelEContentAdapterTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphitiCustomFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphitiResourceFactory
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphitiUtilsTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.ImageProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.ModelElementEContentAdapter
import de.jabc.cinco.meta.core.ge.style.generator.templates.NewDiagramWizardPageTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.NewDiagramWizardTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.PerspectiveTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.PluginXMLTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.PropertyViewTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.ToolBehaviorProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.add.EdgeAddFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.add.NodeAddFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.create.EdgeCreateFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.create.NodeCreateFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.delete.ModelElementDeleteFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage.ContextTmp
import de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage.ResolverTmp
import de.jabc.cinco.meta.core.ge.style.generator.templates.layout.EdgeLayoutFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.layout.NodeLayoutFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.move.NodeMoveFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.reconnect.EdgeReconnectFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.resize.NodeResizeFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.update.ModelElementUpdateFeatures
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.NullProgressMonitor
import productDefinition.CincoProduct
import style.Styles
import java.util.List
import java.util.ArrayList

import static extension de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent.*
import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramTmpl

class GraphitiGeneratorMain extends GeneratorUtils { 
	
	extension DiagramTmpl = new DiagramTmpl
	extension DiagramEditorTmpl = new DiagramEditorTmpl
	extension DiagramTypeProviderTmpl = new DiagramTypeProviderTmpl
	extension FeatureProviderTmpl = new FeatureProviderTmpl
	extension ImageProviderTmpl = new ImageProviderTmpl
	extension NewDiagramWizardTmpl = new NewDiagramWizardTmpl
	extension NewDiagramWizardPageTmpl = new NewDiagramWizardPageTmpl
	extension PerspectiveTmpl = new PerspectiveTmpl
	extension PluginXMLTmpl = new PluginXMLTmpl
	extension PropertyViewTmpl = new PropertyViewTmpl
	extension ToolBehaviorProviderTmpl = new ToolBehaviorProviderTmpl
	extension GraphitiUtilsTmpl = new GraphitiUtilsTmpl
	extension LayoutFeatureTmpl = new LayoutFeatureTmpl
	extension ContextTmp = new ContextTmp
	extension ResolverTmp = new ResolverTmp
	extension NodeAddFeatures = new NodeAddFeatures
	extension NodeCreateFeatures = new NodeCreateFeatures
	extension ModelElementDeleteFeatures = new ModelElementDeleteFeatures
	extension EdgeAddFeatures = new EdgeAddFeatures
	extension EdgeCreateFeatures = new EdgeCreateFeatures
	extension NodeLayoutFeatures = new NodeLayoutFeatures
	extension NodeResizeFeatures = new NodeResizeFeatures
	extension NodeMoveFeatures = new NodeMoveFeatures
	extension ModelElementUpdateFeatures = new ModelElementUpdateFeatures
	extension EdgeLayoutFeatures = new EdgeLayoutFeatures
	extension EdgeReconnectFeatures = new EdgeReconnectFeatures
	extension EmfFactoryTmpl = new EmfFactoryTmpl
	extension GraphitiResourceFactory = new GraphitiResourceFactory
	extension ModelElementEContentAdapter = new ModelElementEContentAdapter
	
	var GraphModel gm
	var IFile cpdFile
	var Styles styles
	val CincoProduct cincoProduct
	var List<CharSequence> pluginXMLContent = new ArrayList<CharSequence>
	
	new (GraphModel gm, IFile cpdFile, Styles s) {
		this.gm = gm
		this.cpdFile = cpdFile
		this.cincoProduct = CincoUtil::getCPD(cpdFile) as CincoProduct
		styles = s
	}
	
	def doGenerate(IProject project) {
		var content = gm.generateDiagramTypeProvider
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("DiagramTypeProvider.java"), content)
		content = gm.generateFeatureProvider
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("FeatureProvider.java"), content)
		content = gm.generateImageProvider
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("ImageProvider.java"), content)
		content = gm.generateLayoutFeature(styles)
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("LayoutUtils.java"), content)
		content = gm.generateToolBehaviorProvider
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("ToolBehaviorProvider.java"), content)
		content = gm.generateNewDiagramWizard
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName.toString.concat(".wizard"), gm.name.toFirstUpper.concat("DiagramWizard.java"), content)
		content = gm.generateNewDiagramWizardPage
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName.toString.concat(".wizard"), gm.name.toFirstUpper.concat("DiagramWizardPage.java"), content)
		content = gm.generateDiagram
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("Diagram.java"), content)
		content = gm.generateDiagramEditor
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("DiagramEditor.java"), content)
		content = gm.generatePerspective
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("PerspectiveFactory.java"), content)
		content = gm.generatePropertyView
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName.toString.concat(".property.view"), gm.name.toFirstUpper.concat("PropertyView.java"), content)
		content = gm.generateGraphitiUtils
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("GraphitiUtils.java"), content)
		content = gm.generateResolver
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameExpression, gm.name.toFirstUpper.concat("ExpressionLanguageResolver.java"), content)
		content = gm.generateContext
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameExpression, gm.name.toFirstUpper.concat("ExpressionLanguageContext.java"), content)
//		content = gm.generateGraphModelEContentAdapter
//		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameEContentAdapter, gm.name.toFirstUpper.concat("EContentAdapter.java"), content)
//		content = gm.generateCustomFeature
//		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("GraphitiCustomFeature.java"), content)
		content = gm.generateFactory
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("Factory.java"), content)
		content = gm.generateResourceFactory
		ContentWriter::writeFile(project, "src-gen", gm.packageName, gm.name.toFirstUpper.concat("ResourceFactory.xtend"), content)
		
		for (Node n : gm.nodes.filter[!isIsAbstract]) {
			if (n.isPrime){
				content = n.doGeneratePrimeAddFeature(styles)
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeaturePrime"+n.name.toFirstUpper+".java", content)
			}
			content = n.doGenerateNodeAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeature"+n.name.toFirstUpper+".java", content)
			
			if (!n.isIsAbstract) {
				content = n.doGenerateNodeCreateFeature(styles) 
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameCreate, "CreateFeature"+n.name.toFirstUpper+".java", content)
			}
			
			content = n.doGenerateModelElementDeleteFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameDelete, "DeleteFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeLayoutFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameLayout, "LayoutFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeResizeFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameResize, "ResizeFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeMoveFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameMove, "MoveFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateModelElementUpdateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameUpdate, "UpdateFeature"+n.name.toFirstUpper+".java", content)
			
		}
		
		for (Edge e : gm.edges.filter[!isIsAbstract]) {
			content = e.doGenerateEdgeAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameAdd, "AddFeature"+e.name.toFirstUpper+".java", content)

			if (!e.isIsAbstract) {
				content = e.doGenerateEdgeCreateFeature(styles)
				ContentWriter::writeJavaFileInSrcGen(project, e.packageNameCreate, "CreateFeature"+e.name.toFirstUpper+".java", content)
			}
			
			content = e.doGenerateModelElementDeleteFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameDelete, "DeleteFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateModelElementUpdateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameUpdate, "UpdateFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateEdgeLayoutFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameLayout, "LayoutFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateEdgeReconnectFeature
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameReconnect, "ReconnectFeature"+e.fuName+".java", content)
			
			
		}
		
//		for (me : gm.modelElements.filter[!isIsAbstract]) {
//			content = me.doGenerateModelElementEContentAdapter
//			ContentWriter::writeJavaFileInSrcGen(project, me.packageNameEContentAdapter, me.fuName+"EContentAdapter.java", content)
//		}
		
		var usedExtensions = CincoUtil.getUsedExtensions(gm);
	    var fileExtensionClassContent = new FileExtensionContent(gm, usedExtensions).generateJavaClassContents(gm);
	    ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper+ "FileExtensions" +".java",fileExtensionClassContent)
		
		pluginXMLContent = gm.generatePluginXML
		if (cincoProduct.defaultPerspective.nullOrEmpty) {
			content = cincoProduct.generateXMLPerspective(cpdFile.project.name)
			pluginXMLContent.add(content)
			content = cincoProduct.generateDefaultPerspective(cpdFile)
			ContentWriter::writeJavaFileInSrcGen(project, cpdFile.project.name+".editor.graphiti", cincoProduct.name+"Perspective.java", content)
		}
				
		ContentWriter::writePluginXML(project, pluginXMLContent, '''<!--@CincoGen «gm.fuName»-->''')
		CincoUtil.refreshProject(new NullProgressMonitor(), project)
	}
	
}
