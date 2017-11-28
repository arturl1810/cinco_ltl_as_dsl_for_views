package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class QualifiedNameProviderTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextQualifiedNameProvider.java'''
	
	override template() '''	
		package «package»;
		
		import graphmodel.ModelElement;
		
		import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
		import org.eclipse.xtext.naming.QualifiedName;
		
		public class «model.name»GratextQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {
		
			@Override
			protected QualifiedName qualifiedName(Object obj) {
				if (obj instanceof ModelElement) {
			        return QualifiedName.create(((ModelElement) obj).getId());
				}
				else return super.qualifiedName(obj);
			}
			
		}
	'''
	
}