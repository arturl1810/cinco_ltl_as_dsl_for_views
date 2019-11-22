package de.jabc.cinco.meta.plugin.cpdpreprocessor

import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin
import java.util.Set
import mgl.GraphModel
import mgl.ModelElement
import org.eclipse.core.resources.IProject
import productDefinition.CincoProduct
import mgl.MglFactory
import productDefinition.Annotation

class CPDPreprocessorPlugin implements ICPDMetaPlugin {
	new() {}

	override void execute(Annotation anno, Set<GraphModel> mglList, CincoProduct product, IProject project) {
		val prepAnnot = product.annotations.filter[name == "preprocessor"].head
		if(prepAnnot === null) return;
		
		val mode = prepAnnot.value.head

		mglList.forEach[
			(nodes + edges + types).map[annotations].flatten.filter[name == "preprocess"].map[
				if(value.head == mode) {
					println('''AAAAAAAAAAAAAAAAAAAAAAAAAA «(parent as ModelElement).name»: «value.get(1)»''')
					val newAnnotation = MglFactory.eINSTANCE.createAnnotation()
					newAnnotation.name = value.get(1)
					value.subList(2, value.size).forEach[
						newAnnotation.value.add(it)
					]
					parent -> newAnnotation
				}
			].toSet().filter[it != null].forEach[ newAnnotationPair |
				newAnnotationPair.key.annotations.add(newAnnotationPair.value)
			]
		]
	}
}
