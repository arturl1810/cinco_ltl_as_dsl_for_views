package de.jabc.cinco.meta.plugin.gratext.template;

import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class GratextQualifiedNameProviderTemplate extends AbstractGratextTemplate {
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("package ");
    ProjectDescriptor _project = this.project();
    String _basePackage = _project.getBasePackage();
    _builder.append(_basePackage, "");
    _builder.append(".scoping;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("import graphmodel.ModelElement;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;");
    _builder.newLine();
    _builder.append("import org.eclipse.xtext.naming.QualifiedName;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("public class ");
    ProjectDescriptor _project_1 = this.project();
    String _targetName = _project_1.getTargetName();
    _builder.append(_targetName, "");
    _builder.append("QualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("\t");
    _builder.append("@Override");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("protected QualifiedName qualifiedName(Object obj) {");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("if (obj instanceof ModelElement) {");
    _builder.newLine();
    _builder.append("//\t\t\tPackage p = (Package) ((ModelElement) obj).eContainer();");
    _builder.newLine();
    _builder.append("\t        ");
    _builder.append("return QualifiedName.create(((ModelElement) obj).getId());");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t\t");
    _builder.append("else return super.qualifiedName(obj);");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
