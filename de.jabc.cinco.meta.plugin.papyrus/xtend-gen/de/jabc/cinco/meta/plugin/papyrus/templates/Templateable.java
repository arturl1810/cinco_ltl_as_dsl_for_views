package de.jabc.cinco.meta.plugin.papyrus.templates;

import de.jabc.cinco.meta.plugin.papyrus.StyledModelElement;
import java.util.ArrayList;
import mgl.GraphModel;

@SuppressWarnings("all")
public interface Templateable {
  public abstract CharSequence create(final GraphModel graphModel, final ArrayList<StyledModelElement> nodes, final ArrayList<StyledModelElement> edges);
}
