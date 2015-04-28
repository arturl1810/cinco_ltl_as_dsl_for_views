package de.jabc.cinco.meta.plugin.papyrus.templates;

import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;
import java.util.ArrayList;
import java.util.HashMap;
import mgl.GraphModel;

@SuppressWarnings("all")
public interface Templateable {
  public abstract CharSequence create(final GraphModel graphModel, final ArrayList<StyledNode> nodes, final ArrayList<StyledEdge> edges, final HashMap<String,ArrayList<StyledNode>> groupedNodes, final ArrayList<ConnectionConstraint> validConnections);
}
