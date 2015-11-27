package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextRestoreSchemaTemplate extends AbstractGratextTemplate {

		
override template()
'''	
<?xml version='1.0' encoding='UTF-8'?>
<!-- Schema file written by PDE -->
<schema targetNamespace="info.scce.dime.gratext" xmlns="http://www.w3.org/2001/XMLSchema">
<annotation>
      <appinfo>
         <meta.schema plugin="info.scce.dime.gratext" id="info.scce.cinco.gratext.restore" name="Gratext Restore"/>
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
            <element ref="client"/>
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
         <attribute name="name" type="string">
            <annotation>
               <documentation>
                  
               </documentation>
            </annotation>
         </attribute>
      </complexType>
   </element>
   <element name="client">
      <complexType>
         <attribute name="class" type="string" use="required">
            <annotation>
               <documentation>
                  
               </documentation>
               <appinfo>
                  <meta.attribute kind="java" basedOn=":info.scce.cinco.gratext.IRestoreAction"/>
               </appinfo>
            </annotation>
         </attribute>
         <attribute name="fileExtension" type="string" use="required">
            <annotation>
               <documentation>
                  
               </documentation>
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