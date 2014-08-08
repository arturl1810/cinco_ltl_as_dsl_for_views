package de.jabc.cinco.meta.core.wizards.templates

class CincoProductWizardTemplates {
	
	def static generateMGLFile(String modelName, String packageName, String projectName) '''
	
@style("/«projectName»/model/«modelName».style")
graphModel «modelName» {
	package «packageName»
	nsURI "http://cinco.scce.info/products/«modelName»"
	diagramExtension "«modelName.toLowerCase»"

	@style(greenCircle)
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
	@style(blueTextRectangle, "${text}")
	node Inner {		
		attr EString as text
		incomingEdges (*[1,-1])
		outgoingEdges (LabeledTransition[1,-1])
	}	
	
	@style(simpleArrow)
	edge Transition { 
	}
	
	@style(labeledArrow, "${label}")
	edge LabeledTransition {
		attr EString as label
	}
}

	'''
	

	def static generateStyleFile(String packageName) '''
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


edgeStyle simpleArrow {	
	appearanceProvider ( "«packageName».appearance.SimpleArrowAppearance" ) 
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