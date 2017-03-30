package de.jabc.cinco.meta.plugin.gratext.template

import mgl.Node
import java.util.Arrays
import java.util.List
import java.util.ArrayList

class GratextEcoreTemplate extends AbstractGratextTemplate {

def graphModelURI() '''«graphmodel.nsURI»/internal'''
//def graphModelEcorePlatformResourceURI() '''platform:/resource/info.scce.cinco.product.flowgraph/src-gen/model/FlowGraph.ecore'''
def graphModelEcorePlatformResourceURI() '''platform:/resource/«modelProjectSymbolicName»/src-gen/model/«model.name».ecore'''


def classes() {
	val classes = new ArrayList<E_Class>
	classes.addAll(Arrays.asList(
		new E_Class("_Point")
			.add(new E_Attribute("x", E_Type.EInt).defaultValue("0"))
			.add(new E_Attribute("y", E_Type.EInt).defaultValue("0")),
		new E_Class("_Placement").supertypes("#//_Point")
			.add(new E_Attribute("width", E_Type.EInt).defaultValue("-1"))
			.add(new E_Attribute("height", E_Type.EInt).defaultValue("-1"))
			.add(new E_Attribute("index", E_Type.EInt).defaultValue("-1")),
		new E_Interface("_Placed")
			.add(new E_Reference("placement", "#//_Placement").containment(true)),
		new E_Class("_Route")
			.add(new E_Reference("points", "#//_Point").containment(true).upper(-1)),
		new E_Class("_Decoration")
			.add(new E_Attribute("namehint", E_Type.EString).defaultValue(""))
			.add(new E_Reference("location", "#//_Point").containment(true)),
		new E_Interface("_EdgeSource")
			.add(new E_Reference("outgoingEdges", "#//_Edge").containment(true).upper(-1)),
		new E_Interface("_Edge")
			.add(new E_Reference("route", "#//_Route").containment(true))
			.add(new E_Reference("decorations", "#//_Decoration").containment(true).upper(-1)),
		new E_Interface("_Prime")
			.add(new E_Reference("prime", "ecore:EClass http://www.eclipse.org/emf/2002/Ecore#//EObject"))
	))
	return classes
}

def interfaces(Node node) {
	var str = '''<eSuperTypes href="#//_Placed"/>'''
	if (model.resp(node).isEdgeSource)
		str += '''<eSuperTypes href="#//_EdgeSource"/>'''
	if (model.resp(node).primeReference != null)
		str += '''<eSuperTypes href="#//_Prime"/>'''
	return str
}

override template()
'''	
<?xml version="1.0" encoding="ASCII"?>
<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
    name="«project.acronym»"
    nsURI="«graphmodel.nsURI»/«project.acronym»"
    nsPrefix="«project.acronym»">
  <eAnnotations source="http://www.eclipse.org/emf/2002/Ecore">
«««    <details key="settingDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
«««    <details key="invocationDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
«««    <details key="validationDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
  </eAnnotations>
  <eClassifiers xsi:type="ecore:EClass" name="«model.name»">
  	 <eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«model.name»"/>
  </eClassifiers>
  «FOR node:model.nodes»
  <eClassifiers xsi:type="ecore:EClass" name="«node.name»" abstract="«node.isIsAbstract»">
«««  	<eSuperTypes href="«graphModelURI»#//Internal«node.name»"/>
	<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«node.name»"/>
  	«interfaces(node)»
  </eClassifiers>
  «ENDFOR»
  «FOR edge:model.edges»
  <eClassifiers xsi:type="ecore:EClass" name="«edge.name»">
  	<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«edge.name»"/>
  	<eSuperTypes href="#//_Edge"/>
  </eClassifiers>
  «ENDFOR»
  «FOR cls:classes»«cls.toXMI»«ENDFOR»
</ecore:EPackage>
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
	
	def toXMI()
	'''
		<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isInterface»" interface="«isInterface»" eSuperTypes="«supertypes»">
		«FOR attr:attributes»«attr.toXMI»«ENDFOR»
		«FOR ref:references»«ref.toXMI»«ENDFOR»
		</eClassifiers>
	'''
	
	def toGenmodelXMI(String ecoreClass)
	'''
		<genClasses ecoreClass="«ecoreClass»#//«name»">
	    «FOR attr:attributes»«attr.toGenmodelXMI(ecoreClass)»«ENDFOR»
	    «FOR ref:references»«ref.toGenmodelXMI(ecoreClass)»«ENDFOR»
		</genClasses>
	'''
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
	
	def toXMI()
	'''<eStructuralFeatures xsi:type="ecore:EAttribute" name="«name»" eType="«type»" defaultValueLiteral="«defaultValue»"/>'''
	
	def toGenmodelXMI(String ecoreClass)
	'''<genFeatures createChild="false" ecoreFeature="ecore:EAttribute «ecoreClass»#//«classname»/«name»"/>'''
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




