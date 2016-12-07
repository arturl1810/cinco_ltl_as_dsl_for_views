package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import mgl.Annotation

interface AnnotationElementTemplateable {
	 def CharSequence create(Annotation annotation,StyledModelElement sme,TemplateContainer tc);
}