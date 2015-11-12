package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.core.utils.URIHandler
import java.io.ByteArrayOutputStream
import java.nio.charset.StandardCharsets
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.List
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.xmi.XMIResource

class GratextGenmodelTemplate extends AbstractGratextTemplate {
	
def ecoreFile() { fileFromTemplate(GratextEcoreTemplate) }
	
def classes() {
	val classes = new ArrayList<E_Class>
	classes.addAll(Arrays.asList(
		new E_Class("_Point")
			.add(new E_Attribute("x", E_Type.EInt).defaultValue("0"))
			.add(new E_Attribute("y", E_Type.EInt).defaultValue("0")),
		new E_Class("_Placement").supertypes("#//_Point")
			.add(new E_Attribute("width", E_Type.EInt).defaultValue("-1"))
			.add(new E_Attribute("height", E_Type.EInt).defaultValue("-1")),
		new E_Interface("_Placed")
			.add(new E_Reference("placement", "#//_Placement").containment(true)),
		new E_Class("_Route")
			.add(new E_Reference("points", "#//_Point").containment(true).upper(-1)),
		new E_Interface("_EdgeTarget"),
		new E_Interface("_EdgeSource")
			.add(new E_Reference("outgoingEdges", "#//_Edge").containment(true).upper(-1)),
		new E_Interface("_Edge")
			.add(new E_Reference("route", "#//_Route").containment(true))
			.add(new E_Reference("target", "#//_EdgeTarget").containment(true))
	))
	graphmodel.edges.forEach[edge | classes.add(
		new E_Interface("_" + edge.name + "Target").supertypes("#//_EdgeTarget")
	)]
	return classes
}
		
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


static class E_Class {
	protected String name
	protected String supertypes
	protected Boolean isInterface = false
	List<E_Attribute> attributes = new ArrayList<E_Attribute>
	List<E_Reference> references = new ArrayList<E_Reference>
	
	new(String name) { this.name = name }
	
	def add(E_Attribute attr) { attributes.add(attr); attr.classname = name; this }
	def add(E_Reference ref) { references.add(ref); ref.classname = name; this }
	def supertypes(String types) { supertypes = types; this }
	
	def toXMI() { '''
		<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isInterface»" interface="«isInterface»" eSuperTypes="«supertypes»">
		«FOR attr:attributes»«attr.toXMI»«ENDFOR»
		«FOR ref:references»«ref.toXMI»«ENDFOR»
		</eClassifiers>'''
	}
	
	def toGenmodelXMI(String ecoreClass) { '''
		<genClasses ecoreClass="«ecoreClass»#//«name»">
	    «FOR attr:attributes»«attr.toGenmodelXMI(ecoreClass)»«ENDFOR»
	    «FOR ref:references»«ref.toGenmodelXMI(ecoreClass)»«ENDFOR»
		</genClasses>
		'''
	}
}	
	
static class E_Interface extends E_Class {
	new(String name) { super(name); isInterface = false }
}

static class E_Attribute {
	protected String name
	protected String classname
	protected String type
	protected String defaultValue
	
	new(String name, String type) { this.name = name; this.type = type }
	
	def defaultValue(String value) { defaultValue = value; this }
	
	def toXMI() { '''
		<eStructuralFeatures xsi:type="ecore:EAttribute" name="«name»" eType="«type»" defaultValueLiteral="«defaultValue»"/>'''
	}
	
	def toGenmodelXMI(String ecoreClass) { '''
		<genFeatures createChild="false" ecoreFeature="ecore:EAttribute «ecoreClass»#//«classname»/«name»"/>'''
	}
}

static class E_Reference {
	protected String name
	protected String classname
	protected String type
	protected boolean isContainment = false
	protected int lower = 0
	protected int upper = 1
	
	new(String name, String type) {
		this.name = name
		this.type = type
	}
	
	def containment(boolean flag) { isContainment = flag; this }
	def lower(int num) { lower = num; this }
	def upper(int num) { upper = num; this }
	
	def toXMI() { '''
		<eStructuralFeatures xsi:type="ecore:EReference" name="«name»" eType="«type»" containment="«isContainment»" lowerBound="«lower»" upperBound="«upper»"/>'''
	}
	
	def toGenmodelXMI(String ecoreClass) { '''
		<genFeatures property="None" children="true" createChild="true" ecoreFeature="ecore:EReference «ecoreClass»#//«classname»/«name»"/>'''
	}
}

static class E_Type {
	protected final static String EInt = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EInt'''
	protected final static String EString = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString'''
	protected final static String EBoolean = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EBoolean'''
}
}