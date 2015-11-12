package de.jabc.cinco.meta.plugin.gratext.template;

import com.google.common.base.Objects;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ContainerDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ModelElementDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.NodeDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate;
import java.util.List;
import java.util.Set;
import mgl.Attribute;
import mgl.Edge;
import mgl.Enumeration;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.ReferencedType;
import mgl.UserDefinedType;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.IntegerRange;

@SuppressWarnings("all")
public class GratextGrammarTemplate extends AbstractGratextTemplate {
  public CharSequence modelRule() {
    CharSequence _xblockexpression = null;
    {
      GraphModelDescriptor _model = this.model();
      final Set<ModelElement> containables = _model.getNonAbstractContainables();
      StringConcatenation _builder = new StringConcatenation();
      GraphModelDescriptor _model_1 = this.model();
      String _name = _model_1.getName();
      _builder.append(_name, "");
      _builder.append(" returns ");
      GraphModelDescriptor _model_2 = this.model();
      String _name_1 = _model_2.getName();
      _builder.append(_name_1, "");
      _builder.append(":{");
      GraphModelDescriptor _model_3 = this.model();
      String _name_2 = _model_3.getName();
      _builder.append(_name_2, "");
      _builder.append("}");
      _builder.newLineIfNotEmpty();
      _builder.append("\'");
      GraphModelDescriptor _model_4 = this.model();
      String _name_3 = _model_4.getName();
      _builder.append(_name_3, "");
      _builder.append("\' (id = CincoID)?");
      _builder.newLineIfNotEmpty();
      _builder.append("(\'{\'");
      _builder.newLine();
      _builder.append("\t");
      GraphModel _graphmodel = this.graphmodel();
      CharSequence _attributes = this.attributes(_graphmodel);
      _builder.append(_attributes, "\t");
      _builder.newLineIfNotEmpty();
      {
        boolean _isEmpty = containables.isEmpty();
        boolean _not = (!_isEmpty);
        if (_not) {
          _builder.append("\t");
          _builder.append("( ( modelElements += ");
          ModelElement _get = ((ModelElement[])Conversions.unwrapArray(containables, ModelElement.class))[0];
          String _name_4 = _get.getName();
          _builder.append(_name_4, "\t");
          _builder.append(" )*");
          _builder.newLineIfNotEmpty();
          {
            int _size = containables.size();
            boolean _greaterThan = (_size > 1);
            if (_greaterThan) {
              {
                int _size_1 = containables.size();
                int _minus = (_size_1 - 1);
                IntegerRange _upTo = new IntegerRange(1, _minus);
                for(final Integer i : _upTo) {
                  _builder.append("\t");
                  _builder.append("& ( modelElements += ");
                  ModelElement _get_1 = ((ModelElement[])Conversions.unwrapArray(containables, ModelElement.class))[(i).intValue()];
                  String _name_5 = _get_1.getName();
                  _builder.append(_name_5, "\t");
                  _builder.append(" )*");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          _builder.append("\t");
          _builder.append(")");
          _builder.newLine();
        }
      }
      _builder.append("\'}\')?");
      _builder.newLine();
      _builder.append(";");
      _builder.newLine();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence containerRule(final NodeContainer node) {
    CharSequence _xblockexpression = null;
    {
      GraphModelDescriptor _model = this.model();
      ContainerDescriptor _resp = _model.resp(node);
      final Set<Edge> outEdges = _resp.getOutgoingEdges();
      GraphModelDescriptor _model_1 = this.model();
      ContainerDescriptor _resp_1 = _model_1.resp(node);
      final Set<ModelElement> containables = _resp_1.getNonAbstractContainables();
      StringConcatenation _builder = new StringConcatenation();
      String _name = node.getName();
      _builder.append(_name, "");
      _builder.append(" returns ");
      String _name_1 = node.getName();
      _builder.append(_name_1, "");
      _builder.append(":{");
      String _name_2 = node.getName();
      _builder.append(_name_2, "");
      _builder.append("}");
      _builder.newLineIfNotEmpty();
      _builder.append("\'");
      String _name_3 = node.getName();
      _builder.append(_name_3, "");
      _builder.append("\' (id = CincoID)? placement = Placement");
      _builder.newLineIfNotEmpty();
      _builder.append("(\'{\'");
      _builder.newLine();
      _builder.append("\t");
      CharSequence _attributes = this.attributes(node);
      _builder.append(_attributes, "\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      String _prime = this.prime(node);
      _builder.append(_prime, "\t");
      _builder.newLineIfNotEmpty();
      {
        boolean _isEmpty = containables.isEmpty();
        boolean _not = (!_isEmpty);
        if (_not) {
          _builder.append("\t");
          _builder.append("( ( modelElements += ");
          ModelElement _get = ((ModelElement[])Conversions.unwrapArray(containables, ModelElement.class))[0];
          String _name_4 = _get.getName();
          _builder.append(_name_4, "\t");
          _builder.append(" )*");
          _builder.newLineIfNotEmpty();
          {
            int _size = containables.size();
            boolean _greaterThan = (_size > 1);
            if (_greaterThan) {
              {
                int _size_1 = containables.size();
                int _minus = (_size_1 - 1);
                IntegerRange _upTo = new IntegerRange(1, _minus);
                for(final Integer i : _upTo) {
                  _builder.append("\t");
                  _builder.append("& ( modelElements += ");
                  ModelElement _get_1 = ((ModelElement[])Conversions.unwrapArray(containables, ModelElement.class))[(i).intValue()];
                  String _name_5 = _get_1.getName();
                  _builder.append(_name_5, "\t");
                  _builder.append(" )*");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          _builder.append("\t");
          _builder.append(")");
          _builder.newLine();
        }
      }
      {
        boolean _isEmpty_1 = outEdges.isEmpty();
        boolean _not_1 = (!_isEmpty_1);
        if (_not_1) {
          _builder.append("\t");
          _builder.append("( ( outgoingEdges += ");
          Edge _get_2 = ((Edge[])Conversions.unwrapArray(outEdges, Edge.class))[0];
          String _name_6 = _get_2.getName();
          _builder.append(_name_6, "\t");
          _builder.append(" )*");
          _builder.newLineIfNotEmpty();
          {
            int _size_2 = outEdges.size();
            boolean _greaterThan_1 = (_size_2 > 1);
            if (_greaterThan_1) {
              {
                int _size_3 = outEdges.size();
                int _minus_1 = (_size_3 - 1);
                IntegerRange _upTo_1 = new IntegerRange(1, _minus_1);
                for(final Integer i_1 : _upTo_1) {
                  _builder.append("\t");
                  _builder.append("& ( outgoingEdges += ");
                  Edge _get_3 = ((Edge[])Conversions.unwrapArray(outEdges, Edge.class))[(i_1).intValue()];
                  String _name_7 = _get_3.getName();
                  _builder.append(_name_7, "\t");
                  _builder.append(" )*");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          _builder.append("\t");
          _builder.append(")");
          _builder.newLine();
        }
      }
      _builder.append("\'}\')?");
      _builder.newLine();
      _builder.append(";");
      _builder.newLine();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence nodeRule(final Node node) {
    CharSequence _xblockexpression = null;
    {
      GraphModelDescriptor _model = this.model();
      NodeDescriptor<Node> _resp = _model.resp(node);
      final Set<Edge> outEdges = _resp.getOutgoingEdges();
      StringConcatenation _builder = new StringConcatenation();
      String _name = node.getName();
      _builder.append(_name, "");
      _builder.append(" returns ");
      String _name_1 = node.getName();
      _builder.append(_name_1, "");
      _builder.append(":{");
      String _name_2 = node.getName();
      _builder.append(_name_2, "");
      _builder.append("}");
      _builder.newLineIfNotEmpty();
      _builder.append("\'");
      String _name_3 = node.getName();
      _builder.append(_name_3, "");
      _builder.append("\' (id = CincoID)? placement = Placement");
      _builder.newLineIfNotEmpty();
      _builder.append("(\'{\'");
      _builder.newLine();
      _builder.append("\t");
      CharSequence _attributes = this.attributes(node);
      _builder.append(_attributes, "\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      String _prime = this.prime(node);
      _builder.append(_prime, "\t");
      _builder.newLineIfNotEmpty();
      {
        boolean _isEmpty = outEdges.isEmpty();
        boolean _not = (!_isEmpty);
        if (_not) {
          _builder.append("\t");
          _builder.append("( ( outgoingEdges += ");
          Edge _get = ((Edge[])Conversions.unwrapArray(outEdges, Edge.class))[0];
          String _name_4 = _get.getName();
          _builder.append(_name_4, "\t");
          _builder.append(" )*");
          _builder.newLineIfNotEmpty();
          {
            int _size = outEdges.size();
            boolean _greaterThan = (_size > 1);
            if (_greaterThan) {
              {
                int _size_1 = outEdges.size();
                int _minus = (_size_1 - 1);
                IntegerRange _upTo = new IntegerRange(1, _minus);
                for(final Integer i : _upTo) {
                  _builder.append("\t");
                  _builder.append("& ( outgoingEdges += ");
                  Edge _get_1 = ((Edge[])Conversions.unwrapArray(outEdges, Edge.class))[(i).intValue()];
                  String _name_5 = _get_1.getName();
                  _builder.append(_name_5, "\t");
                  _builder.append(" )*");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          _builder.append("\t");
          _builder.append(")");
          _builder.newLine();
        }
      }
      _builder.append("\'}\')?");
      _builder.newLine();
      _builder.append(";");
      _builder.newLine();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence edgeRule(final Edge edge) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = edge.getName();
    _builder.append(_name, "");
    _builder.append(" returns ");
    String _name_1 = edge.getName();
    _builder.append(_name_1, "");
    _builder.append(":{");
    String _name_2 = edge.getName();
    _builder.append(_name_2, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("\'-");
    String _name_3 = edge.getName();
    _builder.append(_name_3, "");
    _builder.append("->\' targetElement = [graphmodel::Node|CincoID]");
    _builder.newLineIfNotEmpty();
    _builder.append("(route = Route)?");
    _builder.newLine();
    _builder.append("(\'{\'");
    _builder.newLine();
    _builder.append("\t");
    CharSequence _attributes = this.attributes(edge);
    _builder.append(_attributes, "\t");
    _builder.newLineIfNotEmpty();
    _builder.append("\'}\')?");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence typeRule(final UserDefinedType type) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = type.getName();
    _builder.append(_name, "");
    _builder.append(" returns ");
    GraphModelDescriptor _model = this.model();
    String _acronym = _model.getAcronym();
    _builder.append(_acronym, "");
    _builder.append("::");
    String _name_1 = type.getName();
    _builder.append(_name_1, "");
    _builder.append(":{");
    GraphModelDescriptor _model_1 = this.model();
    String _acronym_1 = _model_1.getAcronym();
    _builder.append(_acronym_1, "");
    _builder.append("::");
    String _name_2 = type.getName();
    _builder.append(_name_2, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    CharSequence _attributes = this.attributes(type);
    _builder.append(_attributes, "");
    _builder.newLineIfNotEmpty();
    _builder.append(";");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence enumRule(final Enumeration type) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("enum ");
    String _name = type.getName();
    _builder.append(_name, "");
    _builder.append(" returns ");
    GraphModelDescriptor _model = this.model();
    String _acronym = _model.getAcronym();
    _builder.append(_acronym, "");
    _builder.append("::");
    String _name_1 = type.getName();
    _builder.append(_name_1, "");
    _builder.append(": ");
    _builder.newLineIfNotEmpty();
    _builder.append("\t");
    EList<String> _literals = type.getLiterals();
    String _get = _literals.get(0);
    _builder.append(_get, "\t");
    _builder.newLineIfNotEmpty();
    {
      EList<String> _literals_1 = type.getLiterals();
      int _size = _literals_1.size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        {
          EList<String> _literals_2 = type.getLiterals();
          int _size_1 = _literals_2.size();
          int _minus = (_size_1 - 1);
          IntegerRange _upTo = new IntegerRange(1, _minus);
          for(final Integer i : _upTo) {
            _builder.append("\t");
            _builder.append("| ");
            EList<String> _literals_3 = type.getLiterals();
            String _get_1 = _literals_3.get((i).intValue());
            _builder.append(_get_1, "\t");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append(";");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence type(final Attribute attr) {
    CharSequence _xifexpression = null;
    GraphModelDescriptor _model = this.model();
    String _type = attr.getType();
    boolean _contains = _model.contains(_type);
    if (_contains) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("[");
      GraphModelDescriptor _model_1 = this.model();
      String _acronym = _model_1.getAcronym();
      _builder.append(_acronym, "");
      _builder.append("::");
      String _type_1 = attr.getType();
      _builder.append(_type_1, "");
      _builder.append("|CincoID]");
      _xifexpression = _builder;
    } else {
      _xifexpression = attr.getType();
    }
    return _xifexpression;
  }
  
  public CharSequence attributes(final ModelElement element) {
    CharSequence _xblockexpression = null;
    {
      GraphModelDescriptor _model = this.model();
      ModelElementDescriptor<ModelElement> _resp = _model.resp(element);
      final List<Attribute> attrs = _resp.getAttributes();
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _isEmpty = attrs.isEmpty();
        boolean _not = (!_isEmpty);
        if (_not) {
          _builder.append("( ( \'");
          Attribute _get = attrs.get(0);
          String _name = _get.getName();
          _builder.append(_name, "");
          _builder.append("\' ");
          Attribute _get_1 = attrs.get(0);
          String _name_1 = _get_1.getName();
          _builder.append(_name_1, "");
          _builder.append(" = ");
          Attribute _get_2 = attrs.get(0);
          CharSequence _type = this.type(_get_2);
          _builder.append(_type, "");
          _builder.append(" )");
          _builder.newLineIfNotEmpty();
          {
            int _size = attrs.size();
            boolean _greaterThan = (_size > 1);
            if (_greaterThan) {
              {
                int _size_1 = attrs.size();
                int _minus = (_size_1 - 1);
                IntegerRange _upTo = new IntegerRange(1, _minus);
                for(final Integer i : _upTo) {
                  _builder.append("& ( \'");
                  Attribute _get_3 = attrs.get((i).intValue());
                  String _name_2 = _get_3.getName();
                  _builder.append(_name_2, "");
                  _builder.append("\' ");
                  Attribute _get_4 = attrs.get((i).intValue());
                  String _name_3 = _get_4.getName();
                  _builder.append(_name_3, "");
                  _builder.append(" = ");
                  Attribute _get_5 = attrs.get((i).intValue());
                  CharSequence _type_1 = this.type(_get_5);
                  _builder.append(_type_1, "");
                  _builder.append(" )");
                  _builder.newLineIfNotEmpty();
                }
              }
              _builder.append("\t\t");
            }
          }
          _builder.append(" )?");
          _builder.newLineIfNotEmpty();
        }
      }
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public String prime(final Node node) {
    final ReferencedType ref = ((Node) node).getPrimeReference();
    boolean _notEquals = (!Objects.equal(ref, null));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("( \'");
      String _name = ref.getName();
      _builder.append(_name, "");
      _builder.append("\' EString )");
      return _builder.toString();
    }
    return null;
  }
  
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("grammar ");
    ProjectDescriptor _project = this.project();
    String _basePackage = _project.getBasePackage();
    _builder.append(_basePackage, "");
    _builder.append(".");
    ProjectDescriptor _project_1 = this.project();
    String _targetName = _project_1.getTargetName();
    _builder.append(_targetName, "");
    _builder.append(" with org.eclipse.xtext.common.Terminals");
    _builder.newLineIfNotEmpty();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("import \"");
    GraphModel _graphmodel = this.graphmodel();
    String _nsURI = _graphmodel.getNsURI();
    _builder.append(_nsURI, "");
    _builder.append("/");
    ProjectDescriptor _project_2 = this.project();
    String _acronym = _project_2.getAcronym();
    _builder.append(_acronym, "");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    _builder.append("import \"");
    GraphModel _graphmodel_1 = this.graphmodel();
    String _nsURI_1 = _graphmodel_1.getNsURI();
    _builder.append(_nsURI_1, "");
    _builder.append("\" as ");
    GraphModelDescriptor _model = this.model();
    String _acronym_1 = _model.getAcronym();
    _builder.append(_acronym_1, "");
    _builder.newLineIfNotEmpty();
    _builder.append("import \"http://www.jabc.de/cinco/gdl/graphmodel\" as graphmodel");
    _builder.newLine();
    _builder.append("import \"http://www.eclipse.org/emf/2002/Ecore\" as ecore");
    _builder.newLine();
    _builder.newLine();
    CharSequence _modelRule = this.modelRule();
    _builder.append(_modelRule, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      GraphModelDescriptor _model_1 = this.model();
      List<NodeContainer> _nonAbstractContainers = _model_1.getNonAbstractContainers();
      for(final NodeContainer node : _nonAbstractContainers) {
        CharSequence _containerRule = this.containerRule(node);
        _builder.append(_containerRule, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      GraphModelDescriptor _model_2 = this.model();
      List<Node> _nonAbstractNonContainerNodes = _model_2.getNonAbstractNonContainerNodes();
      for(final Node node_1 : _nonAbstractNonContainerNodes) {
        CharSequence _nodeRule = this.nodeRule(node_1);
        _builder.append(_nodeRule, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      GraphModelDescriptor _model_3 = this.model();
      List<Edge> _nonAbstractEdges = _model_3.getNonAbstractEdges();
      for(final Edge edge : _nonAbstractEdges) {
        CharSequence _edgeRule = this.edgeRule(edge);
        _builder.append(_edgeRule, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      GraphModelDescriptor _model_4 = this.model();
      List<UserDefinedType> _types = _model_4.getTypes();
      for(final UserDefinedType type : _types) {
        CharSequence _typeRule = this.typeRule(type);
        _builder.append(_typeRule, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      GraphModelDescriptor _model_5 = this.model();
      List<Enumeration> _enumerations = _model_5.getEnumerations();
      for(final Enumeration type_1 : _enumerations) {
        CharSequence _enumRule = this.enumRule(type_1);
        _builder.append(_enumRule, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("Placement returns _Placement:{_Placement}");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("( (\'at\' x=EInt \',\' y=EInt)?");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("& (\'size\' width=EInt \',\' height=EInt)? )");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Route returns _Route:{_Route}");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("\'via\' (points += Point)+");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("Point returns _Point:{_Point}");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("\'(\' x = EInt \',\' y = EInt \')\'");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("CincoID: ID (\'-\' ID)*;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("EString returns ecore::EString:");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("STRING | ID;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("EInt returns ecore::EInt:");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("INT");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("ELong returns ecore::ELong:");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("SIGN? INT");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("EDouble returns ecore::EDouble:");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("SIGN? INT? \'.\' INT");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("EBoolean returns ecore::EBoolean:");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("\'true\' | \'false\'");
    _builder.newLine();
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("terminal SIGN : \'+\' | \'-\' ;");
    _builder.newLine();
    return _builder;
  }
}
