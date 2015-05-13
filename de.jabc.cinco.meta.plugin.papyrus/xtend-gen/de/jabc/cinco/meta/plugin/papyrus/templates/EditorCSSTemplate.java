package de.jabc.cinco.meta.plugin.papyrus.templates;

import com.google.common.base.Objects;
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import java.util.ArrayList;
import java.util.HashMap;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.StringExtensions;

@SuppressWarnings("all")
public class EditorCSSTemplate implements Templateable {
  public CharSequence createNodeCSS(final StyledNode styledNode) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(".devs.");
    GraphicalModelElement _modelElement = styledNode.getModelElement();
    String _name = _modelElement.getName();
    String _firstUpper = StringExtensions.toFirstUpper(_name);
    _builder.append(_firstUpper, "");
    _builder.append(" .label{");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("font-size: ");
    StyledLabel _styledLabel = styledNode.getStyledLabel();
    int _labelFontSize = _styledLabel.getLabelFontSize();
    _builder.append(_labelFontSize, "    ");
    _builder.append("px;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("font-family: ");
    StyledLabel _styledLabel_1 = styledNode.getStyledLabel();
    String _fontName = _styledLabel_1.getFontName();
    _builder.append(_fontName, "    ");
    _builder.append(", \'Lucida Sans Unicode\', sans-serif");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence create(final GraphModel graphModel, final ArrayList<StyledNode> nodes, final ArrayList<StyledEdge> edges, final HashMap<String,ArrayList<StyledNode>> groupedNodes, final ArrayList<ConnectionConstraint> validConnections) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/* CSS for Nodes */");
    _builder.newLine();
    {
      for(final StyledNode node : nodes) {
        {
          StyledLabel _styledLabel = node.getStyledLabel();
          boolean _notEquals = (!Objects.equal(_styledLabel, null));
          if (_notEquals) {
            CharSequence _createNodeCSS = this.createNodeCSS(node);
            _builder.append(_createNodeCSS, "");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
}
