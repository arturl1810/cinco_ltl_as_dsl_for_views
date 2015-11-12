package de.jabc.cinco.meta.plugin.gratext.template

import mgl.Node
import java.util.Arrays
import java.util.List
import java.util.ArrayList

class GratextEcoreTemplate extends AbstractGratextTemplate {
	
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
			.add(new E_Attribute("target", E_Type.EString))
			.add(new E_Reference("route", "#//_Route").containment(true))
	))
//	model.edges.forEach[edge | classes.add(
//		new E_Interface("_" + edge.name + "Target").supertypes("#//_EdgeTarget")
//	)]
	return classes
}

def interfaces(Node node) {
	var str = '''<eSuperTypes href="#//_Placed"/>'''
//	debug("Node: " + node.name)
//	debug(" > isEdgeSource: " + model.resp(node).isEdgeSource)
	if (model.resp(node).isEdgeSource)
		str += '''<eSuperTypes href="#//_EdgeSource"/>'''
//	debug(" > #incoming: " + model.resp(node).incomingEdges.size)
//	for (edge : model.resp(node).incomingEdges) {
//		debug("   > " + edge.name)
//		str += '''<eSuperTypes href="#//_«edge.name»Target"/>'''
//	}
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
  	 <eSuperTypes href="«graphmodel.nsURI»#//«model.name»"/>
  </eClassifiers>
  «FOR node:model.nodes»
  <eClassifiers xsi:type="ecore:EClass" name="«node.name»" abstract="«node.isIsAbstract»">
  	<eSuperTypes href="«graphmodel.nsURI»#//«node.name»"/>
  	«interfaces(node)»
  </eClassifiers>
  «ENDFOR»
  «FOR edge:model.edges»
  <eClassifiers xsi:type="ecore:EClass" name="«edge.name»">
  	<eSuperTypes href="«graphmodel.nsURI»#//«edge.name»"/>
  	<eSuperTypes href="#//_Edge"/>
  </eClassifiers>
  «ENDFOR»
  «FOR cls:classes»«cls.toXMI»«ENDFOR»
</ecore:EPackage>
'''


static class E_Class {
	protected String name
	protected String supertypes
	protected Boolean isAbstract = false
	protected Boolean isInterface = false
	List<E_Attribute> attributes = new ArrayList<E_Attribute>
	List<E_Reference> references = new ArrayList<E_Reference>
	
	new(String name) { this.name = name }
	
	def add(E_Attribute attr) { attributes.add(attr); this }
	def add(E_Reference ref) { references.add(ref); this }
	def supertypes(String types) { supertypes = types; this }
	
	def toXMI() { '''
		<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isAbstract»" interface="«isInterface»" eSuperTypes="«supertypes»">
		«FOR attr:attributes»«attr.toXMI»«ENDFOR»
		«FOR ref:references»«ref.toXMI»«ENDFOR»
		</eClassifiers>'''
	}
}	
	
static class E_Interface extends E_Class {
	new(String name) { super(name); isAbstract = true; isInterface = true }
}

static class E_Attribute {
	protected String name
	protected String type
	protected String defaultValue
	
	new(String name, String type) { this.name = name; this.type = type }
	
	def defaultValue(String value) { defaultValue = value; this }
	
	def toXMI() { '''
		<eStructuralFeatures xsi:type="ecore:EAttribute" name="«name»" eType="«type»" defaultValueLiteral="«defaultValue»"/>'''
	}
}

static class E_Reference {
	protected String name
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
}

static class E_Type {
	protected final static String EInt = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EInt'''
	protected final static String EString = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString'''
	protected final static String EBoolean = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EBoolean'''
}

}



