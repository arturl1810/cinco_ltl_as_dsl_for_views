package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.ge.style.generator.api.templates.CModelElementTmpl
import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import mgl.GraphModel
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils

class CincoApiGeneratorMain extends APIUtils {
	
	extension CModelElementTmpl = new CModelElementTmpl
	
	var GraphModel gm
	
	new (GraphModel graphModel) {
		this.gm = graphModel
	}
	
	def doGenerate(IProject project) {
		var content = gm.doGenerateInterface
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameAPI, gm.fuCName.concat(".java"), content)
		content = gm.doGenerateImpl
		ContentWriter::writeJavaFileInSrcGen(project, gm.packageNameAPI, gm.fuCName.concat("Impl.java"), content)
		
		for (n : gm.nodes) {
			content = n.doGenerateInterface
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAPI, n.fuCName.concat(".java"), content)
			content = n.doGenerateImpl
			ContentWriter::writeJavaFileInSrcGen(project, n.packageNameAPI, n.fuCName.concat("Impl.java"), content)
		}
		
		for (e : gm.edges) {
			content = e.doGenerateInterface
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameAPI, e.fuCName.concat(".java"), content)
			content = e.doGenerateImpl
			ContentWriter::writeJavaFileInSrcGen(project, e.packageNameAPI, e.fuCName.concat("Impl.java"), content)
		}
	}
	
}