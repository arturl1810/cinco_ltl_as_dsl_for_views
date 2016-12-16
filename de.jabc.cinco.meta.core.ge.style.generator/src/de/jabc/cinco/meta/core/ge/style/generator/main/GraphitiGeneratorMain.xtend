package de.jabc.cinco.meta.core.ge.style.generator.main

//import ProductDefinition.CincoProduct
import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramEditorTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.DiagramTypeProviderTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.FeatureProviderTmpl
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
import de.jabc.cinco.meta.core.ge.style.generator.templates.layout.NodeLayoutFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.move.NodeMoveFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.resize.NodeResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.update.EdgeUpdateFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.update.NodeUpdateFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.NullProgressMonitor
import style.Styles
import de.jabc.cinco.meta.core.ge.style.generator.templates.FileExtensionContent
import java.util.List
import productDefinition.CincoProduct

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
	extension NodeLayoutFeature = new NodeLayoutFeature
	extension NodeResizeFeature = new NodeResizeFeature
	extension NodeMoveFeature = new NodeMoveFeature
	extension NodeUpdateFeature = new NodeUpdateFeature
	extension EdgeUpdateFeature = new EdgeUpdateFeature
	
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
		
		for (Node n : gm.nodes) {
			if (n.isPrime){
				content = n.doGeneratePrimeAddFeature(styles)
				ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeaturePrime"+n.name.toFirstUpper+".java", content)
			}
			content = n.doGenerateAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAdd, "AddFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateCreateFeature
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameCreate, "CreateFeature"+n.name.toFirstUpper+".java", content)
			
			content = n.doGenerateDeleteFeature(styles)
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
			content = e.doGenerateAddFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameAdd, "AddFeature"+e.name.toFirstUpper+".java", content)

			content = e.doGenerateCreateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameCreate, "CreateFeature"+e.name.toFirstUpper+".java", content)
			
			content = e.doGenerateEdgeUpdateFeature(styles)
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameUpdate, "UpdateFeature"+e.name.toFirstUpper+".java", content)
		}
		
		var usedExtensions = CincoUtils.getUsedExtensions(gm);
	    var fileExtensionClassContent = new FileExtensionContent(gm, usedExtensions).generateJavaClassContents(gm);
	    ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, gm.name.toFirstUpper+ "FileExtensions" +".java",fileExtensionClassContent)
		
		var pluginXMLContent = gm.generatePluginXML

		
		var cp = CincoUtils::getCPD(cpdFile) as CincoProduct
//		var pluginXML = project.getFile("plugin.xml");  
//		var extensionCommentID = "<!--@CincoGen "+cp.getName().toUpperCase()+"-->";
		
		if (cp.getDefaultPerspective() != null && !cp.getDefaultPerspective().isEmpty())
			return;
		 
		var defaultPerspectiveContent = de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent::generateDefaultPerspective(cp, gm.packageName.toString)
		var defaultXMLPerspectiveContent = de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent::generateXMLPerspective(cp, cpdFile.getProject().getName())
		
//		var file = project.getFile("src-gen/"+project.getName().replace(".", "/")+"/"+cp.getName()+"Perspective.java");
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageName, cp.name+"Perspective.java",defaultPerspectiveContent)
		
//		CincoUtils.writeContentToFile(file, defaultPerspectiveContent.toString());
//		CincoUtils.addExtension(pluginXML.getLocation().toString(), defaultXMLPerspectiveContent.toString(), extensionCommentID, project.getName());
		
		pluginXMLContent.add(defaultXMLPerspectiveContent)
				
		ContentWriter::writePluginXML(project, pluginXMLContent)
		CincoUtils.refreshProject(new NullProgressMonitor(), project)
		
		 
	
	}
	
}