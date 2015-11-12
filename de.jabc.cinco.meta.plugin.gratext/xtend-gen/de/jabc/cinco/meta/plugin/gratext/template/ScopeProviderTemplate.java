package de.jabc.cinco.meta.plugin.gratext.template;

import de.jabc.cinco.meta.plugin.gratext.descriptor.EdgeDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate;
import java.util.List;
import java.util.Set;
import mgl.Edge;
import mgl.Node;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class ScopeProviderTemplate extends AbstractGratextTemplate {
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("package ");
    ProjectDescriptor _project = this.project();
    String _basePackage = _project.getBasePackage();
    _builder.append(_basePackage, "");
    _builder.append(".scoping");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("import graphmodel.Node");
    _builder.newLine();
    _builder.append("import ");
    ProjectDescriptor _project_1 = this.project();
    String _basePackage_1 = _project_1.getBasePackage();
    _builder.append(_basePackage_1, "");
    _builder.append(".*");
    _builder.newLineIfNotEmpty();
    _builder.append("import java.util.ArrayList");
    _builder.newLine();
    _builder.append("import org.eclipse.emf.ecore.EObject");
    _builder.newLine();
    _builder.append("import org.eclipse.emf.ecore.EReference");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.EcoreUtil2");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.naming.QualifiedName");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.scoping.IScope");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.scoping.Scopes");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This class contains custom scoping description.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    ProjectDescriptor _project_2 = this.project();
    String _targetName = _project_2.getTargetName();
    _builder.append(_targetName, "");
    _builder.append("ScopeProvider extends AbstractDeclarativeScopeProvider {");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("\t");
    _builder.append("override getScope(EObject context, EReference reference) {");
    _builder.newLine();
    {
      GraphModelDescriptor _model = this.model();
      List<Edge> _nonAbstractEdges = _model.getNonAbstractEdges();
      for(final Edge edge : _nonAbstractEdges) {
        _builder.append("\t\t");
        _builder.append("if (context instanceof ");
        String _name = edge.getName();
        _builder.append(_name, "\t\t");
        _builder.append(") { ");
        _builder.newLineIfNotEmpty();
        _builder.append("\t\t");
        _builder.append("\t\t");
        _builder.append("if (reference.name.equals(\"targetElement\")) {");
        _builder.newLine();
        _builder.append("\t\t");
        _builder.append("\t\t\t");
        _builder.append("val root = EcoreUtil2.getRootContainer(context)");
        _builder.newLine();
        _builder.append("\t        \t\t");
        _builder.append("val candidates = new ArrayList<Node>");
        _builder.newLine();
        {
          GraphModelDescriptor _model_1 = this.model();
          EdgeDescriptor _resp = _model_1.resp(edge);
          Set<Node> _targetNodes = _resp.getTargetNodes();
          for(final Node node : _targetNodes) {
            _builder.append("\t        \t\t");
            _builder.append("candidates.addAll(EcoreUtil2.getAllContentsOfType(root, ");
            String _name_1 = node.getName();
            _builder.append(_name_1, "\t        \t\t");
            _builder.append("))");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("\t        \t\t");
        _builder.append("return Scopes.scopeFor(candidates, [ QualifiedName::create(it.id) ], IScope.NULLSCOPE)");
        _builder.newLine();
        _builder.append("        \t\t");
        _builder.append("}");
        _builder.newLine();
        _builder.append("\t\t");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("\t\t");
    _builder.append("super.getScope(context, reference)");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
