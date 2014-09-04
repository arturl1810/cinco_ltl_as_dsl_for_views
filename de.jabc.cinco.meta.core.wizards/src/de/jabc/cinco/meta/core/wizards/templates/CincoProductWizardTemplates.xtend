package de.jabc.cinco.meta.core.wizards.templates

import de.jabc.cinco.meta.core.wizards.project.ExampleFeature
import java.util.Set

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.*

class CincoProductWizardTemplates {
	
	def static generateMGLFile(String modelName, String packageName, String projectName, Set<ExampleFeature> features) '''
	
«IF features.contains(PRIME_REFERENCES)»
import "platform:/resource/«packageName»/model/ExternalLibrary.ecore"
«ENDIF»
	
@style("model/«modelName».style")
«IF features.contains(PRIME_REFERENCES)»
@primeviewer
«ENDIF»
«IF features.contains(CODE_GENERATOR)»
@generatable("«packageName»", "«packageName».codegen.Generate","/src-gen/")
«ENDIF»
graphModel «modelName» {
	package «packageName»
	nsURI "http://cinco.scce.info/product/«modelName.toLowerCase»"
	diagramExtension "«modelName.toLowerCase»"
	
	attr EString as modelName
	
	@style(greenCircle)
	«IF features.contains(CUSTOM_ACTION)»
	@contextMenuAction("«packageName».action.ShortestPathToEnd")
	@doubleClickAction("«packageName».action.ShortestPathToEnd")
	«ENDIF»
	node Start {
		// allow exactly one outgoing Transition
		outgoingEdges (Transition[1,1]) 
	}	
	
	@style(redCircle) 
	node End{
		// allow an arbitrary number (>0) of incoming edges
		//
		// the following would have been valid as well, meaning the same:
		// incomingEdges (*[1,-1])
		incomingEdges ({Transition,LabeledTransition}[1,-1])
	}
	
	// use the "blueTextRectangle" as style and pass the attribute "text" as parameter
	@style(blueTextRectangle, "${name}")
	node Activity {		
		attr EString as name
		attr EString as description
		incomingEdges (*[1,-1])
		outgoingEdges (LabeledTransition[1,-1])
	}	
	
	«IF features.contains(PRIME_REFERENCES)»
	@style(greenTextRectangle, "${activity.name}")
	node ExternalActivity {
		@pvLabel(name)
		@pvFileExtension("externallibrary")
		prime externalLibrary.ExternalActivity as activity
		incomingEdges (*[1,-1])
		outgoingEdges (LabeledTransition[1,-1])			
	}
	«ENDIF»
	
	«IF features.contains(CONTAINERS)»
	@style(swimlane, "${actor}")
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
	

	def static generateStyleFile(String packageName, Set<ExampleFeature> features) '''
appearance default {
	lineWidth 2
	background (144,207,238)
}

appearance redBorder extends default {
			foreground (164,29,29)
			background (255,255,255)
} 

nodeStyle redCircle {
	ellipse	outer {
		appearance redBorder
		size(36,36)
		ellipse { 
			appearance redBorder
			position relativeTo outer ( CENTER, MIDDLE )
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

nodeStyle blueTextRectangle {
	roundedRectangle rec {
		appearance default
		position (0,0)
		size (96,32)
		corner (8,8)
		text {
			position relativeTo rec ( CENTER, MIDDLE )
			value "%s" 
		}
	}
}

«IF features.contains(PRIME_REFERENCES)»
nodeStyle greenTextRectangle {
	roundedRectangle rec {
		appearance extends default {
			background (101,175,95)
		}
		position (0,0)
		size (96,32)
		corner (8,8)
		text {
			position relativeTo rec ( CENTER, MIDDLE )
			value "%s" 
		}
	}
}
«ENDIF»

«IF features.contains(CONTAINERS)»
nodeStyle swimlane {
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

edgeStyle labeledArrow {	
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
	
}