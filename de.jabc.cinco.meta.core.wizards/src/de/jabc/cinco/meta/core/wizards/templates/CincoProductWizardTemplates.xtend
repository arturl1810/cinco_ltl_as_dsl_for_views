package de.jabc.cinco.meta.core.wizards.templates

import de.jabc.cinco.meta.core.wizards.project.ExampleFeature
import java.util.Set

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.*
import java.util.Collections
import java.util.EnumSet

class CincoProductWizardTemplates {

	def static generateSomeGraphMGL(String modelName, String packageName) '''
@style("model/«modelName».style")
graphModel «modelName» {
	package «packageName»
	nsURI "http://cinco.scce.info/product/«modelName.toLowerCase»"
	diagramExtension "«modelName.toLowerCase»"
	
	@style(labeledCircle, "${label}")
	node SomeNode {
		incomingEdges (*)
		outgoingEdges (*)
		attr EString as label
	}	
	
	@style(simpleArrow)
	edge Transition { 
	}
}

	'''
	
	def static generateSomeGraphStyle() '''
appearance default {
	lineWidth 2
	background (229,229,229)
}

nodeStyle labeledCircle (1){
	ellipse {
		appearance default
		size(40,40)
		text {
			position ( CENTER, MIDDLE )
			value "%s"
		}
	}
}

edgeStyle simpleArrow {	
	appearance default
	
	decorator {
		location (1.0) // at the end of the edge
		ARROW
		appearance default 
	}
}

	'''
	
	def static generateSomeGraphCPD(String modelName, String packageName)'''
cincoProduct «modelName»Tool {
	mgl "model/«modelName».mgl"
}		
	'''
	
	
/*
 * 
 * 
 * 
 * HERE BEGINS PART OF THE FEATURE SHOWCASE EXAMPLES
 *  
 * 
 * 
 */

	def static generateFlowGraphCPD(String modelName, String packageName, Set<ExampleFeature> features)'''
cincoProduct «modelName»Tool {

	mgl "model/«modelName».mgl"

	«IF features.contains(PRODUCT_BRANDING)»
	splashScreen "branding/splash.bmp" {
		progressBar (37,268,190,10)
		progressMessage (37,280,190,18)
	}

	image16 "branding/Icon16.png"
	image32 "branding/Icon32.png"
	image48 "branding/Icon48.png"
	image64 "branding/Icon64.png"
	image128 "branding/Icon128.png"

	about {
		text "This is the example project for the Cinco SCCE Meta Tooling Suite ( http://cinco.scce.info ) that serves as a feature showcase. It is generated using the 'New CincoProduct' wizard"
	}
	«ENDIF»
	
	«IF features.contains(PRIME_REFERENCES)»
	plugins {
		info.scce.cinco.product.flowgraph.edit,
		info.scce.cinco.product.flowgraph.editor
	}
	«ENDIF»
	
}		
	'''
	
	def static generateFlowGraphMGL(String modelName, String packageName, String projectName, Set<ExampleFeature> features) '''
«IF features.contains(PRIME_REFERENCES)»
import "platform:/resource/«projectName»/model/ExternalLibrary.ecore" as externalLibrary
«ENDIF»
	
@style("model/«modelName».style")
«IF features.contains(PRIME_REFERENCES)»
@primeviewer
«ENDIF»
«IF features.contains(CODE_GENERATOR)»
@generatable("«packageName».codegen.Generate","/src-gen/")
«ENDIF»
«IF features.contains(TRANSFORMATION_API)»
@postCreate("«packageName».hooks.InitializeFlowGraphModel")
«ENDIF»
graphModel «modelName» {
	package «packageName»
	nsURI "http://cinco.scce.info/product/«modelName.toLowerCase»"
	«IF features.contains(ICONS)»
	iconPath "icons/FlowGraph.png"
	«ENDIF»
	diagramExtension "«modelName.toLowerCase»"
	
	attr EString as modelName
	
	@style(greenCircle)
	«IF features.contains(CUSTOM_ACTION)»
	@contextMenuAction("«packageName».action.ShortestPathToEnd")
	@doubleClickAction("«packageName».action.ShortestPathToEnd")
	«ENDIF»
	«IF features.contains(ICONS)»
	@icon("icons/Start.png")
	«ENDIF»
	«IF features.contains(PALETTE_GROUPS)»
	@palette("Round Elements")
	«ENDIF»
	node Start {
		// allow exactly one outgoing Transition
		outgoingEdges (Transition[1,1]) 
	}	
	
	@style(redCircle) 
	«IF features.contains(ICONS)»
	@icon("icons/End.png")
	«ENDIF»
	«IF features.contains(PALETTE_GROUPS)»
	@palette("Round Elements")
	«ENDIF»
	node End{
		/*
		
		allow an arbitrary number (>0) of incoming edges
		
		the following would have been valid as well, meaning the same:		  
		  incomingEdges (*[1,*])
		
		*/
		incomingEdges ({Transition,LabeledTransition}[1,*])
	}
	
	// use the "blueTextRectangle" as style and pass the attribute "text" as parameter
	@style(blueTextRectangle, "${name}")
	«IF features.contains(ICONS)»
	@icon("icons/Activity.png")
	«ENDIF»
	«IF features.contains(PALETTE_GROUPS)»
	@palette("Rectangular Elements")
	«ENDIF»
	«IF features.contains(POST_CREATE_HOOKS)»
	@postCreate("«packageName».hooks.RandomActivityName")
	«ENDIF»
	node Activity {		
		attr EString as name
		attr EString as description
		incomingEdges (*[1,*])
		outgoingEdges (LabeledTransition[1,*])
	}
	
	«IF features.contains(PRIME_REFERENCES)»
	@style(greenTextRectangle, "${activity.name}")
	node ExternalActivity {
		@pvLabel(name)
		@pvFileExtension("elib")
		prime externalLibrary.ExternalActivity as activity
		incomingEdges (*[1,*])
		outgoingEdges (LabeledTransition[1,*])			
	}
	
	@style(greenTextRectangle, "${subFlowGraph.modelName}")
	node SubFlowGraph {
		prime this::FlowGraph as subFlowGraph
		incomingEdges (*[1,*])
		outgoingEdges (LabeledTransition[1,*])
	}
	«ENDIF»
	
	«IF features.contains(CONTAINERS)»
	@style(swimlane, "${actor}")
	«IF features.contains(ICONS)»
	@icon("icons/Swimlane.png")
	«ENDIF»
	«IF features.contains(PALETTE_GROUPS)»
	@palette("Rectangular Elements")
	«ENDIF»
	container Swimlane {
		attr EString as actor	
		«IF features.contains(PRIME_REFERENCES)»
			containableElements (Start[1,1], Activity, End, ExternalActivity, SubFlowGraph)
		«ELSE»
			containableElements (Start[1,1], Activity, End)
		«ENDIF»
	}
	«ENDIF»
	
	@style(simpleArrow)
	edge Transition { 
	}
	
	@style(labeledArrow, "${label}")
	edge LabeledTransition {
		attr EString as label
	}
}

	'''
	

	def static generateFlowGraphStyle(String packageName, Set<ExampleFeature> features) '''
appearance default {
	lineWidth 2
	background (144,207,238)
}

appearance redBorder extends default {
			foreground (164,29,29)
			background (255,255,255)
} 

nodeStyle redCircle {
	ellipse {
		appearance redBorder
		size(36,36)
		ellipse { 
			appearance redBorder
			position ( CENTER, MIDDLE )
			size (24,24)
		}
	}
}

nodeStyle greenCircle {
	ellipse {
		appearance extends default {
			foreground (81,156,88)
			background (255,255,255)
		} 
		size(36,36)
	}
}

nodeStyle blueTextRectangle(1) {
	roundedRectangle {
		appearance default
		position (0,0)
		size (96,32)
		corner (8,8)
		text {
			position ( CENTER, MIDDLE )
			value "%s" 
		}
	}
}

«IF features.contains(PRIME_REFERENCES)»
nodeStyle greenTextRectangle(1) {
	roundedRectangle {
		appearance extends default {
			background (101,175,95)
		}
		position (0,0)
		size (96,32)
		corner (8,8)
		text {
			position ( CENTER, MIDDLE )
			value "%s" 
		}
	}
}
«ENDIF»

«IF features.contains(CONTAINERS)»
nodeStyle swimlane(1) {
	rectangle {
		appearance {
			background (255,236,202)
		}
		size (400,100)
		text {
			position (10,10)
			value "%s"
		}	
	}
}
«ENDIF»

edgeStyle simpleArrow {	
	«IF features.contains(APPEARANCE_PROVIDER)»
	appearanceProvider ( "«packageName».appearance.SimpleArrowAppearance" ) 
	«ELSE»
	appearance default
	«ENDIF»
	
	decorator {
		location (1.0) // at the end of the edge
		ARROW
		appearance default 
	}
}

edgeStyle labeledArrow(1) {	
	appearance default
	decorator {
		location (1.0)
		ARROW
		appearance default
	}
	decorator {
		location (0.3)
		movable
		text {
			value "%s"
		}
	}
}
	'''
	
	def static generateAppearanceProvider(String modelName, String packageName) '''
package «packageName».appearance;

import style.Appearance;
import style.LineStyle;
import style.StyleFactory;
import de.jabc.cinco.meta.core.ge.style.model.appearance.StyleAppearanceProvider;
import «packageName».«modelName.toLowerCase».End;
import «packageName».«modelName.toLowerCase».Transition;

/**
 * This class implements a dynamic appearance for the simpleArrow style. 
 * It simply sets the lineStyle to DASH in case the target node is of 
 * the type End.
 *
 */
public class SimpleArrowAppearance implements StyleAppearanceProvider<Transition> {

	@Override
	public Appearance getAppearance(Transition transition, String element) {
		// element can be ignored here, as there are no named inner elements in the simpleArrow style
		Appearance appearance = StyleFactory.eINSTANCE.createAppearance();
		appearance.setLineWidth(2);
		if (transition.getTargetElement() instanceof End)
			appearance.setLineStyle(LineStyle.DASH);
		else
			appearance.setLineStyle(LineStyle.SOLID);
		return appearance;
	}

}
	
	
	'''
	
	def static generateXtendCodeGenerator(String modelName, String packageName) '''

package «packageName».codegen

import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator
import «packageName».«modelName.toLowerCase».«modelName»
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.resources.ResourcesPlugin
import de.jabc.cinco.meta.core.utils.EclipseFileUtils

/**
 *  Example class that generates code for a given FlowGraph model. As different
 *  feature examples might or might not be included (e.g. the external component
 *  library or swimlanes), this generator only does stupidly enumerate all
 *  nodes and prints some general information about them.
 *
 */
class Generate implements IGenerator<«modelName»> {
	
	override generate(«modelName» model, IPath targetDir, IProgressMonitor monitor) {

		if (model.modelName.nullOrEmpty)
			throw new RuntimeException("Model's name must be set.")

		val code = generateCode(model);
		val targetFile = ResourcesPlugin.workspace.root.getFileForLocation(targetDir.append(model.modelName + ".txt"))

		EclipseFileUtils.writeToFile(targetFile, code)

	}

	private def generateCode(«modelName» model) «"'''"»
		=== «"«"»model.modelName«"»"» ===
		
		The model contains «"«"»model.allNodes.size«"»"» nodes. Here's some general information about them:
		
		«"«"»FOR node : model.allNodes«"»"»
			* node «"«"»node.id«"»"» of type '«"«"»node.eClass.name«"»"»' with «"«"»node.successors.size» successors and «"«"»node.predecessors.size«"»"» predecessors
		«"«"»ENDFOR«"»"»
	«"'''"»

}
	
	'''
	
	def static generateCodeGenerator(String modelName, String packageName) '''
package «packageName».codegen;

import graphmodel.ModelElement;
import «packageName».«modelName.toLowerCase».«modelName»;
import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;

/**
 *  Example class that generates code for a given FlowGraph model. As different
 *  feature examples might or might not be included (e.g. the external component
 *  library or swimlanes), this generator only does stupidly enumerate all
 *  model elements that are directly contained in the root model.
 *
 */
public class Generate implements IGenerator<«modelName»> {
	
	public void generate(«modelName» model, IPath targetDir, IProgressMonitor monitor) {
		String modelName = model.getModelName();
		if (modelName == null || modelName.isEmpty()) {
			throw new RuntimeException("Model's name is not set.");
		}
		CharSequence code = generate(model);
		File outputFile = targetDir.append(modelName + ".txt").toFile();
		writeFile(outputFile, code);
	}

	private CharSequence generate(«modelName» model) {
		String newline = System.lineSeparator();
		StringBuilder sb = new StringBuilder();

		sb.append("=== ")
			.append(model.getModelName())
			.append(" ===")
			.append(newline);

		for (ModelElement e : model.getModelElements()) {
			sb.append(e.eClass().getName())
				.append(newline);
		}

		return sb;
	}

	private void writeFile(File f, CharSequence code) {
		try (BufferedWriter writer = new BufferedWriter(new FileWriter(f))) {
			writer.append(code);
		} 
		catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
	
}
	'''
	
	def static generateCustomAction(String modelName, String packageName) '''
package «packageName».action;

import graphmodel.Node;
import «packageName».«modelName.toLowerCase».End;
import «packageName».«modelName.toLowerCase».Start;

import org.eclipse.jface.dialogs.MessageDialog;

import de.jabc.cinco.meta.runtime.action.CincoCustomAction;

public class ShortestPathToEnd extends CincoCustomAction<Start> {
	
	@Override
	public String getName() {
		return "Calculate Distance to End";
	}

	@Override
	/**
	 * @return always <code>true</code>, as the action can
	 * 		be executed for any Start node.
	 */
	public boolean canExecute(Start start) {
		return true;
	}

	@Override
	public void execute(Start start) {
		int length = getShortest(start, 100);
		String message = 
			length >= 0
				? String.format("The shortest End node is %d steps away.", length)
				: "No End node could be found within the search range.";
		MessageDialog.openInformation(null, "Shortest Path Search Result", message);
	}
	
	/**
	 * Find the shortest distance to a node of type {@link End}
	 * 
	 * @param node 
	 * 		The node to search from.
	 * @param maxSearchDepth 
	 * 		poor man's solution to prevent endless recursion ;)
	 * @return 
	 * 		The nearest distance to an End node or 0 if node is an End node 
	 * 		or some value < 0 in case no End node is within the range of maxSearchDepth
	 */
	private int getShortest(Node node, int maxSearchDepth) {
		if (node instanceof End)
			return 0;
		if (maxSearchDepth == 0)
			return Integer.MIN_VALUE;
		int shortestPath = Integer.MAX_VALUE;
		for (Node successor : node.getSuccessors(Node.class)) {
			int	currentSuccDistance = getShortest(successor, maxSearchDepth -1); 
			if (currentSuccDistance < shortestPath && currentSuccDistance >= 0)
				shortestPath = currentSuccDistance;
		}
		return shortestPath + 1;
	}

}	
	'''
	
	def static generatePrimeRefEcore(String modelName, String packageName) '''
<?xml version="1.0" encoding="UTF-8"?>
<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="externalLibrary" nsURI="http://cinco.scce.info/product/flowgraph/externalLibrary"
    nsPrefix="el">
  <eClassifiers xsi:type="ecore:EClass" name="ExternalActivityLibrary">
    <eStructuralFeatures xsi:type="ecore:EReference" name="activities" upperBound="-1"
        eType="#//ExternalActivity" containment="true"/>
  </eClassifiers>
  <eClassifiers xsi:type="ecore:EClass" name="ExternalActivity">
    <eStructuralFeatures xsi:type="ecore:EAttribute" name="name" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString" iD="true" />
    <eStructuralFeatures xsi:type="ecore:EAttribute" name="description" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
  </eClassifiers>
</ecore:EPackage>
	'''
	
	def static generatePrimeRefGenmodel(String modelName, String packageName, String projectName, String projectID) '''
<?xml version="1.0" encoding="UTF-8"?>
<genmodel:GenModel xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
    xmlns:genmodel="http://www.eclipse.org/emf/2002/GenModel" modelDirectory="/«projectName»/elib-src-gen" editDirectory="/«projectName».edit/src-gen"
    editorDirectory="/«projectName».editor/src-gen" modelPluginID="«projectID»"
    modelName="ExternalLibrary" rootExtendsClass="org.eclipse.emf.ecore.impl.MinimalEObjectImpl$Container"
    testsDirectory="/«projectName».tests/src-gen" importerID="org.eclipse.emf.importer.ecore"
    complianceLevel="7.0" copyrightFields="false" editPluginID="«projectID».edit"
    editorPluginID="«projectID».editor" language="" operationReflection="true"
    importOrganizing="true">
  <foreignModel>ExternalLibrary.ecore</foreignModel>
  <genPackages prefix="ExternalLibrary" basePackage="«packageName»"
      disposableProviderFactory="true" fileExtensions="elib" ecorePackage="ExternalLibrary.ecore#/">
    <genClasses ecoreClass="ExternalLibrary.ecore#//ExternalActivityLibrary">
      <genFeatures property="None" children="true" createChild="true" ecoreFeature="ecore:EReference ExternalLibrary.ecore#//ExternalActivityLibrary/activities"/>
    </genClasses>
    <genClasses ecoreClass="ExternalLibrary.ecore#//ExternalActivity">
      <genFeatures createChild="false" ecoreFeature="ecore:EAttribute ExternalLibrary.ecore#//ExternalActivity/name"/>
      <genFeatures createChild="false" ecoreFeature="ecore:EAttribute ExternalLibrary.ecore#//ExternalActivity/description"/>
    </genClasses>
  </genPackages>
</genmodel:GenModel>
	'''
	
	def static generateRandomActivityNameHook(String modelName, String packageName) '''
package «packageName».hooks;

import «packageName».«modelName.toLowerCase».Activity;

import java.util.Random;

import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook;

/**
 * Example post-create hook that randomly sets the name of the activity. Possible
 * names are inspired by the action verbs of old-school point&click adventure games :)
 */
public class RandomActivityName extends CincoPostCreateHook<Activity> {

	@Override
	public void postCreate(Activity activity) {
		
		String[] names = new String[] {
	            "Close",
	            "Fix",
	            "Give",
	            "Look at",
	            "Open",
	            "Pick up",
	            "Pull",
	            "Push",
	            "Put on",
	            "Read",
	            "Take off",
	            "Talk to",
	            "Turn off",
	            "Turn on",
	            "Unlock",
	            "Use",
	            "Walk to"
		};
		
		int randomIndex = new Random().nextInt(names.length);

		activity.setName(names[randomIndex]);

	}
	
}

	'''
	
	def static generateInitFlowGraphHook(String modelName, String packageName) '''
package «packageName».hooks;

import «packageName».api.cflowgraph.CActivity;
import «packageName».api.cflowgraph.CEnd;
import «packageName».api.cflowgraph.CFlowGraph;
import «packageName».api.cflowgraph.CLabeledTransition;
import «packageName».api.cflowgraph.CStart;
import «packageName».«modelName.toLowerCase».FlowGraph;
import «packageName».graphiti.FlowGraphWrapper;
import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook;

/**
 *  This post-create hook is part of the transformation API feature showcase. As it is defined
 *  for the root model FlowGraph, it will be called by the "New FlowGraph" wizard after creating
 *  the empty model.
 *  
 *  It will just insert a Start node, an Activity, and an End node to every newly created model.
 *
 */
public class InitializeFlowGraphModel extends CincoPostCreateHook<FlowGraph> {

	@Override
	public void postCreate(FlowGraph flowGraph) {
		try {
			// Initialize the API by wrapping the given FlowGraph model and the Diagram into one CFlowGraph
			CFlowGraph cFlowGraph = FlowGraphWrapper.wrapGraphModel(flowGraph, getDiagram());
			
			// Create the three nodes
			CStart start = cFlowGraph.newCStart(50, 50);
			CActivity activity = cFlowGraph.newCActivity(150, 50);
			CEnd end = cFlowGraph.newCEnd(310, 50);
			
			// Connect the nodes with edges
			start.newCTransition(activity);
			CLabeledTransition labeledTransition = activity.newCLabeledTransition(end);
			labeledTransition.setLabel("success");

		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
}

	'''
	
	def static generateReadme(String modelName, String packageName, String projectName, Set<ExampleFeature> features) '''
	= README =
	
	This is dynamically generated documentation for the Cinco FlowGraph example project with features
	selected during project setup.

	
	== Getting Started ==
	
			«IF features.contains(PRIME_REFERENCES)»
			                            ┌─────────────────┐
			                            │ /!\ CAUTION /!\ │
			                            └─────────────────┘
			You selected the "prime references" feature. Prior to product generation, 
			you need to build the ExternalLibrary: open model/ExternalLibrary.genmodel,
			right-click on the root node in the opened editor, and select 'Generate All'
			from the context menu. See the "Additional Features" section below for more
			information.

			«ENDIF»
	«IF !Collections.disjoint(features,EnumSet.of(APPEARANCE_PROVIDER, CODE_GENERATOR, CUSTOM_ACTION, POST_CREATE_HOOKS, TRANSFORMATION_API))»
	Please note: You selected one or more features that produced Java source files. As they depend on classes
	generated from the MGL, the project will report build errors (indicated by the red X marker) until you
	generate the Cinco Product.

	«ENDIF»
	Generate your Cinco Product: right-click on /«packageName»/model/«modelName»Tool.cpd and
	select 'Generate Cinco Product'
	
	Start your generated Cinco Product: right-click on /«packageName» and
	select 'Run as > Eclipse Application'.
	
	Before you can start modeling, you need to create a project: right-click in the Project Explorer and
	select 'New > New FlowGraphTool Project', give the project a name and click 'Finish'.
	
	Now start a first FlowGraph model: right-click on your created project and select 'New > New FlowGraph'.
	
	See below for details on the available modeling elements and effects of additional features selected
	during project initialization.


	== General Features ==
	
	Basic FlowGraph models consist of three types of nodes and two types of edges:
	
	* 'Start' nodes are shown as a green circle and can may have exactly one outgoing 'Transition'
	
	* 'Activity' nodes have attributes 'name' and 'description' and are shown as a blue rectangle
	  showing the name.  They can have multiple outgoing 'LabeledTransition' edges, and multiple incoming
	  edges of arbitrary type.
	
	* 'End' nodes are shown as a red double circle and can have multiple incoming edges of arbitrary type.
	

	== Additional Features ==	
	«IF (features.empty)»
		You have not selected any additional features during project initialization.
	«ELSE»
		«IF features.contains(CONTAINERS)»

			=== Containers ===
			
			Containers are special nodes that can again hold other nodes (and containers). This selected feature adds
			'Swimlane' containers to the FlowGraph example. The containableElements constraint defines what kind of
			nodes (and how many of them) can be contained: Exactly one 'Start' node and arbitrary many of the other
			node types, but no 'Swimlane' containers. The 'actor' attribute is displayed in the top left corner
			of the swimlane.

		«ENDIF»
		«IF features.contains(ICONS)»

			=== Icons ===
			
			This selected feature adds icons to the nodes (displayed in the palette), as well as to the FlowGraph
			model type itself (used as file icon and in the editor tab). The images (png files) are located in the
			icons folder of the project. They are referenced with the @icon(...) annotation (on nodes) and the iconPath
			keyword on the graphModel.

		«ENDIF»
		«IF features.contains(APPEARANCE_PROVIDER)»

			=== Appearance Provider ===
			
			Appearances define basic visual properties within the style language, like colors, line widths, line styles
			fonts, etc. The selected feature makes use of an appearance provider, which can determine these values
			dynamically at runtime. The Java class implementing this behavior is referenced in the edgeStyle/nodeStyle.
			For the FlowGraph example, the appearance provider is used on the 'simpleArrow' style, which is used
			by the 'Transition' node defined in the MGL. It will set a dashed line style, if the target node
			of the edge is of type 'End', and a solid one in all other cases. Thus, if a 'Start' node is directly
			connected with an 'End' node, the connecting edge will be rendered with a dashed line style.

		«ENDIF»
		«IF features.contains(CUSTOM_ACTION)»

			=== Custom Action ===
			
			Cinco's custom actions allow one to execute arbitrary code based on the selected element. This includes
			analyzing the model, transforming the model, code generation, etc. Currently, the action can be added to
			the element in the MGL with two possible annotations: @contextMenuAction(...) and @doubleClickAction(...).
			While the first appears in the menu for the user to choose when right-clicking on the element, the second
			one is automatically executed on double-clicking the element. In the FlowGraph example, a custom action
			is added to the 'Start' node. It searches for the shortest path to an 'End' node and displays the number
			of required steps in a dialog window.

		«ENDIF»
		«IF features.contains(CODE_GENERATOR)»

			=== Code Generator ===
			
			The example code generator is implemented in Xtend, as it is compatible with Java (it actually generates
			.java files from .xtend files), but provides several syntactic ehancements and has built-in support for
			templates. See https://eclipse.org/xtend/documentation/ for more information on Xtend.
			Code generators are usually very specific to the target domain, and there is no meaningful execution semantics
			for our	FlowGraph model. So, the example code generator only enumerates all nodes of the model and prints
			some general information about them.

		«ENDIF»
		«IF features.contains(PRIME_REFERENCES)»

			=== Prime References ===
			
			Cinco's 'prime references' are a mechanism to represent (parts of) other models as nodes within the currently
			edited model, which allows for interconnected models in a cleanly structured way. The underlying idea is that
			the referenced model is drag&dropped 'as a component' into the modeling canvas, resulting in the instantiation
			of the according prime referencing node. The FlowGraph example utilizes this feature in two ways:
			
			1) Sub-Models
			A node type 'SubFlowGraph' is added that represents a whole other flow graph as a green rectangle node. It is
			created by drag&dropping a .flowgraph file directly from the project explorer to the canvas. As this is the
			only valid way of creating this kind of node, it is not listed in the palette like regular node types.
			
			2) External Library
			The second example provides integration of an external library defined with a separate Ecore metamodel, which
			needs to be generated to Java prior to Cinco building the modeling tool (see CAUTION notice above). As this
			integration crosses the boundaries of Cinco, we rely on the model editor automatically generated by the EMF
			framework. To create an external library in your running Cinco Product, right-click in the project explorer
			and select 'New > Other ... > Example EMF Model Creation Wizards > ExternalLibrary Model', give it a name
			and choose 'External Activity Library' as Model Object. Then, open the file, expand the root node and select
			'New Child > External Activity' from the context menu of the 'External Activity Library'. To modify the 'name'
			and 'description' attributes of the external activities, you need Eclipse's property view. Click on any
			element within your .elib file and select 'Show Properties View'. Of course, if the external library were
			defined with Cinco (i.e. a second MGL file), this whole handling would have been simplified. Now, to actually
			use the external activities, refresh the project in the project explorer, expand your .elib file and drag&drop
			the activities into a FlowGraph model. This .elib file expansion is provided by the 'primeviewer' meta plug-in
			of Cinco, which is activated by adding the @primeviewer annotation to the graphModel. The @pvFileExtension(...)
			annotation on the prime reference defines in which files the plug-in has to search for according objects, and
			the @pvLabel(...) annotation defines an attribute of the referenced class that is displayed as a label in the
			expanded .elib file.
			
			Please note: The 'prime' keyword defines a node as a prime reference node. It is used like 'attr' on the one
			prime referencing attribute. In the example, this attribute's type is given as 'externalLibrary.ExternalActivity'
			for the 'ExternalActivity' and as 'this::FlowGraph' for the 'SubFlowGraph'. The latter covers the special case
			of referencing an element type from the same MGL file. If a model or node type from a different MGL shall be
			referenced, an according import statement needs to be added at the top of the MGL and the there given name
			needs to be used instead of 'this'. Generally, references to Ecore types is done with '.' and references to
			MGL types is done with '::'.

		«ENDIF»
		«IF features.contains(POST_CREATE_HOOKS)»

			=== Post-Create Hooks ===
			
			Hooks are used to execute arbitrary code (e.g. analyzing/transforming the model) before or after certain events
			on elements occur. Currently, four different events are available, which are referenced with according annotations:
			@postCreate(...), @postMove(...), @postResize(...), and @preDelete(...). The post-create hook generated with this
			FlowGraph example is bound to the 'Activity' node type and randomly sets the name when a new activity is created.

		«ENDIF»
		«IF features.contains(PALETTE_GROUPS)»

			=== Palette Groups ===
			
			By default, all node types are displayed in the palette in a general group named "Nodes". This selected feature 
			adds the @palette(...) annotation to all node types, either with "Round Elements" or "Rectangular Elements" as
			name for the group.

		«ENDIF»
		«IF features.contains(TRANSFORMATION_API)»

			=== Transformation API ===
			
			The Cinco Transformation API (C-API) is automatically generated for every Cinco product. It wraps the actual model
			types as defined in the MGL and the graphical representation into one easy-to-use API. Every model element has an
			according C-prefixed type, i.e. CFlowGraph, CStart, CActivity, etc. on which one can perform programmatically (e.g.
			within custom actions, hooks, or even code generators) everything that the modeling tool user can do by clicking
			within the running tool. This includes adding, moving, resizing, and deleting nodes, connecting, reconnecting and
			deleting edges, setting attributes, etc.

			This selected feature adds a post-create hook to the FlowGraph model itself. It is triggered by the "New FlowGraph"
			wizard after creating the model. It initializes the model with a 'Start' node, an 'Activity' node, and an 'End' node.

			«IF features.contains(POST_CREATE_HOOKS)»
				Please note: You also selected the "Post-create hooks" feature during project initialization. So, the added 'Activity'
				node will also contain a random value for the 'name' attribute, as its post-create hook will also trigger when a new
				node is created via the C-API.
			«ELSE»
				Please note: If you would have selected the "Post-create hooks" feature during project initialization, the according
				hook of the 'Activity' node would also trigger when a new node is created via the C-API.
			«ENDIF»

		«ENDIF»
		«IF features.contains(PRODUCT_BRANDING)»

			=== Product Branding ===	
			
			At some point, a Cinco Product needs to be given to modeling users, which requires a standalone installer, as those
			users should not need to install Cinco, Generate the product and start it from within Cinco. The branding feature
			adds some additional information and images to the CPD file, which are displayed when the standalone product is
			started. This includes a splash screen, icons, and an about text. For information on how to actually export a Cinco
			Product, see https://projekte.itmc.tu-dortmund.de/projects/cinco/wiki/Export_Product

		«ENDIF»
	«ENDIF»


	'''
	
	
	
	
	
}