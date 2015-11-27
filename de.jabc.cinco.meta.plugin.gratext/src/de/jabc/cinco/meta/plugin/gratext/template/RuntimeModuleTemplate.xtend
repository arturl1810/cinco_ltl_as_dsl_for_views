package de.jabc.cinco.meta.plugin.gratext.template

class RuntimeModuleTemplate extends AbstractGratextTemplate {
	
def providerFile() {
	fileFromTemplate(GratextQualifiedNameProviderTemplate)
}
	
override template()
'''	
package «project.basePackage»;

import «providerFile.package».«providerFile.nameWithoutExtension»;

import graphmodel.Edge;
import graphmodel.Node;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.common.util.DiagnosticChain;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EValidator;
import org.eclipse.emf.ecore.EValidator.Registry;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.linking.ILinker;
import org.eclipse.xtext.linking.impl.Linker;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.parser.DefaultEcoreElementFactory;
import org.eclipse.xtext.parser.IAstFactory;

public class «project.targetName»RuntimeModule extends «project.basePackage».Abstract«project.targetName»RuntimeModule {

	@Override
	public Class<? extends IAstFactory> bindIAstFactory() {
		return MyAstFactory.class;
	}
	
	static class MyAstFactory extends DefaultEcoreElementFactory {

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
	
	static class MyLinker extends Linker {
		
		@Override
		protected boolean isClearAllReferencesRequired(Resource resource) {
			return false;
		}
	}
    
    @Override
	public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return «providerFile.nameWithoutExtension».class;
	}
	
	@Override
	public Registry bindEValidatorRegistry() {
		return new MyEValidatorRegistry();
	}
	
	static class MyEValidatorRegistry implements Registry {

		static Registry instance = EValidator.Registry.INSTANCE;
		
		@Override
		public int size() {
			return instance.size();
		}

		@Override
		public boolean isEmpty() {
			return instance.isEmpty();
		}

		@Override
		public boolean containsKey(Object key) {
			return instance.containsKey(key);
		}

		@Override
		public boolean containsValue(Object value) {
			return instance.containsValue(value);
		}

		@Override
		public Object get(Object key) {
«««			if (key == null) {
				return new EValidator() {

					@Override
					public boolean validate(EObject eObject,
							DiagnosticChain diagnostics,
							Map<Object, Object> context) {
						return true;
					}

					@Override
					public boolean validate(EClass eClass, EObject eObject,
							DiagnosticChain diagnostics,
							Map<Object, Object> context) {
						return true;
					}

					@Override
					public boolean validate(EDataType eDataType, Object value,
							DiagnosticChain diagnostics,
							Map<Object, Object> context) {
						return true;
					}
					
				};
«««			}
		}

		@Override
		public Object put(EPackage key, Object value) {
			return instance.put(key, value);
		}

		@Override
		public Object remove(Object key) {
			return instance.remove(key);
		}

		@Override
		public void putAll(Map<? extends EPackage, ? extends Object> m) {
			instance.putAll(m);
		}

		@Override
		public void clear() {
			instance.clear();
		}

		@Override
		public Set<EPackage> keySet() {
			return instance.keySet();
		}

		@Override
		public Collection<Object> values() {
			return instance.values();
		}

		@Override
		public Set<java.util.Map.Entry<EPackage, Object>> entrySet() {
			return instance.entrySet();
		}

		@Override
		public EValidator getEValidator(EPackage ePackage) {
			return instance.getEValidator(ePackage);
		}
	}
}
'''
}