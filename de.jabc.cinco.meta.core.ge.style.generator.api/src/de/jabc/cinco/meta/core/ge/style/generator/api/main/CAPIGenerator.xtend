package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.capi.generator.utils.CAPIUtils
import mgl.GraphModel
import mgl.ModelElement
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IPath
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.JavaCore
import de.jabc.cinco.meta.core.utils.projects.ContentWriter

class CAPIGenerator {
	
	def doGenerate(IProject p, GraphModel gm, IPath out) {
		CAPIUtils.setCurrentGraphModel(gm);
		val packageName = gm.package.concat(".newcapi")
		var pack = createPackage(p, gm.package.concat(".newcapi"))
		
		for (n : gm.nodes) {
			var nodeTmplContent = new de.jabc.cinco.meta.core.capi.generator.Node_MainTemplate(n).create()
			var fileName = n.fileName
			
			ContentWriter::writeJavaFileInSrcGen(p, packageName, fileName, nodeTmplContent)
//			createJavaFile(pack, fileName, nodeTmplContent.toString)
			
			nodeTmplContent = new de.jabc.cinco.meta.core.capi.generator.NodeView_MainTemplate(n).create()
			fileName = n.viewFileName
			
			ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".newcapi"),fileName, nodeTmplContent)
//			createJavaFile(pack, fileName, nodeTmplContent.toString)
		}
		
		for (e : gm.edges) {
			var edgeTmplContent = new Edge_MainTemplate(e).create()
			var fileName = e.fileName
			
			createJavaFile(pack, fileName, edgeTmplContent.toString)
			
			edgeTmplContent = new de.jabc.cinco.meta.core.capi.generator.EdgeView_MainTemplate(e).create()
			fileName = e.viewFileName
			
			ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".newcapi"),fileName, edgeTmplContent)
		}
		
		var graphModelTmplContent = new de.jabc.cinco.meta.core.capi.generator.GraphModel_MainTemplate(gm).create();
		var fileName = gm.fileName
		ContentWriter::writeJavaFileInSrcGen(p,gm.package.concat(".newcapi"),fileName, graphModelTmplContent)
		
		graphModelTmplContent = new de.jabc.cinco.meta.core.capi.generator.GraphModelView_MainTemplate(gm).create();
		fileName = gm.viewFileName
		ContentWriter::writeJavaFileInSrcGen(p,gm.package.concat(".newcapi"),fileName, graphModelTmplContent)
		
		var wrapperTmplContent = new de.jabc.cinco.meta.core.capi.generator.Wrapper_MainTemplate(gm).create()
		fileName = gm.wrapperFileName
		
		ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".newcapi"), fileName, wrapperTmplContent)
	}
	
	def createPackage(IProject p, String apiPackageName) {
		var javaProject = JavaCore.create(p);
		for (r : javaProject.allPackageFragmentRoots) {
			if (r.elementName.equals("src-gen")) {
				return r.createPackageFragment(apiPackageName, true, null)
			}
			
		}
	}
	
	def createJavaFile(IPackageFragment pack, String fileName, String content) {
		pack.createCompilationUnit(fileName,content, false, null)
	}
	
	def getFileName(ModelElement me) {
		return "C" + me.name + ".java"
	}
	
	def getViewFileName(ModelElement me) {
		return "C" + me.name + "View.java"
	}
	
	def getWrapperFileName(GraphModel gm) {
		return gm.name.toFirstUpper+"Wrapper.java"
	}
}
