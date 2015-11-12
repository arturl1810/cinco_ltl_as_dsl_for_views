package de.jabc.cinco.meta.plugin.gratext.template;

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.NodeDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Node;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

@SuppressWarnings("all")
public class GratextEcoreTemplate extends AbstractGratextTemplate {
  public static class E_Class {
    protected String name;
    
    protected String supertypes;
    
    protected Boolean isAbstract = Boolean.valueOf(false);
    
    protected Boolean isInterface = Boolean.valueOf(false);
    
    private List<GratextEcoreTemplate.E_Attribute> attributes = new ArrayList<GratextEcoreTemplate.E_Attribute>();
    
    private List<GratextEcoreTemplate.E_Reference> references = new ArrayList<GratextEcoreTemplate.E_Reference>();
    
    public E_Class(final String name) {
      this.name = name;
    }
    
    public GratextEcoreTemplate.E_Class add(final GratextEcoreTemplate.E_Attribute attr) {
      GratextEcoreTemplate.E_Class _xblockexpression = null;
      {
        this.attributes.add(attr);
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextEcoreTemplate.E_Class add(final GratextEcoreTemplate.E_Reference ref) {
      GratextEcoreTemplate.E_Class _xblockexpression = null;
      {
        this.references.add(ref);
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextEcoreTemplate.E_Class supertypes(final String types) {
      GratextEcoreTemplate.E_Class _xblockexpression = null;
      {
        this.supertypes = types;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public CharSequence toXMI() {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"");
      _builder.append(this.name, "");
      _builder.append("\" abstract=\"");
      _builder.append(this.isAbstract, "");
      _builder.append("\" interface=\"");
      _builder.append(this.isInterface, "");
      _builder.append("\" eSuperTypes=\"");
      _builder.append(this.supertypes, "");
      _builder.append("\">");
      _builder.newLineIfNotEmpty();
      {
        for(final GratextEcoreTemplate.E_Attribute attr : this.attributes) {
          CharSequence _xMI = attr.toXMI();
          _builder.append(_xMI, "");
        }
      }
      _builder.newLineIfNotEmpty();
      {
        for(final GratextEcoreTemplate.E_Reference ref : this.references) {
          CharSequence _xMI_1 = ref.toXMI();
          _builder.append(_xMI_1, "");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("</eClassifiers>");
      return _builder;
    }
  }
  
  public static class E_Interface extends GratextEcoreTemplate.E_Class {
    public E_Interface(final String name) {
      super(name);
      this.isAbstract = Boolean.valueOf(true);
      this.isInterface = Boolean.valueOf(true);
    }
  }
  
  public static class E_Attribute {
    protected String name;
    
    protected String type;
    
    protected String defaultValue;
    
    public E_Attribute(final String name, final String type) {
      this.name = name;
      this.type = type;
    }
    
    public GratextEcoreTemplate.E_Attribute defaultValue(final String value) {
      GratextEcoreTemplate.E_Attribute _xblockexpression = null;
      {
        this.defaultValue = value;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public CharSequence toXMI() {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EAttribute\" name=\"");
      _builder.append(this.name, "");
      _builder.append("\" eType=\"");
      _builder.append(this.type, "");
      _builder.append("\" defaultValueLiteral=\"");
      _builder.append(this.defaultValue, "");
      _builder.append("\"/>");
      return _builder;
    }
  }
  
  public static class E_Reference {
    protected String name;
    
    protected String type;
    
    protected boolean isContainment = false;
    
    protected int lower = 0;
    
    protected int upper = 1;
    
    public E_Reference(final String name, final String type) {
      this.name = name;
      this.type = type;
    }
    
    public GratextEcoreTemplate.E_Reference containment(final boolean flag) {
      GratextEcoreTemplate.E_Reference _xblockexpression = null;
      {
        this.isContainment = flag;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextEcoreTemplate.E_Reference lower(final int num) {
      GratextEcoreTemplate.E_Reference _xblockexpression = null;
      {
        this.lower = num;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextEcoreTemplate.E_Reference upper(final int num) {
      GratextEcoreTemplate.E_Reference _xblockexpression = null;
      {
        this.upper = num;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public CharSequence toXMI() {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EReference\" name=\"");
      _builder.append(this.name, "");
      _builder.append("\" eType=\"");
      _builder.append(this.type, "");
      _builder.append("\" containment=\"");
      _builder.append(this.isContainment, "");
      _builder.append("\" lowerBound=\"");
      _builder.append(this.lower, "");
      _builder.append("\" upperBound=\"");
      _builder.append(this.upper, "");
      _builder.append("\"/>");
      return _builder;
    }
  }
  
  public static class E_Type {
    protected final static String EInt = new Function0<String>() {
      public String apply() {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EInt");
        return _builder.toString();
      }
    }.apply();
    
    protected final static String EString = new Function0<String>() {
      public String apply() {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString");
        return _builder.toString();
      }
    }.apply();
    
    protected final static String EBoolean = new Function0<String>() {
      public String apply() {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EBoolean");
        return _builder.toString();
      }
    }.apply();
  }
  
  public ArrayList<GratextEcoreTemplate.E_Class> classes() {
    final ArrayList<GratextEcoreTemplate.E_Class> classes = new ArrayList<GratextEcoreTemplate.E_Class>();
    GratextEcoreTemplate.E_Class _e_Class = new GratextEcoreTemplate.E_Class("_Point");
    GratextEcoreTemplate.E_Attribute _e_Attribute = new GratextEcoreTemplate.E_Attribute("x", GratextEcoreTemplate.E_Type.EInt);
    GratextEcoreTemplate.E_Attribute _defaultValue = _e_Attribute.defaultValue("0");
    GratextEcoreTemplate.E_Class _add = _e_Class.add(_defaultValue);
    GratextEcoreTemplate.E_Attribute _e_Attribute_1 = new GratextEcoreTemplate.E_Attribute("y", GratextEcoreTemplate.E_Type.EInt);
    GratextEcoreTemplate.E_Attribute _defaultValue_1 = _e_Attribute_1.defaultValue("0");
    GratextEcoreTemplate.E_Class _add_1 = _add.add(_defaultValue_1);
    GratextEcoreTemplate.E_Class _e_Class_1 = new GratextEcoreTemplate.E_Class("_Placement");
    GratextEcoreTemplate.E_Class _supertypes = _e_Class_1.supertypes("#//_Point");
    GratextEcoreTemplate.E_Attribute _e_Attribute_2 = new GratextEcoreTemplate.E_Attribute("width", GratextEcoreTemplate.E_Type.EInt);
    GratextEcoreTemplate.E_Attribute _defaultValue_2 = _e_Attribute_2.defaultValue("-1");
    GratextEcoreTemplate.E_Class _add_2 = _supertypes.add(_defaultValue_2);
    GratextEcoreTemplate.E_Attribute _e_Attribute_3 = new GratextEcoreTemplate.E_Attribute("height", GratextEcoreTemplate.E_Type.EInt);
    GratextEcoreTemplate.E_Attribute _defaultValue_3 = _e_Attribute_3.defaultValue("-1");
    GratextEcoreTemplate.E_Class _add_3 = _add_2.add(_defaultValue_3);
    GratextEcoreTemplate.E_Interface _e_Interface = new GratextEcoreTemplate.E_Interface("_Placed");
    GratextEcoreTemplate.E_Reference _e_Reference = new GratextEcoreTemplate.E_Reference("placement", "#//_Placement");
    GratextEcoreTemplate.E_Reference _containment = _e_Reference.containment(true);
    GratextEcoreTemplate.E_Class _add_4 = _e_Interface.add(_containment);
    GratextEcoreTemplate.E_Class _e_Class_2 = new GratextEcoreTemplate.E_Class("_Route");
    GratextEcoreTemplate.E_Reference _e_Reference_1 = new GratextEcoreTemplate.E_Reference("points", "#//_Point");
    GratextEcoreTemplate.E_Reference _containment_1 = _e_Reference_1.containment(true);
    GratextEcoreTemplate.E_Reference _upper = _containment_1.upper((-1));
    GratextEcoreTemplate.E_Class _add_5 = _e_Class_2.add(_upper);
    GratextEcoreTemplate.E_Interface _e_Interface_1 = new GratextEcoreTemplate.E_Interface("_EdgeTarget");
    GratextEcoreTemplate.E_Interface _e_Interface_2 = new GratextEcoreTemplate.E_Interface("_EdgeSource");
    GratextEcoreTemplate.E_Reference _e_Reference_2 = new GratextEcoreTemplate.E_Reference("outgoingEdges", "#//_Edge");
    GratextEcoreTemplate.E_Reference _containment_2 = _e_Reference_2.containment(true);
    GratextEcoreTemplate.E_Reference _upper_1 = _containment_2.upper((-1));
    GratextEcoreTemplate.E_Class _add_6 = _e_Interface_2.add(_upper_1);
    GratextEcoreTemplate.E_Interface _e_Interface_3 = new GratextEcoreTemplate.E_Interface("_Edge");
    GratextEcoreTemplate.E_Attribute _e_Attribute_4 = new GratextEcoreTemplate.E_Attribute("target", GratextEcoreTemplate.E_Type.EString);
    GratextEcoreTemplate.E_Class _add_7 = _e_Interface_3.add(_e_Attribute_4);
    GratextEcoreTemplate.E_Reference _e_Reference_3 = new GratextEcoreTemplate.E_Reference("route", "#//_Route");
    GratextEcoreTemplate.E_Reference _containment_3 = _e_Reference_3.containment(true);
    GratextEcoreTemplate.E_Class _add_8 = _add_7.add(_containment_3);
    List<GratextEcoreTemplate.E_Class> _asList = Arrays.<GratextEcoreTemplate.E_Class>asList(_add_1, _add_3, _add_4, _add_5, _e_Interface_1, _add_6, _add_8);
    classes.addAll(_asList);
    return classes;
  }
  
  public String interfaces(final Node node) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<eSuperTypes href=\"#//_Placed\"/>");
    String str = _builder.toString();
    GraphModelDescriptor _model = this.model();
    NodeDescriptor<Node> _resp = _model.resp(node);
    boolean _isEdgeSource = _resp.isEdgeSource();
    if (_isEdgeSource) {
      String _str = str;
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("<eSuperTypes href=\"#//_EdgeSource\"/>");
      str = (_str + _builder_1);
    }
    return str;
  }
  
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?xml version=\"1.0\" encoding=\"ASCII\"?>");
    _builder.newLine();
    _builder.append("<ecore:EPackage xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:ecore=\"http://www.eclipse.org/emf/2002/Ecore\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("name=\"");
    ProjectDescriptor _project = this.project();
    String _acronym = _project.getAcronym();
    _builder.append(_acronym, "    ");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("nsURI=\"");
    GraphModel _graphmodel = this.graphmodel();
    String _nsURI = _graphmodel.getNsURI();
    _builder.append(_nsURI, "    ");
    _builder.append("/");
    ProjectDescriptor _project_1 = this.project();
    String _acronym_1 = _project_1.getAcronym();
    _builder.append(_acronym_1, "    ");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("nsPrefix=\"");
    ProjectDescriptor _project_2 = this.project();
    String _acronym_2 = _project_2.getAcronym();
    _builder.append(_acronym_2, "    ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("<eAnnotations source=\"http://www.eclipse.org/emf/2002/Ecore\">");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("</eAnnotations>");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"");
    GraphModelDescriptor _model = this.model();
    String _name = _model.getName();
    _builder.append(_name, "  ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("  \t ");
    _builder.append("<eSuperTypes href=\"");
    GraphModel _graphmodel_1 = this.graphmodel();
    String _nsURI_1 = _graphmodel_1.getNsURI();
    _builder.append(_nsURI_1, "  \t ");
    _builder.append("#//");
    GraphModelDescriptor _model_1 = this.model();
    String _name_1 = _model_1.getName();
    _builder.append(_name_1, "  \t ");
    _builder.append("\"/>");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("</eClassifiers>");
    _builder.newLine();
    {
      GraphModelDescriptor _model_2 = this.model();
      List<Node> _nodes = _model_2.getNodes();
      for(final Node node : _nodes) {
        _builder.append("  ");
        _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"");
        String _name_2 = node.getName();
        _builder.append(_name_2, "  ");
        _builder.append("\" abstract=\"");
        boolean _isIsAbstract = node.isIsAbstract();
        _builder.append(_isIsAbstract, "  ");
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("\t");
        _builder.append("<eSuperTypes href=\"");
        GraphModel _graphmodel_2 = this.graphmodel();
        String _nsURI_2 = _graphmodel_2.getNsURI();
        _builder.append(_nsURI_2, "  \t");
        _builder.append("#//");
        String _name_3 = node.getName();
        _builder.append(_name_3, "  \t");
        _builder.append("\"/>");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("\t");
        String _interfaces = this.interfaces(node);
        _builder.append(_interfaces, "  \t");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("</eClassifiers>");
        _builder.newLine();
      }
    }
    {
      GraphModelDescriptor _model_3 = this.model();
      List<Edge> _edges = _model_3.getEdges();
      for(final Edge edge : _edges) {
        _builder.append("  ");
        _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"");
        String _name_4 = edge.getName();
        _builder.append(_name_4, "  ");
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("\t");
        _builder.append("<eSuperTypes href=\"");
        GraphModel _graphmodel_3 = this.graphmodel();
        String _nsURI_3 = _graphmodel_3.getNsURI();
        _builder.append(_nsURI_3, "  \t");
        _builder.append("#//");
        String _name_5 = edge.getName();
        _builder.append(_name_5, "  \t");
        _builder.append("\"/>");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("\t");
        _builder.append("<eSuperTypes href=\"#//_Edge\"/>");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("</eClassifiers>");
        _builder.newLine();
      }
    }
    _builder.append("  ");
    {
      ArrayList<GratextEcoreTemplate.E_Class> _classes = this.classes();
      for(final GratextEcoreTemplate.E_Class cls : _classes) {
        CharSequence _xMI = cls.toXMI();
        _builder.append(_xMI, "  ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("</ecore:EPackage>");
    _builder.newLine();
    return _builder;
  }
}
