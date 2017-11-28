package de.jabc.cinco.meta.plugin.primeviewer.contentassist

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor
import mgl.Annotation
import mgl.ReferencedEClass
import mgl.ReferencedModelElement

class PrimeViewerProposalProvider implements IMetaPluginAcceptor {
	
	override getAcceptedStrings(Annotation annotation) {
		if (annotation.name == "pvLabel") {
			switch it:annotation.parent {
				ReferencedEClass: type.getEAllStructuralFeatures.map[name]
				ReferencedModelElement: type.attributes.map[name]
			}
		}
	}

	override getTextApplier(Annotation annotation) {
		null
	}
}
