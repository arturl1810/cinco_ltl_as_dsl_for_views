package de.jabc.cinco.meta.core.ge.style.generator.main

import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramEditorTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramTypeProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.FeatureProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.FileExtensionContent
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphModelEContentAdapterTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphitiCustomFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.GraphitiUtilsTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.ImageProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
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
import de.jabc.cinco.meta.core.ge.style.generator.templates.delete.NodeDeleteFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage.ContextTmp
import de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage.ResolverTmp
import de.jabc.cinco.meta.core.ge.style.generator.templates.layout.EdgeLayoutFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.layout.NodeLayoutFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.move.NodeMoveFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.reconnect.EdgeReconnectFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.resize.NodeResizeFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.update.EdgeUpdateFeatures
import de.jabc.cinco.meta.core.ge.style.generator.templates.update.NodeUpdateFeatures
import de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent
import de.jabc.cinco.meta.core.utils.CincoUtils
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
import de.jabc.cinco.meta.core.ge.style.generator.templates.ModelElementEContentAdapter

class GraphitiGeneratorMain extends GeneratorUtils { 
	
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
	extension NodeDeleteFeatures = new NodeDeleteFeatures
	extension EdgeAddFeatures = new EdgeAddFeatures
	extension EdgeCreateFeatures = new EdgeCreateFeatures
	extension NodeLayoutFeatures = new NodeLayoutFeatures
	extension NodeResizeFeatures = new NodeResizeFeatures
	extension NodeMoveFeatures = new NodeMoveFeatures
	extension NodeUpdateFeatures = new NodeUpdateFeatures
	extension EdgeUpdateFeatures = new EdgeUpdateFeatures
	extension EdgeLayoutFeatures = new EdgeLayoutFeatures
	extension EdgeReconnectFeatures = new EdgeReconnectFeatures
	extension GraphModelEContentAdapterTmpl = new GraphModelEContentAdapterTmpl
	extension ModelElementEContentAdapter = new ModelElementEContentAdapter
	extension GraphitiCustomFeatureTmpl = new GraphitiCustomFeatureTmpl
	
	var GraphModel gm
	var IFile cpdFile
	Styles styles
	
	new (GraphModel gm, IFile cpdFile, Styles s) {
		this.gm = gm
		this.cpdFile = cpdFile
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
		content = gm.generateGraphModelEContentAdapter
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameEContentAdapter, gm.name.toFirstUpper.concat("EContentAdapter.java"), content)
//		content = gm.generateCustomFeature
//		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper.concat("GraphitiCustomFeature.java"), content)
		
		for (Node n : gm.nodes) {
			if (n.isPrime){
				content = n.doGeneratePrimeAddFeature(styles)
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeaturePrime"+n.name.toFirstUpper+".java", content)
			}
			content = n.doGenerateNodeAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeature"+n.name.toFirstUpper+".java", content)
			
			if (!n.isIsAbstract) {
				content = n.doGenerateNodeCreateFeature(styles) 
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameCreate, "CreateFeature"+n.name.toFirstUpper+".java", content)
				
				content = n.generateModelElementEContentAdapter
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameEContentAdapter, n.name.toFirstUpper.concat("EContentAdapter.java"), content)
			}
			
			content = n.doGenerateNodeDeleteFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameDelete, "DeleteFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeLayoutFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameLayout, "LayoutFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeResizeFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameResize, "ResizeFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeMoveFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameMove, "MoveFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateNodeUpdateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameUpdate, "UpdateFeature"+n.name.toFirstUpper+".java", content)
			
		}
		
		for (Edge e : gm.edges) {
			content = e.doGenerateEdgeAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameAdd, "AddFeature"+e.name.toFirstUpper+".java", content)

			if (!e.isIsAbstract) {
				content = e.doGenerateEdgeCreateFeature(styles)
				ContentWriter::writeJavaFileInSrcGen(project, e.packageNameCreate, "CreateFeature"+e.name.toFirstUpper+".java", content)
				
				content = e.generateModelElementEContentAdapter
				ContentWriter::writeJavaFileInSrcGen(project, e.packageNameEContentAdapter, e.name.toFirstUpper.concat("EContentAdapter.java"), content)
			}
			
			content = e.doGenerateEdgeUpdateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameUpdate, "UpdateFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateEdgeLayoutFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameLayout, "LayoutFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateEdgeReconnectFeature
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameReconnect, "ReconnectFeature"+e.fuName+".java", content)
			
		}
		
		var usedExtensions = CincoUtils.getUsedExtensions(gm);
	    var fileExtensionClassContent = new FileExtensionContent(gm, usedExtensions).generateJavaClassContents(gm);
	    ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper+ "FileExtensions" +".java",fileExtensionClassContent)
		
		var pluginXMLContent = gm.generatePluginXML

		
		var cp = CincoUtils::getCPD(cpdFile) as CincoProduct
		
		if (cp.getDefaultPerspective() != null && !cp.getDefaultPerspective().isEmpty())
			return;
		 
		var defaultPerspectiveContent = DefaultPerspectiveContent::generateDefaultPerspective(cp, cpdFile)
		var defaultXMLPerspectiveContent = DefaultPerspectiveContent::generateXMLPerspective(cp, cpdFile.getProject().getName())
		
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, cp.name+"Perspective.java",defaultPerspectiveContent)
		
		
		pluginXMLContent.add(defaultXMLPerspectiveContent)
				
		ContentWriter::writePluginXML(project, pluginXMLContent)
		CincoUtils.refreshProject(new NullProgressMonitor(), project)
		
		 
	
	}
	
}
