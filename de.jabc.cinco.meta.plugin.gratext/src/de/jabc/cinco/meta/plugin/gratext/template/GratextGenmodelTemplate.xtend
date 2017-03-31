package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.core.utils.URIHandler
import java.io.ByteArrayOutputStream
import java.nio.charset.StandardCharsets
import java.util.HashMap
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.xmi.XMIResource
import de.jabc.cinco.meta.plugin.gratext.GratextProjectGenerator

class GratextGenmodelTemplate extends GratextEcoreTemplate {
	
def ecoreFile() { fileFromTemplate(GratextEcoreTemplate) }
	
def genmodel() {
	val genModel = createGenModel
//	for (genPackage : genModel.genPackages) {
//		genPackage.basePackage = project.basePackage
//	}
	val bops = new ByteArrayOutputStream
	val optionMap = new HashMap<String,Object>
	optionMap.put(XMIResource.OPTION_URI_HANDLER, new URIHandler(ctx.context.get("ePackage") as EPackage));
	optionMap.put(XMIResource.OPTION_ENCODING, StandardCharsets.UTF_8.name());
	genModel.eResource.save(bops, optionMap);
	return bops.toString(StandardCharsets.UTF_8.name());
}

override template()
'''	
<?xml version="1.0" encoding="UTF-8"?>
<genmodel:GenModel xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:genmodel="http://www.eclipse.org/emf/2002/GenModel" runtimeVersion="2.10"
    modelName="«project.targetName»" complianceLevel="8.0" copyrightFields="false"
    modelDirectory="/«project.symbolicName»/model-gen"
    modelPluginID="«project.symbolicName»"
    editPluginID="«project.symbolicName».edit"
    editorPluginID="«project.symbolicName».editor"
    testsPluginID="«project.symbolicName».tests">
  <genPackages prefix="«project.targetName»" basePackage="«model.basePackage»" disposableProviderFactory="true" ecorePackage="«ecoreFile.name»#/">
    <genClasses ecoreClass="«ecoreFile.name»#//«model.name»"/>
    «FOR node:model.nodes»
    <genClasses ecoreClass="«ecoreFile.name»#//«node.name»"/>
    «ENDFOR»
    «FOR edge:model.edges»
    <genClasses ecoreClass="«ecoreFile.name»#//«edge.name»"/>
    «ENDFOR»
    «FOR cls:classes»«cls.toGenmodelXMI(ecoreFile.name)»«ENDFOR»
  </genPackages>
  <usedGenPackages href="platform:/resource/«ctx.modelProjectSymbolicName»/src-gen/model/«model.name».genmodel#//«model.acronym»"/>
  <usedGenPackages href="platform:/plugin/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.genmodel#//graphmodel"/>
</genmodel:GenModel>
'''



}