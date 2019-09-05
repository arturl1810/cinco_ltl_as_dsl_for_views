package de.jabc.cinco.meta.plugin.modelchecking.provider

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor
import mgl.Annotation
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FulfillmentConstraint

class ModelCheckingProposalProvider implements IMetaPluginAcceptor{
	
	override getAcceptedStrings(Annotation annotation) {
		switch (annotation.name){
			case "mcDefault", case "mc": return #["include","exclude"]
			case "mcHighlightColor": return #["\"Color.RED\"", "\"Color.BLUE\"", "\"Color.BLACK\"", 
									"\"Color.CYAN\"", "\"Color.GRAY\"", "\"Color.ORANGE\"", "\"Color.WHITE\"", "\"Color.YELLOW\""]
			case "mcFulfillmentConstraint": return FulfillmentConstraint.values.map[toString]
			default : return #[]
		}
	}
	
	override getTextApplier(Annotation annotation) {
		null
	}
}