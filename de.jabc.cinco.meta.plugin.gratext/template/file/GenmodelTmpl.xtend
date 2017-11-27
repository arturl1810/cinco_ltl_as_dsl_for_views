package file

class GenmodelTmpl extends EcoreTmpl {
	
	override getTargetFileName() '''«model.name»Gratext.genmodel'''
	
	def targetName() '''«model.name»Gratext'''
	
	override template() '''	
		<?xml version="1.0" encoding="UTF-8"?>
		<genmodel:GenModel xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:genmodel="http://www.eclipse.org/emf/2002/GenModel" runtimeVersion="2.10"
		    modelName="«targetName»" complianceLevel="8.0" copyrightFields="false"
		    modelDirectory="/«project.symbolicName»/model-gen"
		    modelPluginID="«project.symbolicName»"
		    editPluginID="«project.symbolicName».edit"
		    editorPluginID="«project.symbolicName».editor"
		    testsPluginID="«project.symbolicName».tests">
		    «val ecoreFileName = EcoreTmpl.getTargetFileName»
			<genPackages prefix="«targetName»" basePackage="«model.package»" disposableProviderFactory="true" ecorePackage="«ecoreFileName»#/">
			    <genClasses ecoreClass="«ecoreFileName»#//«model.name»"/>
			    «FOR node:model.nodes»
			    	<genClasses ecoreClass="«ecoreFileName»#//«node.name»">
«««			    	«typeAttributeMap.get(node).map[
«««			    		'''<genFeatures createChild="false" ecoreFeature="ecore:EAttribute «ecoreFile.name»#//«node.name»/gratext_«name»"/>'''
«««			    	].join("\n") ?: ""»
			    	</genClasses>
			    «ENDFOR»
			    «FOR edge:model.edges»
			    	<genClasses ecoreClass="«ecoreFileName»#//«edge.name»"/>
			    «ENDFOR»
			    «FOR cls:classes»
			    	«cls.toGenmodelXMI(ecoreFileName)»
			    «ENDFOR»
			</genPackages>
			<usedGenPackages href="platform:/resource/«model.projectSymbolicName»/src-gen/model/«model.name».genmodel#//«model.name.toLowerCase»"/>
			<usedGenPackages href="platform:/plugin/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.genmodel#//graphmodel"/>
		</genmodel:GenModel>
	'''
	
}