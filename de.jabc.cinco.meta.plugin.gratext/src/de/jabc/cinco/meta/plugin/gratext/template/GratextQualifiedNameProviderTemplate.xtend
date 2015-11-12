package de.jabc.cinco.meta.plugin.gratext.template

class GratextQualifiedNameProviderTemplate extends AbstractGratextTemplate {
	
override template()
'''	
package «project.basePackage».scoping;

import graphmodel.ModelElement;

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;

public class «project.targetName»QualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {

	@Override
	protected QualifiedName qualifiedName(Object obj) {
		if (obj instanceof ModelElement) {
//			Package p = (Package) ((ModelElement) obj).eContainer();
	        return QualifiedName.create(((ModelElement) obj).getId());
		}
		else return super.qualifiedName(obj);
	}
	
}
'''
}