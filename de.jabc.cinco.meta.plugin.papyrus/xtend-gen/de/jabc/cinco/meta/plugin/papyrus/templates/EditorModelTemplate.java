package de.jabc.cinco.meta.plugin.papyrus.templates;

import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import de.jabc.cinco.meta.plugin.papyrus.utils.Formatter;
import java.util.ArrayList;
import java.util.HashMap;
import mgl.Attribute;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import style.Color;

@SuppressWarnings("all")
public class EditorModelTemplate implements Templateable {
  public CharSequence create(final GraphModel graphModel, final ArrayList<StyledNode> nodes, final ArrayList<StyledEdge> edges, final HashMap<String,ArrayList<StyledNode>> groupedNodes, final ArrayList<ConnectionConstraint> validConnections) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Created by papyrus cinco meta plugin");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For Graphmodel ");
    String _name = graphModel.getName();
    _builder.append(_name, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (typeof exports === \'object\') {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var joint = {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("util: require(\'../src/core\').util,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("shapes: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("basic: require(\'./joint.shapes.basic\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("dia: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("ElementView: require(\'../src/joint.dia.element\').ElementView,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("Link: require(\'../src/joint.dia.link\').Link");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var _ = require(\'lodash\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("joint.shapes.devs = {};");
    _builder.newLine();
    _builder.newLine();
    _builder.append("joint.shapes.devs.Model = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("type_name: \'model\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("markup: \'<g class=\"rotatable\"><g class=\"scalable\"><g class=\"inPorts\"/><g class=\"outPorts\"/><rect class=\"body\"/></g><text class=\"label\"/></g>\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("portMarkup: \'<g class=\"port port<%= id %>\"><rect class=\"port-body\"/><text class=\"port-label\"/></g>\',");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Model\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_id: \'0\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'NoName\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'element\',");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("inPorts: [\'\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("outPorts: [],");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.\': { magnet: false },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#ffffff\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("magnet: false,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("fill: \'#transparent\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#ffffff\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("text: {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'pointer-events\': \'none\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': { text: \'Model\', \'ref-x\': .5, \'ref-y\': 10, ref: \'.body\', \'text-anchor\': \'middle\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.inPorts .port-label\': { x:0, dy: 0, \'text-anchor\': \'end\', fill: \'#ffffff\'},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.outPorts .port-label\':{ x: 0, dy: 0, fill: \'#ffffff\' }");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}, joint.shapes.basic.Generic.prototype.defaults),");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("setLabel: function() {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("},");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("getPortAttrs: function(portName, index, total, selector, type) {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var attrs = {};");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var portClass = \'port\' + index;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var portSelector = selector + \'>.\' + portClass;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var portLabelSelector = portSelector + \'>.port-label\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var portBodySelector = portSelector + \'>.port-body\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs[portLabelSelector] = { text: portName };");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs[portBodySelector] = { port: { id: portName || _.uniqueId(type) , type: type } };");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs[portSelector] = { ref: \'.body\', \'ref-y\': (-0.9 * edgeTriggerWidth), \'ref-x\' : (-0.9 * edgeTriggerWidth) };");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (selector === \'.outPorts\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("attrs[portSelector] = { ref: \'.body\', \'ref-y\': (0), \'ref-x\' : (0) };");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return attrs;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* GraphModel Attributes");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {{GraphModel: string[]}}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("cinco_graphModelAttr = {");
    _builder.newLine();
    {
      EList<Attribute> _attributes = graphModel.getAttributes();
      boolean _hasElements = false;
      for(final Attribute attr : _attributes) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "    ");
        }
        _builder.append("    ");
        CharSequence _createAttribute = this.createAttribute(attr);
        _builder.append(_createAttribute, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("};");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------Define Nodes and Containers---------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append(" ");
    _builder.newLine();
    {
      for(final StyledNode node : nodes) {
        CharSequence _createNode = this.createNode(node);
        _builder.append(_createNode, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("/*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("---------------------Define Edges----------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append(" ");
    _builder.newLine();
    {
      for(final StyledEdge edge : edges) {
        CharSequence _createEdge = this.createEdge(edge);
        _builder.append(_createEdge, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);");
    _builder.newLine();
    {
      for(final StyledNode node_1 : nodes) {
        _builder.append("joint.shapes.devs.");
        GraphicalModelElement _modelElement = node_1.getModelElement();
        String _name_1 = _modelElement.getName();
        _builder.append(_name_1, "");
        _builder.append(" = joint.shapes.devs.ModelView;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("if (typeof exports === \'object\') {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("module.exports = joint.shapes.devs;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createEdge(final StyledEdge styledEdge) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    GraphicalModelElement _modelElement = styledEdge.getModelElement();
    String _name = _modelElement.getName();
    String _firstUpper = StringExtensions.toFirstUpper(_name);
    _builder.append(_firstUpper, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.");
    GraphicalModelElement _modelElement_1 = styledEdge.getModelElement();
    String _name_1 = _modelElement_1.getName();
    String _firstUpper_1 = StringExtensions.toFirstUpper(_name_1);
    _builder.append(_firstUpper_1, "");
    _builder.append(" = joint.dia.Link.extend({");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Link\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'");
    GraphicalModelElement _modelElement_2 = styledEdge.getModelElement();
    String _name_2 = _modelElement_2.getName();
    String _firstUpper_2 = StringExtensions.toFirstUpper(_name_2);
    _builder.append(_firstUpper_2, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("cinco_type: \'Edge\',");
    _builder.newLine();
    _builder.append("        ");
    GraphicalModelElement _modelElement_3 = styledEdge.getModelElement();
    CharSequence _createAttributes = this.createAttributes(_modelElement_3);
    _builder.append(_createAttributes, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.connection\': { ");
    _builder.newLine();
    _builder.append("            \t");
    _builder.append("stroke: \'#");
    Color _foregroundColor = styledEdge.getForegroundColor();
    String _hex = Formatter.toHex(_foregroundColor);
    _builder.append(_hex, "            	");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            \t");
    _builder.append("\'stroke-width\': ");
    int _lineWidth = styledEdge.getLineWidth();
    _builder.append(_lineWidth, "            	");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-source\': {");
    _builder.newLine();
    _builder.append("            \t");
    StyledConnector _sourceConnector = styledEdge.getSourceConnector();
    CharSequence _createEdgeDecorator = this.createEdgeDecorator(_sourceConnector);
    _builder.append(_createEdgeDecorator, "            	");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-target\': {");
    _builder.newLine();
    _builder.append("            \t");
    StyledConnector _targetConnector = styledEdge.getTargetConnector();
    CharSequence _createEdgeDecorator_1 = this.createEdgeDecorator(_targetConnector);
    _builder.append(_createEdgeDecorator_1, "            	");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("setLabel: function() {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Get the needed Attributes for the label");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var attributes = this.attributes.cinco_attrs;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.set(\'labels\', [");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        \t\t");
    _builder.append("position: ");
    double _labelLocation = styledEdge.getLabelLocation();
    _builder.append(_labelLocation, "        		");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        \t\t");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("        \t\t\t");
    _builder.append("text: {");
    _builder.newLine();
    _builder.append("        \t\t\t\t");
    _builder.append("dy: -10,");
    _builder.newLine();
    _builder.append("        \t\t\t\t");
    _builder.append("text: \'L: \'+getAttributeLabel(attributes.atom),");
    _builder.newLine();
    _builder.append("        \t\t\t\t");
    _builder.append("fill: \'#");
    Color _labelColor = styledEdge.getLabelColor();
    String _hex_1 = Formatter.toHex(_labelColor);
    _builder.append(_hex_1, "        				");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        \t\t\t\t");
    _builder.append("\'font-size\': ");
    int _labelFontSize = styledEdge.getLabelFontSize();
    _builder.append(_labelFontSize, "        				");
    _builder.newLineIfNotEmpty();
    _builder.append("        \t\t\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        \t\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createEdgeDecorator(final StyledConnector styledConnector) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("fill: \'#");
    Color _backgroundColor = styledConnector.getBackgroundColor();
    String _hex = Formatter.toHex(_backgroundColor);
    _builder.append(_hex, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("stroke: \'#");
    Color _backgroundColor_1 = styledConnector.getBackgroundColor();
    String _hex_1 = Formatter.toHex(_backgroundColor_1);
    _builder.append(_hex_1, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("d: \'M ");
    int _m1 = styledConnector.getM1();
    _builder.append(_m1, " ");
    _builder.append(" ");
    int _m2 = styledConnector.getM2();
    _builder.append(_m2, " ");
    _builder.append(" L ");
    int _l11 = styledConnector.getL11();
    _builder.append(_l11, " ");
    _builder.append(" ");
    int _l12 = styledConnector.getL12();
    _builder.append(_l12, " ");
    _builder.append(" L ");
    int _l21 = styledConnector.getL21();
    _builder.append(_l21, " ");
    _builder.append(" ");
    int _l22 = styledConnector.getL22();
    _builder.append(_l22, " ");
    _builder.append(" z\'");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence createNode(final StyledNode styledNode) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    GraphicalModelElement _modelElement = styledNode.getModelElement();
    String _name = _modelElement.getName();
    String _firstUpper = StringExtensions.toFirstUpper(_name);
    _builder.append(_firstUpper, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.");
    GraphicalModelElement _modelElement_1 = styledNode.getModelElement();
    Class<? extends GraphicalModelElement> _class = _modelElement_1.getClass();
    String _name_1 = _class.getName();
    String _firstUpper_1 = StringExtensions.toFirstUpper(_name_1);
    _builder.append(_firstUpper_1, "");
    _builder.append(" = joint.shapes.devs.Model.extend({");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.");
    GraphicalModelElement _modelElement_2 = styledNode.getModelElement();
    String _name_2 = _modelElement_2.getName();
    String _firstUpper_2 = StringExtensions.toFirstUpper(_name_2);
    _builder.append(_firstUpper_2, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("cinco_name: \'");
    GraphicalModelElement _modelElement_3 = styledNode.getModelElement();
    String _name_3 = _modelElement_3.getName();
    String _firstUpper_3 = StringExtensions.toFirstUpper(_name_3);
    _builder.append(_firstUpper_3, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("cinco_type: \'Node\',");
    _builder.newLine();
    _builder.append("        ");
    GraphicalModelElement _modelElement_4 = styledNode.getModelElement();
    CharSequence _createAttributes = this.createAttributes(_modelElement_4);
    _builder.append(_createAttributes, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("size: { ");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("width: ");
    int _width = styledNode.getWidth();
    _builder.append(_width, "        	");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        \t");
    _builder.append("height: ");
    int _height = styledNode.getHeight();
    _builder.append(_height, "        	");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: ");
    int _width_1 = styledNode.getWidth();
    _builder.append(_width_1, "                ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("height: ");
    int _width_2 = styledNode.getWidth();
    _builder.append(_width_2, "                ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("fill: \'#");
    Color _backgroundColor = styledNode.getBackgroundColor();
    String _hex = Formatter.toHex(_backgroundColor);
    _builder.append(_hex, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("stroke: \'#");
    Color _foregroundColor = styledNode.getForegroundColor();
    String _hex_1 = Formatter.toHex(_foregroundColor);
    _builder.append(_hex_1, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'stroke-width\': ");
    int _lineWidth = styledNode.getLineWidth();
    _builder.append(_lineWidth, "                ");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-size\': ");
    int _labelFontSize = styledNode.getLabelFontSize();
    _builder.append(_labelFontSize, "                ");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: (");
    int _width_3 = styledNode.getWidth();
    _builder.append(_width_3, "                ");
    _builder.append("+ edgeTriggerWidth*2),");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("height: (");
    int _height_1 = styledNode.getHeight();
    _builder.append(_height_1, "                ");
    _builder.append(" + edgeTriggerWidth*2)");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}, joint.shapes.devs.Model.prototype.defaults),");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("setLabel: function() {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Get the needed Attributes for the label");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var attributes = this.attributes.cinco_attrs;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.attr(\'.label\',{");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("text: \'L: \'+getAttributeLabel(attributes.name),");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("fill: \'#");
    Color _labelColor = styledNode.getLabelColor();
    String _hex_2 = Formatter.toHex(_labelColor);
    _builder.append(_hex_2, "        	");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        \t");
    _builder.append("\'font-size\': ");
    int _labelFontSize_1 = styledNode.getLabelFontSize();
    _builder.append(_labelFontSize_1, "        	");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createAttributes(final GraphicalModelElement modelElement) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    {
      EList<Attribute> _attributes = modelElement.getAttributes();
      boolean _hasElements = false;
      for(final Attribute attr : _attributes) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "");
        }
        CharSequence _createAttribute = this.createAttribute(attr);
        _builder.append(_createAttribute, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createAttribute(final Attribute attr) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EClass _eClass = attr.eClass();
      String _name = _eClass.getName();
      boolean _equals = _name.equals("EString");
      if (_equals) {
        String _name_1 = attr.getName();
        _builder.append(_name_1, "");
        _builder.append(": [\' \', \'text\']");
        _builder.newLineIfNotEmpty();
      } else {
        EClass _eClass_1 = attr.eClass();
        String _name_2 = _eClass_1.getName();
        boolean _equals_1 = _name_2.equals("EBoolean");
        if (_equals_1) {
          String _name_3 = attr.getName();
          _builder.append(_name_3, "");
          _builder.append(": [false, \'boolean\']");
          _builder.newLineIfNotEmpty();
        } else {
          EClass _eClass_2 = attr.eClass();
          String _name_4 = _eClass_2.getName();
          boolean _equals_2 = _name_4.equals("EList");
          if (_equals_2) {
            String _name_5 = attr.getName();
            _builder.append(_name_5, "");
            _builder.append(": [");
            _builder.newLineIfNotEmpty();
            _builder.append("\t");
            _builder.append("{ ");
            _builder.newLine();
            _builder.append("\t");
            _builder.append("selected: \'one\',");
            _builder.newLine();
            _builder.append("\t");
            _builder.append("choices : [\'one\',\'two\',\'three\']");
            _builder.newLine();
            _builder.append("\t");
            _builder.append("},");
            _builder.newLine();
            _builder.append("\t");
            _builder.append("\'map\']");
            _builder.newLine();
          } else {
            EClass _eClass_3 = attr.eClass();
            String _name_6 = _eClass_3.getName();
            boolean _equals_3 = _name_6.equals("EInt");
            if (_equals_3) {
              String _name_7 = attr.getName();
              _builder.append(_name_7, "");
              _builder.append(": [0, \'number\']");
              _builder.newLineIfNotEmpty();
            } else {
              EClass _eClass_4 = attr.eClass();
              String _name_8 = _eClass_4.getName();
              boolean _equals_4 = _name_8.equals("EDouble");
              if (_equals_4) {
                String _name_9 = attr.getName();
                _builder.append(_name_9, "");
                _builder.append(": [0.00, \'double\']");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    return _builder;
  }
}
