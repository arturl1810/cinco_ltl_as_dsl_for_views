package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.StyledModelElement

interface Templateable {
	 def CharSequence create(GraphModel graphModel,ArrayList<StyledModelElement> nodes, ArrayList<StyledModelElement> edges);
}