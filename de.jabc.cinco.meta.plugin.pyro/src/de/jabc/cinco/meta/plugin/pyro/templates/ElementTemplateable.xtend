package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer

interface ElementTemplateable {
	 def CharSequence create(StyledModelElement sme,TemplateContainer element);
}