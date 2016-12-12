package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class TracerSchemaTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return super.graphmodel.tracerPackage+".exsd"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	<?xml version='1.0' encoding='UTF-8'?>
	<!-- Schema file written by PDE -->
	<schema targetNamespace="«graphmodel.tracerPackage»" xmlns="http://www.w3.org/2001/XMLSchema">
	<annotation>
	      <appinfo>
	         <meta.schema plugin="«graphmodel.tracerPackage»" id="«graphmodel.tracerPackage».execution" name="Execution"/>
	      </appinfo>
	      <documentation>
	         [Enter description of this extension point.]
	      </documentation>
	   </annotation>
	
	   <element name="extension">
	      <annotation>
	         <appinfo>
	            <meta.element />
	         </appinfo>
	      </annotation>
	      <complexType>
	         <choice minOccurs="1" maxOccurs="unbounded">
	            <element ref="executionsemantic"/>
	         </choice>
	         <attribute name="point" type="string" use="required">
	            <annotation>
	               <documentation>
	                  
	               </documentation>
	            </annotation>
	         </attribute>
	         <attribute name="id" type="string">
	            <annotation>
	               <documentation>
	                  
	               </documentation>
	            </annotation>
	         </attribute>
	         <attribute name="extension" type="string">
	            <annotation>
	               <documentation>
	                  
	               </documentation>
	               <appinfo>
	                  <meta.attribute translatable="true"/>
	               </appinfo>
	            </annotation>
	         </attribute>
	      </complexType>
	   </element>
	
	   <element name="executionsemantic">
	      <complexType>
	         <attribute name="context" type="string" use="required">
	            <annotation>
	               <documentation>
	                  
	               </documentation>
	               <appinfo>
	                  <meta.attribute kind="java" basedOn="«graphmodel.tracerPackage».AbstractContext:"/>
	               </appinfo>
	            </annotation>
	         </attribute>
	         <attribute name="semantic" type="string" use="required">
	            <annotation>
	               <documentation>
	                  
	               </documentation>
	               <appinfo>
	                  <meta.attribute kind="java" basedOn="«graphmodel.tracerPackage».AbstractSemantic:"/>
	               </appinfo>
	            </annotation>
	         </attribute>
	      </complexType>
	   </element>
	
	   <annotation>
	      <appinfo>
	         <meta.section type="since"/>
	      </appinfo>
	      <documentation>
	         [Enter the first release in which this extension point appears.]
	      </documentation>
	   </annotation>
	
	   <annotation>
	      <appinfo>
	         <meta.section type="examples"/>
	      </appinfo>
	      <documentation>
	         [Enter extension point usage example here.]
	      </documentation>
	   </annotation>
	
	   <annotation>
	      <appinfo>
	         <meta.section type="apiinfo"/>
	      </appinfo>
	      <documentation>
	         [Enter API information here.]
	      </documentation>
	   </annotation>
	
	   <annotation>
	      <appinfo>
	         <meta.section type="implementation"/>
	      </appinfo>
	      <documentation>
	         [Enter information about supplied implementation of this extension point.]
	      </documentation>
	   </annotation>
	
	
	</schema>
	
	'''
	
}