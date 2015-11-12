package de.jabc.cinco.meta.plugin.gratext.template;

import de.jabc.cinco.meta.core.utils.URIHandler;
import de.jabc.cinco.meta.plugin.gratext.descriptor.FileDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Node;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.xmi.XMIResource;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

@SuppressWarnings("all")
public class GratextGenmodelTemplate extends AbstractGratextTemplate {
  public static class E_Class {
    protected String name;
    
    protected String supertypes;
    
    protected Boolean isInterface = Boolean.valueOf(false);
    
    private List<GratextGenmodelTemplate.E_Attribute> attributes = new ArrayList<GratextGenmodelTemplate.E_Attribute>();
    
    private List<GratextGenmodelTemplate.E_Reference> references = new ArrayList<GratextGenmodelTemplate.E_Reference>();
    
    public E_Class(final String name) {
      this.name = name;
    }
    
    public GratextGenmodelTemplate.E_Class add(final GratextGenmodelTemplate.E_Attribute attr) {
      GratextGenmodelTemplate.E_Class _xblockexpression = null;
      {
        this.attributes.add(attr);
        attr.classname = this.name;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextGenmodelTemplate.E_Class add(final GratextGenmodelTemplate.E_Reference ref) {
      GratextGenmodelTemplate.E_Class _xblockexpression = null;
      {
        this.references.add(ref);
        ref.classname = this.name;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextGenmodelTemplate.E_Class supertypes(final String types) {
      GratextGenmodelTemplate.E_Class _xblockexpression = null;
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
      _builder.append(this.isInterface, "");
      _builder.append("\" interface=\"");
      _builder.append(this.isInterface, "");
      _builder.append("\" eSuperTypes=\"");
      _builder.append(this.supertypes, "");
      _builder.append("\">");
      _builder.newLineIfNotEmpty();
      {
        for(final GratextGenmodelTemplate.E_Attribute attr : this.attributes) {
          CharSequence _xMI = attr.toXMI();
          _builder.append(_xMI, "");
        }
      }
      _builder.newLineIfNotEmpty();
      {
        for(final GratextGenmodelTemplate.E_Reference ref : this.references) {
          CharSequence _xMI_1 = ref.toXMI();
          _builder.append(_xMI_1, "");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("</eClassifiers>");
      return _builder;
    }
    
    public CharSequence toGenmodelXMI(final String ecoreClass) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<genClasses ecoreClass=\"");
      _builder.append(ecoreClass, "");
      _builder.append("#//");
      _builder.append(this.name, "");
      _builder.append("\">");
      _builder.newLineIfNotEmpty();
      _builder.append("\t    ");
      {
        for(final GratextGenmodelTemplate.E_Attribute attr : this.attributes) {
          CharSequence _genmodelXMI = attr.toGenmodelXMI(ecoreClass);
          _builder.append(_genmodelXMI, "\t    ");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("\t    ");
      {
        for(final GratextGenmodelTemplate.E_Reference ref : this.references) {
          CharSequence _genmodelXMI_1 = ref.toGenmodelXMI(ecoreClass);
          _builder.append(_genmodelXMI_1, "\t    ");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("</genClasses>");
      _builder.newLine();
      return _builder;
    }
  }
  
  public static class E_Interface extends GratextGenmodelTemplate.E_Class {
    public E_Interface(final String name) {
      super(name);
      this.isInterface = Boolean.valueOf(false);
    }
  }
  
  public static class E_Attribute {
    protected String name;
    
    protected String classname;
    
    protected String type;
    
    protected String defaultValue;
    
    public E_Attribute(final String name, final String type) {
      this.name = name;
      this.type = type;
    }
    
    public GratextGenmodelTemplate.E_Attribute defaultValue(final String value) {
      GratextGenmodelTemplate.E_Attribute _xblockexpression = null;
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
    
    public CharSequence toGenmodelXMI(final String ecoreClass) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<genFeatures createChild=\"false\" ecoreFeature=\"ecore:EAttribute ");
      _builder.append(ecoreClass, "");
      _builder.append("#//");
      _builder.append(this.classname, "");
      _builder.append("/");
      _builder.append(this.name, "");
      _builder.append("\"/>");
      return _builder;
    }
  }
  
  public static class E_Reference {
    protected String name;
    
    protected String classname;
    
    protected String type;
    
    protected boolean isContainment = false;
    
    protected int lower = 0;
    
    protected int upper = 1;
    
    public E_Reference(final String name, final String type) {
      this.name = name;
      this.type = type;
    }
    
    public GratextGenmodelTemplate.E_Reference containment(final boolean flag) {
      GratextGenmodelTemplate.E_Reference _xblockexpression = null;
      {
        this.isContainment = flag;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextGenmodelTemplate.E_Reference lower(final int num) {
      GratextGenmodelTemplate.E_Reference _xblockexpression = null;
      {
        this.lower = num;
        _xblockexpression = this;
      }
      return _xblockexpression;
    }
    
    public GratextGenmodelTemplate.E_Reference upper(final int num) {
      GratextGenmodelTemplate.E_Reference _xblockexpression = null;
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
    
    public CharSequence toGenmodelXMI(final String ecoreClass) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<genFeatures property=\"None\" children=\"true\" createChild=\"true\" ecoreFeature=\"ecore:EReference ");
      _builder.append(ecoreClass, "");
      _builder.append("#//");
      _builder.append(this.classname, "");
      _builder.append("/");
      _builder.append(this.name, "");
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
  
  public FileDescriptor ecoreFile() {
    return this.fileFromTemplate(GratextEcoreTemplate.class);
  }
  
  public ArrayList<GratextGenmodelTemplate.E_Class> classes() {
    final ArrayList<GratextGenmodelTemplate.E_Class> classes = new ArrayList<GratextGenmodelTemplate.E_Class>();
    GratextGenmodelTemplate.E_Class _e_Class = new GratextGenmodelTemplate.E_Class("_Point");
    GratextGenmodelTemplate.E_Attribute _e_Attribute = new GratextGenmodelTemplate.E_Attribute("x", GratextGenmodelTemplate.E_Type.EInt);
    GratextGenmodelTemplate.E_Attribute _defaultValue = _e_Attribute.defaultValue("0");
    GratextGenmodelTemplate.E_Class _add = _e_Class.add(_defaultValue);
    GratextGenmodelTemplate.E_Attribute _e_Attribute_1 = new GratextGenmodelTemplate.E_Attribute("y", GratextGenmodelTemplate.E_Type.EInt);
    GratextGenmodelTemplate.E_Attribute _defaultValue_1 = _e_Attribute_1.defaultValue("0");
    GratextGenmodelTemplate.E_Class _add_1 = _add.add(_defaultValue_1);
    GratextGenmodelTemplate.E_Class _e_Class_1 = new GratextGenmodelTemplate.E_Class("_Placement");
    GratextGenmodelTemplate.E_Class _supertypes = _e_Class_1.supertypes("#//_Point");
    GratextGenmodelTemplate.E_Attribute _e_Attribute_2 = new GratextGenmodelTemplate.E_Attribute("width", GratextGenmodelTemplate.E_Type.EInt);
    GratextGenmodelTemplate.E_Attribute _defaultValue_2 = _e_Attribute_2.defaultValue("-1");
    GratextGenmodelTemplate.E_Class _add_2 = _supertypes.add(_defaultValue_2);
    GratextGenmodelTemplate.E_Attribute _e_Attribute_3 = new GratextGenmodelTemplate.E_Attribute("height", GratextGenmodelTemplate.E_Type.EInt);
    GratextGenmodelTemplate.E_Attribute _defaultValue_3 = _e_Attribute_3.defaultValue("-1");
    GratextGenmodelTemplate.E_Class _add_3 = _add_2.add(_defaultValue_3);
    GratextGenmodelTemplate.E_Interface _e_Interface = new GratextGenmodelTemplate.E_Interface("_Placed");
    GratextGenmodelTemplate.E_Reference _e_Reference = new GratextGenmodelTemplate.E_Reference("placement", "#//_Placement");
    GratextGenmodelTemplate.E_Reference _containment = _e_Reference.containment(true);
    GratextGenmodelTemplate.E_Class _add_4 = _e_Interface.add(_containment);
    GratextGenmodelTemplate.E_Class _e_Class_2 = new GratextGenmodelTemplate.E_Class("_Route");
    GratextGenmodelTemplate.E_Reference _e_Reference_1 = new GratextGenmodelTemplate.E_Reference("points", "#//_Point");
    GratextGenmodelTemplate.E_Reference _containment_1 = _e_Reference_1.containment(true);
    GratextGenmodelTemplate.E_Reference _upper = _containment_1.upper((-1));
    GratextGenmodelTemplate.E_Class _add_5 = _e_Class_2.add(_upper);
    GratextGenmodelTemplate.E_Interface _e_Interface_1 = new GratextGenmodelTemplate.E_Interface("_EdgeTarget");
    GratextGenmodelTemplate.E_Interface _e_Interface_2 = new GratextGenmodelTemplate.E_Interface("_EdgeSource");
    GratextGenmodelTemplate.E_Reference _e_Reference_2 = new GratextGenmodelTemplate.E_Reference("outgoingEdges", "#//_Edge");
    GratextGenmodelTemplate.E_Reference _containment_2 = _e_Reference_2.containment(true);
    GratextGenmodelTemplate.E_Reference _upper_1 = _containment_2.upper((-1));
    GratextGenmodelTemplate.E_Class _add_6 = _e_Interface_2.add(_upper_1);
    GratextGenmodelTemplate.E_Interface _e_Interface_3 = new GratextGenmodelTemplate.E_Interface("_Edge");
    GratextGenmodelTemplate.E_Reference _e_Reference_3 = new GratextGenmodelTemplate.E_Reference("route", "#//_Route");
    GratextGenmodelTemplate.E_Reference _containment_3 = _e_Reference_3.containment(true);
    GratextGenmodelTemplate.E_Class _add_7 = _e_Interface_3.add(_containment_3);
    GratextGenmodelTemplate.E_Reference _e_Reference_4 = new GratextGenmodelTemplate.E_Reference("target", "#//_EdgeTarget");
    GratextGenmodelTemplate.E_Reference _containment_4 = _e_Reference_4.containment(true);
    GratextGenmodelTemplate.E_Class _add_8 = _add_7.add(_containment_4);
    List<GratextGenmodelTemplate.E_Class> _asList = Arrays.<GratextGenmodelTemplate.E_Class>asList(_add_1, _add_3, _add_4, _add_5, _e_Interface_1, _add_6, _add_8);
    classes.addAll(_asList);
    GraphModel _graphmodel = this.graphmodel();
    EList<Edge> _edges = _graphmodel.getEdges();
    final Consumer<Edge> _function = new Consumer<Edge>() {
      public void accept(final Edge edge) {
        String _name = edge.getName();
        String _plus = ("_" + _name);
        String _plus_1 = (_plus + "Target");
        GratextGenmodelTemplate.E_Interface _e_Interface = new GratextGenmodelTemplate.E_Interface(_plus_1);
        GratextGenmodelTemplate.E_Class _supertypes = _e_Interface.supertypes("#//_EdgeTarget");
        classes.add(_supertypes);
      }
    };
    _edges.forEach(_function);
    return classes;
  }
  
  public String genmodel() {
    try {
      final GenModel genModel = this.createGenModel();
      final ByteArrayOutputStream bops = new ByteArrayOutputStream();
      final HashMap<String, Object> optionMap = new HashMap<String, Object>();
      Map<String, Object> _context = this.ctx.getContext();
      Object _get = _context.get("ePackage");
      URIHandler _uRIHandler = new URIHandler(((EPackage) _get));
      optionMap.put(XMIResource.OPTION_URI_HANDLER, _uRIHandler);
      String _name = StandardCharsets.UTF_8.name();
      optionMap.put(XMIResource.OPTION_ENCODING, _name);
      Resource _eResource = genModel.eResource();
      _eResource.save(bops, optionMap);
      String _name_1 = StandardCharsets.UTF_8.name();
      return bops.toString(_name_1);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<genmodel:GenModel xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:ecore=\"http://www.eclipse.org/emf/2002/Ecore\" xmlns:genmodel=\"http://www.eclipse.org/emf/2002/GenModel\" runtimeVersion=\"2.10\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("modelName=\"");
    ProjectDescriptor _project = this.project();
    String _targetName = _project.getTargetName();
    _builder.append(_targetName, "    ");
    _builder.append("\" complianceLevel=\"8.0\" copyrightFields=\"false\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("modelDirectory=\"/");
    ProjectDescriptor _project_1 = this.project();
    String _symbolicName = _project_1.getSymbolicName();
    _builder.append(_symbolicName, "    ");
    _builder.append("/model-gen\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("modelPluginID=\"");
    ProjectDescriptor _project_2 = this.project();
    String _symbolicName_1 = _project_2.getSymbolicName();
    _builder.append(_symbolicName_1, "    ");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("editPluginID=\"");
    ProjectDescriptor _project_3 = this.project();
    String _symbolicName_2 = _project_3.getSymbolicName();
    _builder.append(_symbolicName_2, "    ");
    _builder.append(".edit\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("editorPluginID=\"");
    ProjectDescriptor _project_4 = this.project();
    String _symbolicName_3 = _project_4.getSymbolicName();
    _builder.append(_symbolicName_3, "    ");
    _builder.append(".editor\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("testsPluginID=\"");
    ProjectDescriptor _project_5 = this.project();
    String _symbolicName_4 = _project_5.getSymbolicName();
    _builder.append(_symbolicName_4, "    ");
    _builder.append(".tests\">");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("<genPackages prefix=\"");
    ProjectDescriptor _project_6 = this.project();
    String _targetName_1 = _project_6.getTargetName();
    _builder.append(_targetName_1, "  ");
    _builder.append("\" basePackage=\"");
    GraphModelDescriptor _model = this.model();
    String _basePackage = _model.getBasePackage();
    _builder.append(_basePackage, "  ");
    _builder.append("\" disposableProviderFactory=\"true\" ecorePackage=\"");
    FileDescriptor _ecoreFile = this.ecoreFile();
    String _name = _ecoreFile.getName();
    _builder.append(_name, "  ");
    _builder.append("#/\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<genClasses ecoreClass=\"");
    FileDescriptor _ecoreFile_1 = this.ecoreFile();
    String _name_1 = _ecoreFile_1.getName();
    _builder.append(_name_1, "    ");
    _builder.append("#//");
    GraphModelDescriptor _model_1 = this.model();
    String _name_2 = _model_1.getName();
    _builder.append(_name_2, "    ");
    _builder.append("\"/>");
    _builder.newLineIfNotEmpty();
    {
      GraphModelDescriptor _model_2 = this.model();
      List<Node> _nodes = _model_2.getNodes();
      for(final Node node : _nodes) {
        _builder.append("    ");
        _builder.append("<genClasses ecoreClass=\"");
        FileDescriptor _ecoreFile_2 = this.ecoreFile();
        String _name_3 = _ecoreFile_2.getName();
        _builder.append(_name_3, "    ");
        _builder.append("#//");
        String _name_4 = node.getName();
        _builder.append(_name_4, "    ");
        _builder.append("\"/>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      GraphModelDescriptor _model_3 = this.model();
      List<Edge> _edges = _model_3.getEdges();
      for(final Edge edge : _edges) {
        _builder.append("    ");
        _builder.append("<genClasses ecoreClass=\"");
        FileDescriptor _ecoreFile_3 = this.ecoreFile();
        String _name_5 = _ecoreFile_3.getName();
        _builder.append(_name_5, "    ");
        _builder.append("#//");
        String _name_6 = edge.getName();
        _builder.append(_name_6, "    ");
        _builder.append("\"/>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    {
      ArrayList<GratextGenmodelTemplate.E_Class> _classes = this.classes();
      for(final GratextGenmodelTemplate.E_Class cls : _classes) {
        FileDescriptor _ecoreFile_4 = this.ecoreFile();
        String _name_7 = _ecoreFile_4.getName();
        CharSequence _genmodelXMI = cls.toGenmodelXMI(_name_7);
        _builder.append(_genmodelXMI, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("</genPackages>");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("<usedGenPackages href=\"platform:/resource/");
    String _modelProjectSymbolicName = this.ctx.getModelProjectSymbolicName();
    _builder.append(_modelProjectSymbolicName, "  ");
    _builder.append("/src-gen/model/");
    GraphModelDescriptor _model_4 = this.model();
    String _name_8 = _model_4.getName();
    _builder.append(_name_8, "  ");
    _builder.append(".genmodel#//");
    GraphModelDescriptor _model_5 = this.model();
    String _acronym = _model_5.getAcronym();
    _builder.append(_acronym, "  ");
    _builder.append("\"/>");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("<usedGenPackages href=\"platform:/plugin/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.genmodel#//graphmodel\"/>");
    _builder.newLine();
    _builder.append("</genmodel:GenModel>");
    _builder.newLine();
    return _builder;
  }
}
