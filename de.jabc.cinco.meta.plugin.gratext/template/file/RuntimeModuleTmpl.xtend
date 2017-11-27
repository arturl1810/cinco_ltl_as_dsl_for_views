package file

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.GraphModel

class RuntimeModuleTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextRuntimeModule.java'''
	
	override template() '''	
		package «package»;
		
		import «package».generator.«model.name»GratextTransformer;
		import «package».scoping.«model.name»GratextQualifiedNameProvider;
		
		import graphmodel.Node;
		import graphmodel.internal.InternalEdge;
		import graphmodel.internal.InternalIdentifiableElement;
		import graphmodel.internal.InternalNode;
		import graphmodel.internal.InternalPackage;
		
		import java.util.Collection;
		import java.util.Collections;
		import java.util.List;
		import java.util.Map;
		import java.util.Set;
		
		import org.eclipse.emf.common.util.DiagnosticChain;
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EDataType;
		import org.eclipse.emf.ecore.EFactory;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.EPackage;
		import org.eclipse.emf.ecore.EReference;
		import org.eclipse.emf.ecore.EStructuralFeature;
		import org.eclipse.emf.ecore.EValidator;
		import org.eclipse.emf.ecore.EValidator.Registry;
		import org.eclipse.emf.ecore.resource.Resource;
		import org.eclipse.xtext.conversion.IValueConverterService;
		import org.eclipse.xtext.conversion.ValueConverterException;
		import org.eclipse.xtext.linking.ILinker;
		import org.eclipse.xtext.linking.ILinkingService;
		import org.eclipse.xtext.linking.impl.DefaultLinkingService;
		import org.eclipse.xtext.linking.impl.IllegalNodeException;
		import org.eclipse.xtext.linking.impl.Linker;
		import org.eclipse.xtext.naming.IQualifiedNameConverter;
		import org.eclipse.xtext.naming.IQualifiedNameProvider;
		import org.eclipse.xtext.naming.QualifiedName;
		import org.eclipse.xtext.nodemodel.INode;
		import org.eclipse.xtext.parser.DefaultEcoreElementFactory;
		import org.eclipse.xtext.parser.IAstFactory;
		import org.eclipse.xtext.resource.IEObjectDescription;
		import org.eclipse.xtext.resource.XtextResource;
		
		import com.google.inject.Inject;
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.Transformer;
		import de.jabc.cinco.meta.plugin.gratext.runtime.util.TerminalConverters;
		
		public class «model.name»GratextRuntimeModule extends «package».Abstract«model.name»GratextRuntimeModule {
		
			@Override
			public Class<? extends IValueConverterService> bindIValueConverterService() {
			    return TerminalConverters.class;
			}
		
			@Override
			public Class<? extends IAstFactory> bindIAstFactory() {
				return MyAstFactory.class;
			}
			
			static class MyAstFactory extends DefaultEcoreElementFactory {
		
				@Override
				public void add(EObject object, String feature, Object value, String ruleName, INode node) throws ValueConverterException {
					if (feature.startsWith("gratext_")) {
						feature = feature.substring(8);
						value = mapGratextFeatureValue(object, feature, value, ruleName, node);
					}
					if (node.getSemanticElement() instanceof InternalEdge) try {
						InternalEdge edge = (InternalEdge) node.getSemanticElement();
						InternalNode source = (InternalNode) node.getParent().getSemanticElement();
						EFactory fct = EPackage.Registry.INSTANCE.getEFactory("«model.nsURI»");
						Node sourceBase = (Node) fct.create(source.eClass());
						sourceBase.setInternalElement(source);
						edge.setSourceElement(sourceBase);
					} catch(Exception e) {
				    		e.printStackTrace();
				    }
					super.add(object, feature, value, ruleName, node);
				}
						
				@Override
				public void set(EObject object, String feature, Object value, String ruleName, INode node) throws ValueConverterException {
					if (feature.startsWith("gratext_")) {
						feature = feature.substring(8);
						value = mapGratextFeatureValue(object, feature, value, ruleName, node);
					}
					super.set(object, feature, value, ruleName, node);
				}
				
				private Object mapGratextFeatureValue(EObject object, String featureName, Object value, String ruleName, INode node) {
					final EStructuralFeature structuralFeature = object.eClass().getEStructuralFeature(featureName);
					if (structuralFeature instanceof EReference) {
						value = getTokenValue(value, ruleName, node);
						if (value instanceof EObject) {
							final EObject eObj = (EObject) value;
							final EClass requiredType = ((EReference) structuralFeature).getEReferenceType();
							if (!isInternal(requiredType) && isInternal(eObj.eClass())) {
								value = createNonInternal(eObj, requiredType);
							}
						}
					}
					return value;
				}
				
				private Object getTokenValue(Object tokenOrValue, String ruleName, INode node) throws ValueConverterException {
					Object value = getTokenAsStringIfPossible(tokenOrValue);
					if ((value == null || value instanceof CharSequence) && ruleName != null) {
						value = getConverterService().toValue(value == null ? null : value.toString(), ruleName, node);
					}
					return value;
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
			public Class<? extends ILinkingService> bindILinkingService() {
				return MyLinkingService.class;
			}
			
			static class MyLinkingService extends DefaultLinkingService {
					
				@Inject
				private IQualifiedNameConverter qualifiedNameConverter;
				
				@Override
				public List<EObject> getLinkedObjects(EObject context, EReference ref, INode node) throws IllegalNodeException {
					final EClass requiredType = ref.getEReferenceType();
					if (requiredType == null)
						return Collections.emptyList();
					
					final String crossRefString = getCrossRefNodeAsString(node);
					if (crossRefString == null || crossRefString.isEmpty())
						return Collections.emptyList();
					
					QualifiedName qualifiedLinkName =  qualifiedNameConverter.toQualifiedName(crossRefString);
					IEObjectDescription eObjectDescription = getScope(context, ref).getSingleElement(qualifiedLinkName);
					if (eObjectDescription != null) {
						EObject eObj = eObjectDescription.getEObjectOrProxy();
						if (!isInternal(requiredType) && isInternal(eObjectDescription.getEClass())) {
							return Collections.singletonList(createNonInternal(eObj, requiredType));
						}
						return Collections.singletonList(eObj);
					}
					return Collections.emptyList();
				}
			}
				
			public static boolean isInternal(EClass type) {
				EClass internal = InternalPackage.Literals.INTERNAL_IDENTIFIABLE_ELEMENT;
				return internal.isSuperTypeOf(type);
			}
			
			public static EObject createNonInternal(EObject internal, EClass requiredType) {
				InternalIdentifiableElement ime = (InternalIdentifiableElement) internal;
				Transformer transformer = new «model.name»GratextTransformer();
				return transformer.transform(ime, false).getElement();
			}
		    
		    @Override
			public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
				return «model.name»GratextQualifiedNameProvider.class;
			}
		    
		    @Override
		    public Class<? extends XtextResource> bindXtextResource() {
		    	return «model.name»GratextResource.class;
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