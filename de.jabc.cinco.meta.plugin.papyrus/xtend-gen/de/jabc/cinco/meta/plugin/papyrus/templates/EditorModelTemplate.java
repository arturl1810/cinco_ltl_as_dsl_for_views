package de.jabc.cinco.meta.plugin.papyrus.templates;

import de.jabc.cinco.meta.plugin.papyrus.StyledModelElement;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import java.util.ArrayList;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.StringExtensions;

@SuppressWarnings("all")
public class EditorModelTemplate implements Templateable {
  public CharSequence create(final GraphModel graphModel, final ArrayList<StyledModelElement> nodes, final ArrayList<StyledModelElement> edges) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Created by zweihoff on 07.04.15.");
    _builder.newLine();
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
    _builder.append("/*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------Define Nodes Containers---------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("-------------------------------------------------------");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
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
    _builder.append("    ");
    _builder.append("GraphModel: [\' \',\'text\']");
    _builder.newLine();
    _builder.append("};");
    _builder.newLine();
    _builder.newLine();
    _builder.append("joint.shapes.devs.BigAtomic = joint.shapes.devs.Model.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.BigAtomic\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'BigAtomic\',    //Cinco Name");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Node\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {              //Cinco Attributes");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("ionising: [{ selected: \'one\', choices : [\'one\',\'two\',\'three\'] }, \'map\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("size: { width: 120, height: 120 }, //Cinco Style Size");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: 120,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("height: 120,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("fill: \'#ffffff\', //Background");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#ffb176\',//Foreground");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'stroke-width\' : 2 //linewidth");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-size\': 14,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-family\': \'Arial\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}, //Defined text in STYLE");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: (120 + (edgeTriggerWidth*2) ), height: (120 + (edgeTriggerWidth*2) )");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//inPorts: [\'\']");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}, joint.shapes.devs.Model.prototype.defaults),");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("setLabel: function() {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var attributes = this.attributes.cinco_attrs;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.attr(\'.label\',{ text: \'L: \'+getAttributeLabel(attributes.ionising),fill: \'#ffb176\'}); //How the label is rendered");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* SmallAtomic");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.SmallAtomic = joint.shapes.devs.Model.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.SmallAtomic\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'SmallAtomic\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Node\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("radiation: [0.00, \'double\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("size: { width: 80, height: 80 },");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: 80,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("height: 80,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("fill: \'#ffffff\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#ffb176\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'stroke-width\': 3");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-size\': 10");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}, //Cinco Label");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: (80 + (edgeTriggerWidth*2)), height: (80 + (edgeTriggerWidth*2))");
    _builder.newLine();
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
    _builder.append("var attributes = this.attributes.cinco_attrs;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.attr(\'.label\',{ text: \'L: \'+getAttributeLabel(attributes.radiation),fill: \'#ffb176\'});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* BigAtmoic");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.Coupled = joint.shapes.devs.Model.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: joint.util.deepSupplement({");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Coupled\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'Coupled\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Container\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("name: [\' \', \'text\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("value: [0, \'number\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("valid: [true, \'boolean\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("size: { width: 200, height: 300 },");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: 200,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("height: 300,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("fill: \'#ffffff\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#7c68fc\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'stroke-width\': 3");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-size\': 18");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}, //Cinco Label");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: (200+ edgeTriggerWidth*2), height: (300 + edgeTriggerWidth*2)");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
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
    _builder.append("this.attr(\'.label\',{ text: \'L: \'+getAttributeLabel(attributes.name),fill: \'blue\'});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* AtomToCoupled");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.AtomToCoupledYellow = joint.dia.Link.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Link\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'AtomToCoupledYellow\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Edge\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("atom : [\' \',\'text\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.connection\': { stroke: \'yellow\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-source\': { fill: \'white\',stroke: \'white\', d: \'M 0 0 L 0 0 L 0 0 z\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-target\': { fill: \'white\',stroke: \'yellow\', d: \'M 10 0 L 0 5 L 10 10 z\' }");
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
    _builder.append("//EDGE STYLE");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//Position: 1(target), 0(source)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//fill: text-color");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//font-size");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.set(\'labels\', [{ position: 0.5, attrs: { text: { dy: -10, text: \'L: \'+getAttributeLabel(attributes.atom), fill: \'yellow\', \'font-size\': 16 }}}]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* AtomToCoupled");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.AtomToCoupledBlue = joint.dia.Link.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Link\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'AtomToCoupledBlue\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Edge\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("atom : [\' \',\'text\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.connection\': { stroke: \'blue\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-source\': { fill: \'white\',stroke: \'white\', d: \'M 0 0 L 0 0 L 0 0 z\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-target\': { fill: \'white\',stroke: \'blue\', d: \'M 10 0 L 0 5 L 10 10 z\' }");
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
    _builder.append("//EDGE STYLE");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//Position: 1(target), 0(source)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//fill: text-color");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//font-size");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.set(\'labels\', [{ position: 0.5, attrs: { text: { dy: -10, text: \'L: \'+getAttributeLabel(attributes.atom), fill: \'blue\', \'font-size\': 16 }}}]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* CoupledToAtom");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @type {void|*}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("joint.shapes.devs.CoupledToAtom = joint.dia.Link.extend({");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("defaults: {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("type: \'devs.Link\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_name: \'CoupledToAtom\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_type: \'Edge\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("cinco_attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("coupled : [\' \',\'text\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.connection\': { stroke: \'red\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("//fill: backgroundColor, stroke: foreGroundColor");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("//d: M 0 0 L 0 0 L 0 0 z NO ARROW");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("//d: M 10 0 L 0 5 L 10 10 z DEFAULT ARROW");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-source\': { fill: \'white\',stroke: \'white\', d: \'M 0 0 L 0 0 L 0 0 z\' },");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.marker-target\': { fill: \'white\',stroke: \'red\', d: \'M 10 0 L 0 5 L 10 10 z\' }");
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
    _builder.append("//EDGE STYLE");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//Position: 1(target), 0(source)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//fill: text-color");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//font-size");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("this.set(\'labels\', [{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("position: 0.5,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("attrs: {text: {dy: -10, text: \'L: \' + getAttributeLabel(attributes.coupled), fill: \'red\', \'font-size\': 16}}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);");
    _builder.newLine();
    _builder.append("joint.shapes.devs.BigAtomicView = joint.shapes.devs.ModelView;");
    _builder.newLine();
    _builder.append("joint.shapes.devs.SmallAtomicView = joint.shapes.devs.ModelView;");
    _builder.newLine();
    _builder.append("joint.shapes.devs.CoupledView = joint.shapes.devs.ModelView;");
    _builder.newLine();
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (typeof exports === \'object\') {");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("module.exports = joint.shapes.devs;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence createNode(final StyledModelElement styledModelElement) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\t");
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    GraphicalModelElement _modelElement = styledModelElement.getModelElement();
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
    GraphicalModelElement _modelElement_1 = styledModelElement.getModelElement();
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
    GraphicalModelElement _modelElement_2 = styledModelElement.getModelElement();
    String _name_2 = _modelElement_2.getName();
    String _firstUpper_2 = StringExtensions.toFirstUpper(_name_2);
    _builder.append(_firstUpper_2, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("cinco_name: \'");
    GraphicalModelElement _modelElement_3 = styledModelElement.getModelElement();
    String _name_3 = _modelElement_3.getName();
    String _firstUpper_3 = StringExtensions.toFirstUpper(_name_3);
    _builder.append(_firstUpper_3, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("cinco_type: \'Container\',");
    _builder.newLine();
    _builder.append("        ");
    GraphicalModelElement _modelElement_4 = styledModelElement.getModelElement();
    CharSequence _createAttributes = this.createAttributes(_modelElement_4);
    _builder.append(_createAttributes, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("size: { width: 200, height: 300 },");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("attrs: {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: 200,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("height: 300,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("fill: \'#ffffff\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("stroke: \'#7c68fc\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'stroke-width\': 3");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.label\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'font-size\': 18");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}, //Cinco Label");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'.port-body\': {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("width: (200+ edgeTriggerWidth*2), height: (300 + edgeTriggerWidth*2)");
    _builder.newLine();
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
    _builder.append("this.attr(\'.label\',{ text: \'L: \'+getAttributeLabel(attributes.name),fill: \'blue\'});");
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
    _builder.append("            ");
    _builder.append("name: [\' \', \'text\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("value: [0, \'number\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("valid: [true, \'boolean\']");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
