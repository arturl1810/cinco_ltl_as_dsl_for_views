package de.jabc.cinco.meta.plugin.primeviewer.validation

import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator
import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult
import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import mgl.Annotation
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.ReferencedType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError

class PrimeViewerValidator implements IMetaPluginValidator {
	
	extension GraphModelExtension = new GraphModelExtension

	override checkAll(EObject eObject) {
		if (eObject instanceof Annotation) {
			val anno = eObject as Annotation
			switch anno.name {
				case "primeviewer": anno.checkPrimeviewer
				case "pvLabel": anno.checkPvLabel
				case "pvFileExtension": anno.checkPvFileExtension
			}
		}
	}
	
	def ValidationResult<String, EStructuralFeature> checkPrimeviewer(Annotation anno) {
		/* do nothing */
	}

	def ValidationResult<String, EStructuralFeature> checkPvLabel(Annotation anno) {
		if (anno.value?.size != 1) newError(
			'''provide exactly one valid attribute as label, e.g. pvLabel(name)''',
			anno.eClass.getEStructuralFeature("name"))
			
		else if (anno.parent instanceof ReferencedType) {
			val attrName = anno.value.head
			val refType = anno.parent as ReferencedType
			val valid = switch it:refType {
				ReferencedEClass: type.getEStructuralFeature(attrName) != null
				ReferencedModelElement: type.allAttributes.map[name].exists[it == attrName]
			}
			if (!valid) newError(
				'''«attrName» is not a valid attribute of the referenced type «refType.name»''',
				anno.eClass.getEStructuralFeature("value"))
		}
	}

	def ValidationResult<String, EStructuralFeature> checkPvFileExtension(Annotation anno) {
		if (anno.value?.size != 1) newError(
			'''provide exactly one file extension, e.g. pvFileExtension("value")''',
			anno.eClass.getEStructuralFeature("name"))
	}

	
}
