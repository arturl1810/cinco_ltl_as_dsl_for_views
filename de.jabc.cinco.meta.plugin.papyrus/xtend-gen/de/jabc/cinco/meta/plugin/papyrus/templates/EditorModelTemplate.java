package de.jabc.cinco.meta.plugin.papyrus.templates;

import com.google.common.base.Objects;
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.NodeShape;
import de.jabc.cinco.meta.plugin.papyrus.model.PolygonPoint;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import java.util.ArrayList;
import java.util.HashMap;
import mgl.Attribute;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class EditorModelTemplate implements Templateable {
  public CharSequence create(final GraphModel graphModel, final ArrayList<StyledNode> nodes, final ArrayList<StyledEdge> edges, final HashMap<String,ArrayList<StyledNode>> groupedNodes, final ArrayList<ConnectionConstraint> validConnections) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\t\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("* Created by papyrus cinco meta plugin");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("* For Graphmodel ");
    String _name = graphModel.getName();
    _builder.append(_name, "	 ");
    _builder.newLineIfNotEmpty();
    _builder.append("\t ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("if (typeof exports === \'object\') {");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t    ");
    _builder.append("var joint = {");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("util: require(\'../src/core\').util,");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("shapes: {");
    _builder.newLine();
    _builder.append("\t            ");
    _builder.append("basic: require(\'./joint.shapes.basic\')");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("dia: {");
    _builder.newLine();
    _builder.append("\t            ");
    _builder.append("ElementView: require(\'../src/joint.dia.element\').ElementView,");
    _builder.newLine();
    _builder.append("\t            ");
    _builder.append("Link: require(\'../src/joint.dia.link\').Link");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t    ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("\t    ");
    _builder.append("var _ = require(\'lodash\');");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("joint.shapes.devs = {};");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* RECTANGLE Rounded");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.ModelRect = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("type_name: \'modelRect\',");
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
    _builder.append("type: \'devs.ModelRect\',");
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
    _builder.append("\'.scalable\' :{");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("transform : \"scale(0.5,0.5)\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
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
    _builder.append("\'transform\':\'translate(-10,-10)\',");
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
    _builder.append("\'.label\': { text: \'ModelRect\', \'ref-x\': .5, \'ref-y\': 10, ref: \'.body\', \'text-anchor\': \'middle\' },");
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
    _builder.append("attrs[portSelector] = { ref: \'.body\', \'ref-y\': (0), \'ref-x\' : (0) };");
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
    _builder.append("* ELLIPSE");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.ModelEllipse = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("type_name: \'modelEllipse\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("markup: \'<g class=\"rotatable\"><g class=\"scalable\"><g class=\"inPorts\"/><g class=\"outPorts\"/><ellipse class=\"body\"/></g><text class=\"label\"/></g>\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("portMarkup: \'<g class=\"port port<%= id %>\"><ellipse class=\"port-body\"/><text class=\"port-label\"/></g>\',");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.ModelEllipse\',");
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
    _builder.append("\'.scalable\' :{");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("transform : \"scale(1,1)\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.\': { magnet: false },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#ffffff\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("cx: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("cy: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("rx: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("ry: 0");
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
    _builder.append("stroke: \'#ffffff\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("cx: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("cy: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("rx: 0,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("ry: 0");
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
    _builder.append("attrs[portSelector] = { ref: \'.body\', \'ref-y\': (0), \'ref-x\' : (0) };");
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
    _builder.append("* POLYGON");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.ModelPolygon = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("type_name: \'modelPolygon\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("markup: \'<g class=\"rotatable\"><g class=\"scalable\"><g class=\"inPorts\"/><g class=\"outPorts\"/><polygon class=\"body\"/></g><text class=\"label\"/></g>\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("portMarkup: \'<g class=\"port port<%= id %>\"><polygon class=\"port-body\"/><text class=\"port-label\"/></g>\',");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.ModelPolygon\',");
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
    _builder.append("\'.scalable\' :{");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("transform : \"scale(0.5,0.5)\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.\': { magnet: false },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("points: \'0,0 50,50 100,0\', //Polygon Points");
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
    _builder.append("attrs[portSelector] = { ref: \'.body\', \'ref-y\':0, \'ref-x\' :0 };");
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
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("* GraphModel Attributes");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("* @type {{GraphModel: string[]}}");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("cinco_graphModelAttr = {");
    _builder.newLine();
    {
      EList<Attribute> _attributes = graphModel.getAttributes();
      boolean _hasElements = false;
      for(final Attribute attr : _attributes) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "	    ");
        }
        _builder.append("\t    ");
        CharSequence _createAttribute = this.createAttribute(attr);
        _builder.append(_createAttribute, "	    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("\t");
    _builder.append("};");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("/*");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("-------------Define Nodes and Containers---------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("\t ");
    _builder.newLine();
    {
      for(final StyledNode node : nodes) {
        _builder.append("\t");
        CharSequence _createNode = this.createNode(node);
        _builder.append(_createNode, "	");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("\t");
    _builder.append("/*");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("---------------------Define Edges----------------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append("\t ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("\t ");
    _builder.newLine();
    {
      for(final StyledEdge edge : edges) {
        _builder.append("\t");
        CharSequence _createEdge = this.createEdge(edge);
        _builder.append(_createEdge, "	");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);");
    _builder.newLine();
    {
      for(final StyledNode node_1 : nodes) {
        _builder.append("\t");
        _builder.append("joint.shapes.devs.");
        GraphicalModelElement _modelElement = node_1.getModelElement();
        String _name_1 = _modelElement.getName();
        _builder.append(_name_1, "	");
        _builder.append("View = joint.shapes.devs.ModelView;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("if (typeof exports === \'object\') {");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("\t    ");
    _builder.append("module.exports = joint.shapes.devs;");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createEdge(final StyledEdge styledEdge) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method labelColor is undefined for the type EditorModelTemplate"
      + "\nThe method labelFontSize is undefined for the type EditorModelTemplate");
  }
  
  public CharSequence createEdgeDecorator(final StyledConnector styledConnector) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method m1 is undefined for the type EditorModelTemplate"
      + "\nThe method m2 is undefined for the type EditorModelTemplate"
      + "\nThe method l11 is undefined for the type EditorModelTemplate"
      + "\nThe method l12 is undefined for the type EditorModelTemplate"
      + "\nThe method l21 is undefined for the type EditorModelTemplate"
      + "\nThe method l22 is undefined for the type EditorModelTemplate");
  }
  
  public CharSequence createNodeShape(final StyledNode styledNode) {
    StringConcatenation _builder = new StringConcatenation();
    {
      NodeShape _nodeShape = styledNode.getNodeShape();
      boolean _equals = Objects.equal(_nodeShape, NodeShape.ELLIPSE);
      if (_equals) {
        _builder.append("ModelEllipse");
        _builder.newLine();
      } else {
        NodeShape _nodeShape_1 = styledNode.getNodeShape();
        boolean _equals_1 = Objects.equal(_nodeShape_1, NodeShape.POLYGON);
        if (_equals_1) {
          _builder.append("ModelPolygon");
          _builder.newLine();
        } else {
          _builder.append("ModelRect");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  public CharSequence createNodeShapeBody(final StyledNode styledNode) {
    StringConcatenation _builder = new StringConcatenation();
    {
      NodeShape _nodeShape = styledNode.getNodeShape();
      boolean _equals = Objects.equal(_nodeShape, NodeShape.ELLIPSE);
      if (_equals) {
        _builder.append("cx: 0,");
        _builder.newLine();
        _builder.append("cy: 0,");
        _builder.newLine();
        _builder.append("rx: ");
        int _width = styledNode.getWidth();
        int _divide = (_width / 2);
        _builder.append(_divide, "");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("ry: ");
        int _height = styledNode.getHeight();
        int _divide_1 = (_height / 2);
        _builder.append(_divide_1, "");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
      } else {
        NodeShape _nodeShape_1 = styledNode.getNodeShape();
        boolean _equals_1 = Objects.equal(_nodeShape_1, NodeShape.POLYGON);
        if (_equals_1) {
          _builder.append("points: \'");
          {
            ArrayList<PolygonPoint> _polygonPoints = styledNode.getPolygonPoints();
            boolean _hasElements = false;
            for(final PolygonPoint p : _polygonPoints) {
              if (!_hasElements) {
                _hasElements = true;
              } else {
                _builder.appendImmediate(" ", "");
              }
              String _string = p.toString();
              _builder.append(_string, "");
            }
          }
          _builder.append("\',");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("width: ");
          int _width_1 = styledNode.getWidth();
          _builder.append(_width_1, "");
          _builder.append(",");
          _builder.newLineIfNotEmpty();
          _builder.append("height: ");
          int _width_2 = styledNode.getWidth();
          _builder.append(_width_2, "");
          _builder.append(",");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  public CharSequence createNodeShapePortBody(final StyledNode styledNode) {
    StringConcatenation _builder = new StringConcatenation();
    {
      NodeShape _nodeShape = styledNode.getNodeShape();
      boolean _equals = Objects.equal(_nodeShape, NodeShape.ELLIPSE);
      if (_equals) {
        _builder.append("cx: 8,");
        _builder.newLine();
        _builder.append("cy: 8,");
        _builder.newLine();
        _builder.append("rx: ");
        int _width = styledNode.getWidth();
        int _divide = (_width / 2);
        int _minus = (_divide - 6);
        _builder.append(_minus, "");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("ry: ");
        int _height = styledNode.getHeight();
        int _divide_1 = (_height / 2);
        int _minus_1 = (_divide_1 - 6);
        _builder.append(_minus_1, "");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("//\'x-ref\':");
        _builder.newLine();
        _builder.append("width: (");
        int _width_1 = styledNode.getWidth();
        int _plus = (_width_1 + 5);
        _builder.append(_plus, "");
        _builder.append("),");
        _builder.newLineIfNotEmpty();
        _builder.append("height: (");
        int _height_1 = styledNode.getHeight();
        int _plus_1 = (_height_1 + 5);
        _builder.append(_plus_1, "");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      } else {
        NodeShape _nodeShape_1 = styledNode.getNodeShape();
        boolean _equals_1 = Objects.equal(_nodeShape_1, NodeShape.POLYGON);
        if (_equals_1) {
          _builder.append("\'transform\':\'translate(-10,-10)\',");
          _builder.newLine();
          _builder.append("points: \'");
          _builder.newLine();
          {
            ArrayList<PolygonPoint> _polygonPoints = styledNode.getPolygonPoints();
            boolean _hasElements = false;
            for(final PolygonPoint p : _polygonPoints) {
              if (!_hasElements) {
                _hasElements = true;
              } else {
                _builder.appendImmediate(" ", "");
              }
              int _x = p.getX();
              double _multiply = (_x * 1.2);
              _builder.append(_multiply, "");
              _builder.append(",");
              int _y = p.getY();
              double _multiply_1 = (_y * 1.2);
              _builder.append(_multiply_1, "");
              _builder.newLineIfNotEmpty();
              _builder.append("\t");
            }
          }
          _builder.append("\',");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("width: ");
          int _width_2 = styledNode.getWidth();
          int _plus_2 = (_width_2 + 20);
          _builder.append(_plus_2, "");
          _builder.append(",");
          _builder.newLineIfNotEmpty();
          _builder.append("height: ");
          int _width_3 = styledNode.getWidth();
          int _plus_3 = (_width_3 + 20);
          _builder.append(_plus_3, "");
          _builder.append(",");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  public CharSequence createNode(final StyledNode styledNode) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method labelFontSize is undefined for the type EditorModelTemplate"
      + "\nThe method fontName is undefined for the type EditorModelTemplate"
      + "\nThe method fontType is undefined for the type EditorModelTemplate"
      + "\nThe method labelColor is undefined for the type EditorModelTemplate"
      + "\nThe method labelFontSize is undefined for the type EditorModelTemplate"
      + "\nThe method fontName is undefined for the type EditorModelTemplate"
      + "\nThe method fontType is undefined for the type EditorModelTemplate");
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
