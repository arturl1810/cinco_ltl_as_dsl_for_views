package de.jabc.cinco.meta.core.feature.handler

import java.util.HashMap
import java.util.Set
import mgl.GraphModel
import org.eclipse.core.resources.IProject
import org.eclipse.xtext.util.StringInputStream

class GenerateFeatureXML {
	def static void generate(GraphModel model, String packageName,
			HashMap<String, Set<String>> annotationToMGLPackageMap, HashMap<String, Set<String>> annotationToPackageMap,
			HashMap<String, Set<String>> annotationToFragmentMap,
			HashMap<String, Set<String>> annotationToMGLFragmentMap,
			Set<String> otherPluginIDs, Set<String> otherFragmentIDs, IProject featureProject) {
		val plugins = otherPluginIDs+collectPlugins(model,annotationToPackageMap,annotationToMGLPackageMap,packageName)
		val fragments = otherFragmentIDs+collectFragments(model,annotationToFragmentMap,annotationToMGLFragmentMap,packageName)
		val featureXML = generateXML(plugins,fragments,packageName)
			
		val xmlFile = featureProject.getFile("feature.xml")
		if(xmlFile.exists){
			xmlFile.setContents(new StringInputStream(featureXML.toString),true,true,null);
		}else{
			xmlFile.create(new StringInputStream(featureXML.toString),true,null)
		}
		
	}
	
	def static generateXML(Iterable<String> plugins, Iterable<String> fragments,String packageName) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<feature id="«packageName».feature"
			label="«packageName» Feature "
			version="1.0.0.qualifier">
			«FOR pl: plugins»
			<plugin
				id="«pl»"
				download-size="0"
				install-size="0"
				version="0.0.0"
				unpack="false"/>
			«ENDFOR»
			«FOR frg: fragments»
				<plugin
					id="«frg»"
					download-size="0"
					install-size="0"
					version="0.0.0"
					fragment="true"
					unpack="false"/>
			«ENDFOR»
		</feature>
	'''
	
	def static collectPlugins(GraphModel model, HashMap<String, Set<String>> annotationToPackageMap, HashMap<String, Set<String>> annotationToMGLPackageMap,String packageName){
		model.annotations.map[anno| annotationToPackageMap.get(anno)+annotationToMGLPackageMap.get(anno).map[mglDepPkg|String.format("%s.%s",packageName,mglDepPkg)] ].flatten
	}
	
	def static collectFragments(GraphModel model,HashMap<String, Set<String>> annotationToFragmentMap,
			HashMap<String, Set<String>> annotationToMGLFragmentMap,String packageName){
		model.annotations.map[anno| annotationToFragmentMap.get(anno)+annotationToMGLFragmentMap.get(anno).map[mglDepFrg|String.format("%s.%s",packageName,mglDepFrg)] ].flatten
	}
	
	
}