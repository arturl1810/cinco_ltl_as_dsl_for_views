package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class AstFactoryTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextAstFactory.java'''
	
	override template() '''
		package «package»;
		
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.EReference;
		import org.eclipse.emf.ecore.EStructuralFeature;
		import org.eclipse.emf.ecore.util.EcoreUtil;
		import org.eclipse.xtext.conversion.ValueConverterException;
		import org.eclipse.xtext.nodemodel.INode;
		import org.eclipse.xtext.parser.DefaultEcoreElementFactory;
		
		import graphmodel.Node;
		import graphmodel.internal.InternalEdge;
		import graphmodel.internal.InternalIdentifiableElement;
		import graphmodel.internal.InternalModelElementContainer;
		import graphmodel.internal.InternalNode;
		import graphmodel.internal.InternalPackage;
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.Transformer;
		import «package».generator.«model.name»GratextTransformer;
		
		class «model.name»GratextAstFactory extends DefaultEcoreElementFactory {
			
			Transformer _transformer;
			
			private void assertTransformer(EObject model) {
				if (model instanceof «model.name»)
					_transformer = «model.name»GratextResource.transformers.get(model); // create transformer if not existent
			}
			
			public Transformer getTransformer() {
				if (_transformer == null) {
					System.err.println("[ASTFactory] WARN: transformer is null - creating decoupled instance");
					_transformer = new «model.name»GratextTransformer();
				}
				return _transformer;
			}
			
			@Override
			public void add(EObject object, String feature, Object value, String ruleName, INode node) throws ValueConverterException {
				if (object instanceof InternalModelElementContainer
						&& feature == "modelElements"
						&& value instanceof InternalNode) {
					getTransformer().getNodesInitialOrder((InternalModelElementContainer) object).add((InternalNode) value);
				}
				if (feature.startsWith("gratext_")) {
					feature = feature.substring(8);
					value = mapGratextFeatureValue(object, feature, value, ruleName, node);
				}
				if (node.getSemanticElement() instanceof InternalEdge && feature.equals("outgoingEdges")) try {
					InternalEdge edge = (InternalEdge) node.getSemanticElement();
					InternalNode source = (InternalNode) node.getParent().getSemanticElement();
					Node sourceBase = (Node) createNonInternal(source);
					edge.setSourceElement(sourceBase);
				} catch(Exception e) {
			    		e.printStackTrace();
			    }
				super.add(object, feature, value, ruleName, node);
			}
					
			@Override
			public void set(EObject object, String feature, Object value, String ruleName, INode node) throws ValueConverterException {
				assertTransformer(EcoreUtil.getRootContainer(object));
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
							value = createNonInternal(eObj);
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
			
			private EObject createNonInternal(EObject internal) {
				InternalIdentifiableElement ime = (InternalIdentifiableElement) internal;
				Transformer transformer = getTransformer();
				return transformer.transform(ime, false).getElement();
			}
			
			private boolean isInternal(EClass type) {
				EClass internal = InternalPackage.Literals.INTERNAL_IDENTIFIABLE_ELEMENT;
				return internal.isSuperTypeOf(type);
			}
		}
	'''
	
}