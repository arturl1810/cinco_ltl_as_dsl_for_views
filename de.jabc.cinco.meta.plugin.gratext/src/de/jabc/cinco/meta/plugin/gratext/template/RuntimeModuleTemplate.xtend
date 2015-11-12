package de.jabc.cinco.meta.plugin.gratext.template

class RuntimeModuleTemplate extends AbstractGratextTemplate {
	
def providerFile() {
	fileFromTemplate(GratextQualifiedNameProviderTemplate)
}
	
override template()
'''	
package «project.basePackage»;

import org.eclipse.xtext.naming.IQualifiedNameProvider;
import «providerFile.package».«providerFile.nameWithoutExtension»;

import graphmodel.Edge;
import graphmodel.Node;
import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.parser.DefaultEcoreElementFactory;
import org.eclipse.xtext.parser.IAstFactory;

public class «project.targetName»RuntimeModule extends «project.basePackage».Abstract«project.targetName»RuntimeModule {

	@Override
	public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return «providerFile.nameWithoutExtension».class;
	}
	
	@Override
	public Class<? extends IAstFactory> bindIAstFactory() {
		return MyAstFactory.class;
	}
	
	static public class MyAstFactory extends DefaultEcoreElementFactory {

		@Override
		public void add(EObject object, String feature, Object value, String ruleName, INode node) throws ValueConverterException {
			if (node.getSemanticElement() instanceof Edge) try {
				Edge edge = (Edge) node.getSemanticElement();
				Node source = (Node) node.getParent().getSemanticElement();
				edge.setSourceElement(source);
			} catch(Exception e) {
		    		e.printStackTrace();
		    }
			super.add(object, feature, value, ruleName, node);
		}
		
    }
}
'''
}