package de.jabc.cinco.meta.core.pluginregistry.validation

import java.util.List
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.AbstractDeclarativeValidator

abstract class AbstractMetaPluginValidator extends AbstractDeclarativeValidator {
	
	override List<EPackage> getEPackages() {
		newArrayList(EPackage.Registry.INSTANCE.getEPackage("http://www.jabc.de/cinco/meta/core/mgl"))
	}
	
	def applyResult(ValidationResult<String,EStructuralFeature> result) {
		switch it:result {
			ValidationResult.Error<String,EStructuralFeature>: error(message, feature)
			ValidationResult.Warning<String,EStructuralFeature>: warning(message, feature)
			ValidationResult.Info<String,EStructuralFeature>: info(message, feature)
		}
	}
}
