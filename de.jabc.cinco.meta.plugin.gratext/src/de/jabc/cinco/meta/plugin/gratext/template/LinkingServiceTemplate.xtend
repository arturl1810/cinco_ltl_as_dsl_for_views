package de.jabc.cinco.meta.plugin.gratext.template

class LinkingServiceTemplate extends AbstractGratextTemplate {

	def transformer() { fileFromTemplate(TransformerTemplate) }

	override template() '''	
		package «project.basePackage»;
		
		import java.util.Collections;
		import java.util.List;
		
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.EReference;
		import org.eclipse.emf.ecore.util.EcoreUtil;
		import org.eclipse.xtext.linking.impl.DefaultLinkingService;
		import org.eclipse.xtext.linking.impl.IllegalNodeException;
		import org.eclipse.xtext.naming.IQualifiedNameConverter;
		import org.eclipse.xtext.naming.QualifiedName;
		import org.eclipse.xtext.nodemodel.INode;
		import org.eclipse.xtext.resource.IEObjectDescription;
		import org.eclipse.xtext.scoping.IScope;
		
		import com.google.inject.Inject;
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.Transformer;
		import graphmodel.internal.InternalIdentifiableElement;
		import graphmodel.internal.InternalPackage;
		
		import «transformer.className»;
		
		class «project.targetName»LinkingService extends DefaultLinkingService {
		
			@Inject
			private IQualifiedNameConverter qualifiedNameConverter;
			
			Transformer _transformer;
			
			private void assertTransformer(EObject model) {
				if (model instanceof «model.name»)
					_transformer = «project.targetName»Resource.transformers.get(model); // create transformer if not existent
			}
			
			public Transformer getTransformer() {
				if (_transformer == null) {
					System.err.println("[LinkingService] WARN: transformer is null - creating decoupled instance");
					_transformer = new «transformer.classSimpleName»();
				}
				return _transformer;
			}
			
			@Override
			public List<EObject> getLinkedObjects(EObject context, EReference ref, INode node) throws IllegalNodeException {
				EObject model = EcoreUtil.getRootContainer(context);
				assertTransformer(model);
				final EClass requiredType = ref.getEReferenceType();
				if (requiredType == null)
					return Collections.emptyList();
				
				String crossRefString = getCrossRefNodeAsString(node);
				if (crossRefString == null || crossRefString.isEmpty())
					return Collections.emptyList();
				
				IScope scope = getScope(context, ref);
				QualifiedName qualifiedLinkName =  qualifiedNameConverter.toQualifiedName(crossRefString);
				IEObjectDescription eObjectDescription = scope.getSingleElement(qualifiedLinkName);
				
				if (eObjectDescription == null) {
					crossRefString += "_INTERNAL";
					qualifiedLinkName = qualifiedNameConverter.toQualifiedName(crossRefString);
					eObjectDescription = scope.getSingleElement(qualifiedLinkName);
				}
				
				if (eObjectDescription != null) {
					EObject eObj = eObjectDescription.getEObjectOrProxy();
					if (!isInternal(requiredType) && isInternal(eObjectDescription.getEClass())) {
						return Collections.singletonList(createNonInternal(eObj));
					}
					return Collections.singletonList(eObj);
				}
				return Collections.emptyList();
			}
			
			private EObject createNonInternal(EObject internal) {
				InternalIdentifiableElement ime = (InternalIdentifiableElement) internal;
				Transformer transformer = getTransformer();
				return transformer.transform(ime, true).getElement();
			}
			
			private boolean isInternal(EClass type) {
				EClass internal = InternalPackage.Literals.INTERNAL_IDENTIFIABLE_ELEMENT;
				return internal.isSuperTypeOf(type);
			}
		}
	'''
}
