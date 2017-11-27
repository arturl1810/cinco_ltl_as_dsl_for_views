package de.jabc.cinco.meta.core.utils.mwe2

import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.GeneratedMetamodel
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.xtext.generator.ecore.EMFGeneratorFragment2
import org.eclipse.emf.ecore.EAttribute

@Log class CustomEcoreEMFGeneratorFragment extends EMFGeneratorFragment2 {
	
	val idAttributeMap = <String,List<String>> newHashMap
	val globalAttributeNames = <String> newArrayList
	
	override generate() {
		grammar.metamodelDeclarations.filter(GeneratedMetamodel)
			.map[EPackage]
			.map[EClassifiers].flatten
			.filter(EClass)
			.map[cls | cls.EAttributes.filter[isRelevant(cls)]].flatten
			.forEach[
				LOG.info('''Flagging attribute '«name»' of EClass '«EContainingClass.name»' as ID-Attribute''')
				ID = true
			]
		super.generate
	}
	
	private def isRelevant(EAttribute attr, EClass cls) {
		globalAttributeNames.contains(attr.name)
			|| idAttributeMap.get(cls.name)?.contains(attr.name)
	}
	
	def addIdAttribute(IdAttributeDescriptor desc) {
		if (desc.className == null) {
			globalAttributeNames += desc.attributeName
		} else {
			val list = idAttributeMap.get(desc.className)
				?: newArrayList => [
					idAttributeMap.put(desc.className, it)
				]
			list += desc.attributeName
		}
	}
}

class IdAttributeDescriptor {
	@Accessors String className
	@Accessors String attributeName
}

