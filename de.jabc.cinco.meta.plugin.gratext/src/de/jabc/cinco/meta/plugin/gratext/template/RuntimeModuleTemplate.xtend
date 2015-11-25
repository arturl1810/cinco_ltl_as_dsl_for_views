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

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.linking.ILinker;
import org.eclipse.xtext.linking.impl.Linker;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.parser.DefaultEcoreElementFactory;
import org.eclipse.xtext.parser.IAstFactory;

public class «project.targetName»RuntimeModule extends «project.basePackage».Abstract«project.targetName»RuntimeModule {

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
    
    @Override
	public Class<? extends ILinker> bindILinker() {
		return MyLinker.class;
	}
	
	public static class MyLinker extends Linker {
		
		@Override
		protected boolean isClearAllReferencesRequired(Resource resource) {
			return false;
		}
	}
    
    @Override
	public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return «providerFile.nameWithoutExtension».class;
	}
}
'''
}