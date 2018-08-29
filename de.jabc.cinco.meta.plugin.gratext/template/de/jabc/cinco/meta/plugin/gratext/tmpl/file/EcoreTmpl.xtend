package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.ComplexAttribute
import mgl.ModelElement
import mgl.Node
import mgl.UserDefinedType

class EcoreTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»Gratext.ecore'''
	
	def graphModelURI() '''«model.nsURI»/internal'''
	
	def graphModelEcorePlatformResourceURI() '''platform:/resource/«model.projectName»/src-gen/model/«model.name».ecore'''
	
	def Iterable<E_Class> classes() {#[
//			new E_Class("_Point")
//				.add(new E_Attribute("x", E_Type.EInt).defaultValue("0"))
//				.add(new E_Attribute("y", E_Type.EInt).defaultValue("0")),
			new E_Class("_Placed") //.supertypes("#//_Point")
//				.add(new E_Attribute("width", E_Type.EInt).defaultValue("-1"))
//				.add(new E_Attribute("height", E_Type.EInt).defaultValue("-1"))
				.add(new E_Attribute("index", E_Type.EInt).defaultValue("-1")),
//			new E_Interface("_Placed")
//				.add(new E_Reference("placement", "#//_Placement").containment(true)),
//			new E_Class("_Route")
//				.add(new E_Reference("points", "#//_Point").containment(true).upper(-1)),
//			new E_Class("_Decoration")
//				.add(new E_Attribute("namehint", E_Type.EString).defaultValue(""))
//				.add(new E_Reference("location", "#//_Point").containment(true)),
			new E_Interface("_EdgeSource")
				.add(new E_Reference("outgoingEdges", "#//_Edge").containment(true).upper(-1)),
			new E_Interface("_Edge"),
//				.add(new E_Reference("route", "#//_Route").containment(true))
//				.add(new E_Reference("decorations", "#//_Decoration").containment(true).upper(-1)),
			new E_Interface("_Prime")
				.add(new E_Reference("prime", "ecore:EClass http://www.eclipse.org/emf/2002/Ecore#//EObject"))
	]}

	def getInterfaces(Node node) {
		var str = '''<eSuperTypes href="#//_Placed"/>'''
		if (node.isEdgeSource)
			str += '''<eSuperTypes href="#//_EdgeSource"/>'''
		if (node.hasPrimeReference)
			str += '''<eSuperTypes href="#//_Prime"/>'''
		return str
	}

	def getTypeAttributes(ModelElement it) {
		allAttributes.filter(ComplexAttribute)
			.filter[type instanceof UserDefinedType].map['''
				<eStructuralFeatures xsi:type="ecore:EReference"
				«IF ((upperBound < 0) || (upperBound > 1))»
					upperBound="-1"
				«ENDIF»
				name="gratext_«name»" eType="#//«type.name»" containment="true"/>
			'''].join("\n") ?: ""
	}

	override template() '''	
		<?xml version="1.0" encoding="ASCII"?>
		<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
		    name="gratext"
		    nsURI="«model.nsURI»/gratext"
		    nsPrefix="gratext">
			<eAnnotations source="http://www.eclipse.org/emf/2002/Ecore">
«««			    <details key="settingDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
«««			    <details key="invocationDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
«««			    <details key="validationDelegates" value="http://www.eclipse.org/emf/2002/Ecore/OCL"/>
			</eAnnotations>
			<eClassifiers xsi:type="ecore:EClass" name="«model.name»">
				<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«model.name»"/>
				«model.typeAttributes»
			</eClassifiers>
			«FOR it:model.nodes»
				<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isIsAbstract»">
«««			  <eStructuralFeatures xsi:type="ecore:EAttribute" name="index" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EInt"/>
					<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«name»"/>
					«interfaces»
					«typeAttributes»
				</eClassifiers>
			«ENDFOR»
			«FOR it:model.edges»
				<eClassifiers xsi:type="ecore:EClass" name="«name»">
					<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«name»"/>
					<eSuperTypes href="#//_Edge"/>
					«typeAttributes»
				</eClassifiers>
			«ENDFOR»
			«FOR it:model.userDefinedTypes»
				<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isIsAbstract»">
					<eSuperTypes href="«graphModelEcorePlatformResourceURI»#//internal/Internal«name»"/>
					«typeAttributes»
				</eClassifiers>
			«ENDFOR»
			«FOR cls:classes»
				«cls.toXMI»
			«ENDFOR»
		</ecore:EPackage>
	'''

	static class E_Class {
		protected String name
		protected String supertypes
		protected Boolean isInterface = false
		val attributes = <E_Attribute>newArrayList
		val references = <E_Reference>newArrayList
		
		new(String name) { this.name = name }
		
		def add(E_Attribute attr) { attributes.add(attr); attr.classname = name; this }
		def add(E_Reference ref) { references.add(ref); ref.classname = name; this }
		def supertypes(String types) { supertypes = types; this }
		
		def toXMI() '''
			<eClassifiers xsi:type="ecore:EClass" name="«name»" abstract="«isInterface»" interface="«isInterface»" eSuperTypes="«supertypes»">
			«FOR attr:attributes»«attr.toXMI»«ENDFOR»
			«FOR ref:references»«ref.toXMI»«ENDFOR»
			</eClassifiers>
		'''
		
		def toGenmodelXMI(String ecoreClass) '''
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
		
		def toXMI() '''
			<eStructuralFeatures xsi:type="ecore:EReference" name="«name»" eType="«type»" containment="«isContainment»" lowerBound="«lower»" upperBound="«upper»"/>
		'''
		
		
		def toGenmodelXMI(String ecoreClass) '''
			<genFeatures property="None" children="true" createChild="true" ecoreFeature="ecore:EReference «ecoreClass»#//«classname»/«name»"/>
		'''
	}
	
	static class E_Type {
		static val EInt = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EInt'''
		static val EString = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString'''
		static val EBoolean = '''ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EBoolean'''
	}

}