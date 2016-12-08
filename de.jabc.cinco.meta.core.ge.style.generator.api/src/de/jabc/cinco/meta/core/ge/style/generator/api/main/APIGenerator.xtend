package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.ge.style.generator.api.utils.APIUtils
import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import mgl.GraphModel
import mgl.ModelElement
import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.JavaCore

class APIGenerator {
	
	def doGenerate(IProject p, GraphModel gm) {
		APIUtils.setCurrentGraphModel(gm);
		val packageName = gm.package.concat(".api")
		var pack = createPackage(p, gm.package.concat(".api"))
		
		for (n : gm.nodes) {
			var nodeTmplContent = new Node_MainTemplate(n).doGenerate()
			var fileName = n.fileName
			
			ContentWriter::writeJavaFileInSrcGen(p, packageName, fileName, nodeTmplContent)
			
			nodeTmplContent = new NodeView_MainTemplate(n).doGenerate()
			fileName = n.viewFileName
			
			ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".api"),fileName, nodeTmplContent)
		}
		
		for (e : gm.edges) {
			var edgeTmplContent = new Edge_MainTemplate(e).doGenerate()
			var fileName = e.fileName
			
			createJavaFile(pack, fileName, edgeTmplContent.toString)
			
			edgeTmplContent = new EdgeView_MainTemplate(e).doGenerate()
			fileName = e.viewFileName
			
			ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".api"),fileName, edgeTmplContent)
		}
		
		var graphModelTmplContent = new GraphModel_MainTemplate(gm).doGenerate();
		var fileName = gm.fileName
		ContentWriter::writeJavaFileInSrcGen(p,gm.package.concat(".api"),fileName, graphModelTmplContent)
		
		graphModelTmplContent = new GraphModelView_MainTemplate(gm).doGenerate();
		fileName = gm.viewFileName
		ContentWriter::writeJavaFileInSrcGen(p,gm.package.concat(".api"),fileName, graphModelTmplContent)
		
		var wrapperTmplContent = new Wrapper_MainTemplate(gm).doGenerate()
		fileName = gm.wrapperFileName
		
		ContentWriter::writeJavaFileInSrcGen(p, gm.package.concat(".api"), fileName, wrapperTmplContent)
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
		return me.name + ".java"
	}
	
	def getViewFileName(ModelElement me) {
		return me.name + "View.java"
	}
	
	def getWrapperFileName(GraphModel gm) {
		return gm.name.toFirstUpper+"Wrapper.java"
	}
}
