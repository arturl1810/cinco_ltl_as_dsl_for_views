package de.jabc.cinco.meta.core.utils.mwe2

import java.io.File
import java.nio.charset.Charset
import java.nio.file.Files
import java.nio.file.Paths
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import org.apache.log4j.Logger
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.w3c.dom.Attr
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.NodeList
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent

class MakeSourceDirectory implements IWorkflowComponent {
	
	private static final Logger log = Logger.getLogger(MakeSourceDirectory);
	
	String srcDir = null
	String project = null
	boolean addGitIgnore = false
	boolean cleanIfExisting = false
	boolean createIfMissing = true


	def setSrcDir(String str) {
		srcDir = str
	}

	def setProject(String str) {
		project = str
	}
	
	def setAddGitIgnore(boolean flag) {
		addGitIgnore = flag
	}
	
	def setCleanIfExisting(boolean flag) {
		cleanIfExisting = flag
	}
	
	def setCreateIfMissing(boolean flag) {
		createIfMissing = flag
	}

	override invoke(IWorkflowContext arg0) {
		project.nullOrEmpty ?: "project property must be set"
		val fProject = Paths.get(project).toFile
		!fProject.exists ?: '''project «project» does not exist'''
		
		srcDir.nullOrEmpty ?: "srcDir property must be set"
		srcDir.contains("/") ?: "srcDir must not contain /"
		val fSrcDir = Paths.get(project, srcDir).toFile
		if (!fSrcDir.exists) {
			if (createIfMissing) {
				log.info('''Creating directory "«fSrcDir»"''')
				fSrcDir.mkdir
			}
		} else {
			!fSrcDir.isDirectory ?: '''file "«fSrcDir»" exists, but is no directory'''
			if (cleanIfExisting) {
				log.info('''Cleaning "«fSrcDir»"''')
				fSrcDir.clean
			}
		}
			
		val fGitIgnore = Paths.get(project, srcDir, ".gitignore")
		if (addGitIgnore && !fGitIgnore.toFile.exists) {
			log.info('''Creating file "«fGitIgnore»"''')
			Files.write(fGitIgnore, #["*", "!.gitignore"], Charset.forName("UTF-8"));
		}
		
		addToClasspathIfMissing
	}
	
	/**
	 * Convenient operator for handling assertions.
	 */
	private def ?: (boolean test, String message) {
		if (test) {
			log.error(message)
			throw new IllegalArgumentException(message)
		}
	}
	
	private def addToClasspathIfMissing() {
		val fClasspath = Paths.get(project, ".classpath").toFile
		val builder = DocumentBuilderFactory.newInstance.newDocumentBuilder
		val doc = builder.parse(fClasspath)
		val entries = doc.getElementsByTagName("classpathentry")
		if (!entries.containsSrcEntry) {
			log.info('''Adding "«srcDir»" to «fClasspath».''')
			val root = doc.getElementsByTagName("classpath").item(0)
			root.appendChild(doc.createElement("classpathentry") => [
				setAttribute("kind", "src")
				setAttribute("path", srcDir)
			])
			doc.writeToClasspathFile(fClasspath)
		}
	}
	
	private def containsSrcEntry(NodeList entries) {
		for (i : 0..entries.length) {
			switch entry : entries.item(i) {
				Element : if (entry.isSrcEntry(srcDir))
					return true
			}
		}
		return false
	}
	
	private def isSrcEntry(Element e, String srcDir) {
		val kind = (e.attributes.getNamedItem("kind") as Attr)?.value
		val path = (e.attributes.getNamedItem("path") as Attr)?.value
		kind == "src" && path == srcDir
	}

	private def writeToClasspathFile(Document doc, File fClasspath) {
		TransformerFactory.newInstance.newTransformer => [
			setOutputProperty(OutputKeys.ENCODING, "UTF-8")
			setOutputProperty(OutputKeys.INDENT, "yes")
			transform(
				new DOMSource(doc),
				new StreamResult(fClasspath)
			)
		]
	}
	
	private def clean(File fSrcDir) {
		fSrcDir.listFiles?.forEach[
			if (isDirectory) clean
			else if (!delete) log.error('''Couldn't delete "«it»"''')
		]
	}
	
	override void postInvoke() { /* nothing to do here */ }

	override void preInvoke() { /* nothing to do here */ }
}
