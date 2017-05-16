package de.jabc.cinco.meta.core.utils.projects

import de.jabc.cinco.meta.core.utils.CincoUtil
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.io.IOException
import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.core.JavaCore

class ContentWriter {
	
//	final static String PLUGIN_FRAME = "<?xml version=\"1.0\" encoding=\"" + System.getProperty("file.encoding") +
//		"\"?>\n" + "<?eclipse version=\"3.0\"?>\n" + "<plugin>\n" + "</plugin>"

	def static void writeJavaFileInSrcGen(IProject p, CharSequence packageName, String fileName, CharSequence content) {
		writeJavaFile(p, "src-gen", packageName.toString(), fileName, content.toString())
	}

	def static void writeJavaFileInSrcGen(IProject p, String packageName, String fileName, CharSequence content) {
		writeJavaFile(p, "src-gen", packageName, fileName, content.toString())
	}

	def static void writeJavaFileInSrcGen(IProject p, String packageName, String fileName, String content) {
		writeJavaFile(p, "src-gen", packageName, fileName, content)
	}

	def static void writeJavaFile(IProject p, String folderName, String packageName, String fileName, String content) {
		var NullProgressMonitor monitor = new NullProgressMonitor()
		var IFolder folder = p.getFolder(folderName)
		try {
			if (!folder.exists()) {
				folder.create(true, true, monitor)
			}
			var IJavaProject javaProject = JavaCore.create(p)
			var IPackageFragmentRoot packageFragmentRoot = javaProject.getPackageFragmentRoot(folder)
			var IPackageFragment pack = packageFragmentRoot.createPackageFragment(packageName, true, monitor)
			pack.createCompilationUnit(fileName, content.toString(), false, monitor)
		} catch (CoreException e) {
			e.printStackTrace()
		}

	}

	def static void writeFile(IProject p, String folderName, CharSequence packageName, String fileName,
		CharSequence content) {
		var NullProgressMonitor monitor = new NullProgressMonitor()
		var IFolder folder = p.getFolder(folderName)
		var IFolder packageFolder = null
		try {
			if (!folder.exists()) {
				folder.create(true, true, monitor)
			}
			packageFolder = folder.getFolder(new Path(packageName.toString().replaceAll("\\.", "/")))
			if(!packageFolder.exists()) packageFolder.create(true, true, monitor)
			var IFile f = packageFolder.getFile(fileName)
			var File file = f.getLocation().toFile()
			var FileWriter fw = new FileWriter(file)
			fw.write(content.toString())
			fw.close()
		} catch (CoreException e) {
			e.printStackTrace()
		} catch (IOException e) {
			e.printStackTrace()
		}

	}

	def static void writePluginXML(IProject project, CharSequence content, String extensionCommentID) {
		var String pluginXMLPath = project.getLocation().append("plugin.xml").toString()
		CincoUtil.addExtension(pluginXMLPath, content.toString(), extensionCommentID, project.getName())
	}

	def static void writePluginXML(IProject project, List<CharSequence> extensions, String extensionCommentID) {
		writePluginXML(project, extensions.join("\n"), extensionCommentID)
	}

	def static String getFileContents(File pluginXMLFile) throws IOException {
		var BufferedReader reader = new BufferedReader(new FileReader(pluginXMLFile))
		var String line
		var String content = new String()
		while ((line = reader.readLine()) !== null) {
			content += line
		}
		reader.close()
		return content
	}
}
