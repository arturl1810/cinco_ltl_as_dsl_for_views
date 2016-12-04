package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer

interface Templateable {
	 def CharSequence create(TemplateContainer tc);
}