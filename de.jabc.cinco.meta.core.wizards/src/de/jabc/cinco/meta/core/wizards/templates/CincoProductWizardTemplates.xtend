package de.jabc.cinco.meta.core.wizards.templates

import de.jabc.cinco.meta.core.wizards.project.ExampleFeature
import java.util.Set

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.*

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
cincoProduct «modelName»{
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
		containableElements (*)
		attr EString as actor	
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

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.jface.dialogs.MessageDialog;

import de.jabc.cinco.meta.core.ge.style.model.customfeature.CincoCustomAction;

public class ShortestPathToEnd extends CincoCustomAction<Start> {
	
	public ShortestPathToEnd(IFeatureProvider fp) {
		super(fp);
	}
	
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
    <eStructuralFeatures xsi:type="ecore:EAttribute" name="name" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
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

import de.jabc.cinco.meta.core.ge.style.model.customfeature.CincoPostCreateHook;

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
import de.jabc.cinco.meta.core.ge.style.model.customfeature.CincoPostCreateHook;

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
	Generated Documentation for Cinco feature showcase project «projectName»
	
	To generate your Cinco Product, right-click on «packageName»/model/«modelName».cpd and select 'Generate Cinco Product'
	
	«IF features.contains(PRIME_REFERENCES)»
		CAUTION: You selected the "prime references" feature. Prior to product generation, you need to build the ExternalLibrary
		code by opening «packageName»/model/ExternalLibrary.genmodel, right-clicking
		on the root node in the opened editor, and selecting 'Generate All' from the context menu.
	«ENDIF»	


	'''
	
	
	
	
	
}