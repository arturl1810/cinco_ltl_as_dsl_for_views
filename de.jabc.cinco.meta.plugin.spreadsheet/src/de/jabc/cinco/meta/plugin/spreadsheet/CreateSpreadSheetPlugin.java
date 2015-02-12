package de.jabc.cinco.meta.plugin.spreadsheet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import mgl.GraphModel;
import mgl.Node;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;

import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.plugin.template.CalculationExceptionTemplate;
import de.jabc.cinco.meta.plugin.template.CalculationHandlerTemplate;
import de.jabc.cinco.meta.plugin.template.ExporterTemplate;
import de.jabc.cinco.meta.plugin.template.GenerationHandlerTemplate;
import de.jabc.cinco.meta.plugin.template.ImporterTemplate;
import de.jabc.cinco.meta.plugin.template.MenuPropertyTester;
import de.jabc.cinco.meta.plugin.template.NewSheetDialogTemplate;
import de.jabc.cinco.meta.plugin.template.NodeStatusTemplate;
import de.jabc.cinco.meta.plugin.template.NodeUtilTemplate;
import de.jabc.cinco.meta.plugin.template.OpeningHandlerTemplate;
import de.jabc.cinco.meta.plugin.template.PluginXMLTemplate;
import de.jabc.cinco.meta.plugin.template.ResultNodeComparatorTemplate;
import de.jabc.cinco.meta.plugin.template.SelectSheetDialogTemplate;
import de.jabc.cinco.meta.plugin.template.SheetCalculatorTemplate;
import de.jabc.cinco.meta.plugin.template.SheetHandlerTemplate;
import de.jabc.cinco.meta.plugin.template.UserInteractionTemplate;
import de.jabc.cinco.meta.plugin.template.VersionNodeComparator;
import de.jabc.cinco.meta.plugin.template.VersionNodeTemplate;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreateSpreadSheetPlugin {

	public String execute(LightweightExecutionEnvironment environment)
			throws ServiceException {
		LightweightExecutionContext context = environment.getLocalContext().getGlobalContext();
		
		
		String pluginPath = ".plugin.spreadsheet";
		String fileName = "export.xls";
		String sheetName = "firstSheet";
		String packagePath = "";
		String sheetFolderName = "sheets";
		boolean multiple = false;
		int userCellx =20;
		int userCellY = 20;
		
		
		ArrayList<ResultNode> resultNodes = new ArrayList<ResultNode>();
		ArrayList<Node> allNodes = new ArrayList<Node>();
		ArrayList<CalculatingEdge> calculatingEdges = new ArrayList<CalculatingEdge>();
		
		try {
			GraphModel graphModel = (GraphModel) context.get("graphModel");
			String graphName = graphModel.getName();
			//Search for Graphmodel Annotation "spreadsheetexport" with one argument
			for(mgl.Annotation anno: graphModel.getAnnotations()){
				if(anno.getName().equals("spreadsheet")){
					System.out.println("EXPORT GRAPH AS XLS - Here we go!");
					
					if(anno.getValue().size()>=1)
					{
						System.out.println("XLS Argument: "+anno.getValue().get(0));
						if(anno.getValue().get(0).equals("multiple")){
							multiple=true;
						}
					}
					if(anno.getValue().size() >= 2) {
						System.out.println("Sheet Folder: "+anno.getValue().get(1));
						sheetFolderName = anno.getValue().get(1);
					}
					if(anno.getValue().size() >= 3) {
						System.out.println("Max User Cell Cols: "+anno.getValue().get(2));
						userCellx=Integer.parseInt(anno.getValue().get(2));
					}
					if(anno.getValue().size() >= 4) {
						System.out.println("Max User Cell Rows: "+anno.getValue().get(3));
						userCellY=Integer.parseInt(anno.getValue().get(3));
					}
					
				}
			}
			//All Nodes
			for(Node node: graphModel.getNodes()) {
				allNodes.add(node);
			}
			
			//Search for result nodes
			for(mgl.Node node: graphModel.getNodes()){
				ResultNode resultNode = new ResultNode();
				for(mgl.Annotation anno : node.getAnnotations()){
					if(anno.getName().equals("resulting")){
						resultNode.nodeName = node.getName();
						resultNode.resultAttrNames = new ArrayList<String>();
						resultNode.otherAttrNames = new ArrayList<String>();
						System.out.println("NodeFound "+ node.getName());
						boolean foundresult = false;
						for(mgl.Attribute attr : node.getAttributes())
						{
							
							for(mgl.Annotation attranno: attr.getAnnotations()){
								if(attranno.getName().equals("result")){
									foundresult=true;
									resultNode.resultAttrNames.add(attr.getName());
								}
								else
								{
									resultNode.otherAttrNames.add(attr.getName());
								}
							}
							
						}
						if(foundresult){
							resultNodes.add(resultNode);
							System.out.println(resultNode);
						}
					}
				}
			}
			//Search for calculating edges
			for(mgl.Edge edge: graphModel.getEdges()){
				CalculatingEdge ce = new CalculatingEdge();
				for(mgl.Annotation anno : edge.getAnnotations()){
					if(anno.getName().equals("calculating")){
						ce.name = edge.getName();
						calculatingEdges.add(ce);
						System.out.println(ce);
					}
				}
			}
			
			
			
			
			List<String> exportedPackages = new ArrayList<>();
			List<String> additionalNature = new ArrayList<>();
			String projectName = graphModel.getPackage() + pluginPath;
			packagePath = graphModel.getPackage()+"."+graphName.toLowerCase();
			List<IProject> referencedProjects = new ArrayList<>();
			
			//Create SRC-Folders
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			
			//Determines the symbolic name
			IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(new Path(graphModel.eResource().getURI().toPlatformString(true)));
			String symbolicName;
			if (res != null)
				symbolicName = ProjectCreator.getProjectSymbolicName(res.getProject());
			else symbolicName = graphModel.getPackage();
			
			//Sets required Bundles for the generated PlugIn-Project
			Set<String> requiredBundles = new HashSet<>();
			requiredBundles.add(symbolicName);
			requiredBundles.add("de.jabc.cinco.meta.libraries;bundle-version=\"0.6.0\"");
			requiredBundles.add("org.eclipse.ui");
			requiredBundles.add("org.eclipse.swt");
			requiredBundles.add("org.eclipse.core.runtime");
			requiredBundles.add("org.eclipse.core.resources");
			requiredBundles.add("org.eclipse.ui.navigator");
			requiredBundles.add("org.eclipse.emf.common");
			requiredBundles.add("org.eclipse.emf.ecore");
			requiredBundles.add("org.eclipse.graphiti.ui");
			requiredBundles.add("org.eclipse.ui.workbench");
			requiredBundles.add("de.jabc.cinco.meta.core.mgl.model");
			requiredBundles.add("org.eclipse.graphiti.mm");
			requiredBundles.add("org.eclipse.graphiti");
			requiredBundles.add("org.eclipse.emf.transaction");
			requiredBundles.add("org.eclipse.jface");
			requiredBundles.add("org.eclipse.core.expressions");
			
			//Overwrites the old generated code
			if(new Path("/"+projectName).toFile().exists())
				new Path("/"+projectName).toFile().delete();
			
			if(new Path("/"+projectName+"/ui").toFile().exists())
				new Path("/"+projectName+"/ui").toFile().delete();
			
			IProgressMonitor progressMonitor = new NullProgressMonitor();
			
			//Class names
			String genHandlerClass = "GenerationHandler";
			String calcHandlerClass = "CalculatingHandler";
			String openingHandlerClass = "OpeningHandler";
			
			
			//Generate pluginxml
			PluginXMLTemplate plugintemplate= new PluginXMLTemplate();
			String template = plugintemplate.createPlugin(projectName,genHandlerClass,calcHandlerClass,openingHandlerClass).toString();
			//Creates the Project
			IProject tvProject = ProjectCreator.createProject(projectName,
					srcFolders, referencedProjects, requiredBundles,
					exportedPackages, additionalNature, progressMonitor,false,template);
			String projectPath = tvProject.getLocation().makeAbsolute()
					.toPortableString();
			
			//Generate Classes
			//Handler
			ProjectCreator.createFile(genHandlerClass+".java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new GenerationHandlerTemplate().create(packagePath,projectName,genHandlerClass,sheetName,fileName,resultNodes,calculatingEdges,multiple).toString(),
					progressMonitor);
			
			ProjectCreator.createFile(calcHandlerClass+".java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new CalculationHandlerTemplate().create(packagePath,projectName,calcHandlerClass,sheetName,fileName,resultNodes,multiple).toString(),
					progressMonitor);
			
			ProjectCreator.createFile(openingHandlerClass+".java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new OpeningHandlerTemplate().create(packagePath,projectName,calcHandlerClass,sheetName,fileName,resultNodes).toString(),
					progressMonitor);
			
			//Exporter
			ProjectCreator.createFile("Spreadsheetexporter.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new ExporterTemplate().create(projectName,genHandlerClass,graphName,graphModel.getPackage(),fileName,sheetName,userCellx,userCellY).toString(),
					progressMonitor);
			
			//Importer
			ProjectCreator.createFile("Spreadsheetimporter.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new ImporterTemplate().create(projectName).toString(),
					progressMonitor);
			//Utils
			ProjectCreator.createFile("NodeUtil.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new NodeUtilTemplate().create(packagePath,projectName,resultNodes,calculatingEdges,allNodes,graphModel.getName()).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("SheetCalculator.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new SheetCalculatorTemplate().create(packagePath,projectName,resultNodes,calculatingEdges,allNodes,graphModel.getName()).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("VersionNode.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new VersionNodeTemplate().create(projectName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("NodeStatus.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new NodeStatusTemplate().create(projectName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("SheetHandler.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new SheetHandlerTemplate().create(projectName,multiple,sheetFolderName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("MenuPropertyTester.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new MenuPropertyTester().create(packagePath,projectName,resultNodes).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("VersionNodeComparator.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new VersionNodeComparator().create(projectName).toString(),
					progressMonitor);
			
			//Exceptions
			ProjectCreator.createFile("CalculationException.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new CalculationExceptionTemplate().create(projectName).toString(),
					progressMonitor);
			
			//UI
			ProjectCreator.createFile("UserInteraction.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new UserInteractionTemplate().create(projectName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("NewSheetDialog.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new NewSheetDialogTemplate().create(projectName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("SelectSheetDialog.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new SelectSheetDialogTemplate().create(projectName).toString(),
					progressMonitor);
			
			ProjectCreator.createFile("ResultNodeComparator.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
					new ResultNodeComparatorTemplate().create(projectName,resultNodes).toString(),
					progressMonitor);
			
			
			context.put("projectPath", projectPath);
			
			//Write the MANIFEST.MF
			File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
			BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
			
			bufwr.append("Bundle-ActivationPolicy: lazy\n");
			bufwr.flush();
			bufwr.close();
			
			
			tvProject.refreshLocal(IResource.DEPTH_INFINITE, null);
			
		}catch(Exception ex)
		{
			return "error";
		}
		return "default";
	}

}
