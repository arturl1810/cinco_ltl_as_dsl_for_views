package de.jabc.cinco.meta.core.utils.mwe2

import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.w3c.dom.Attr
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.Node
import org.apache.log4j.Logger
import javax.xml.transform.OutputKeys

class MakeSourceDirectory implements IWorkflowComponent {
	
	private static final Logger log = Logger.getLogger(MakeSourceDirectory);

	String srcDir = null
	String project = null

	def String getSrcDir() {
		return srcDir
	}

	def void setSrcDir(String srcDir) {
		this.srcDir = srcDir
	}

	def String getProject() {
		return project
	}

	def void setProject(String project) {
		this.project = project
	}

	override void invoke(IWorkflowContext arg0) {
		
		if (srcDir.nullOrEmpty) {
			log.error("srcDir property must be set")
			throw new IllegalArgumentException("srcDir property must be set")
		}

		if (project.nullOrEmpty) {
			log.error("project property must be set")
			throw new IllegalArgumentException("project property must be set")
		}
			
		if (srcDir.contains("/")) {
			log.error("srcDir must not contain /")
			throw new IllegalArgumentException("srcDir must not contain /")
		}
		
		var File fSrcDir = new File(project + "/" + srcDir)
		
		if (fSrcDir.exists && !fSrcDir.directory) {
			log.error('''file "«srcDir»" exists, but is no directory''')
			throw new IllegalStateException('''srcDir "«srcDir»" exists, but is no directory''')
		}	

		if (!fSrcDir.exists) {
			log.info('''directory "«srcDir»" does not exist in «project» yet. Creating it.''')
			fSrcDir.mkdir
		}
			
		srcDir.addToClasspathIfNotAlreay
		
	}
	
	def addToClasspathIfNotAlreay(String srcDir) {
		var File fClasspath = new File(project + "/.classpath")
		val builder = DocumentBuilderFactory.newInstance().newDocumentBuilder
		val doc = builder.parse(fClasspath)
		val entries = doc.getElementsByTagName("classpathentry")
		val root = doc.getElementsByTagName("classpath").item(0) as Element
		var entryExists = false
		for (var i = 0; i < entries.length; i++) {
			val entry = entries.item(i)
			if (entry.nodeType == Node.ELEMENT_NODE) {
				val elementry = entry as Element	
				if (elementry.isSrcEntry(srcDir)) {
					entryExists = true	
				}
			}
		}
		if (!entryExists) {
			log.info('''src entry for "«srcDir»" does not exist in «project»/.classpath. Adding it.''')
			val newEntry = doc.createElement("classpathentry")
			newEntry.setAttribute("kind", "src")
			newEntry.setAttribute("path", srcDir)
			root.appendChild(newEntry)
			doc.writeToClasspathFile
		}
		
	}
	
	def isSrcEntry(Element e, String srcDir) {
		val kind = (e.attributes.getNamedItem("kind") as Attr).value
		val path = (e.attributes.getNamedItem("path") as Attr).value
		kind == "src" && path == srcDir
	}

	def writeToClasspathFile(Document doc) {
		val transformer = TransformerFactory.newInstance().newTransformer();
		transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
	    transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		val output = new StreamResult(new File(project + "/.classpath"));
		val input = new DOMSource(doc);
		transformer.transform(input, output);
	}
	

	override void postInvoke() { // TODO Auto-generated method stub
	}

	override void preInvoke() { // TODO Auto-generated method stub
	}
}
