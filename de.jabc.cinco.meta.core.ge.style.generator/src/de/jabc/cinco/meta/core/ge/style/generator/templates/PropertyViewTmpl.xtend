package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ui.properties.CincoPropertyView
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import mgl.GraphModel
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.platform.IDiagramBehavior
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.graphiti.ui.platform.GraphitiConnectionEditPart
import org.eclipse.graphiti.ui.platform.GraphitiShapeEditPart
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.ISelectionListener
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.xtext.ui.editor.embedded.EmbeddedEditorFactory

import static extension de.jabc.cinco.meta.core.utils.CincoUtil.*
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*
import de.jabc.cinco.meta.core.ui.properties.IValuesProposalProvider

class PropertyViewTmpl extends GeneratorUtils {

/**
 * Generates the code which registers the {@link EStructuralFeature}s for the 
 * generic {@link CincoPropertyView}
 * 
 * @param gm The processed {@link GraphModel}
 */	
def generatePropertyView(GraphModel gm)'''
package «gm.packageName».property.view;

import «EmbeddedEditorFactory.name».Builder;

public class «gm.fuName»PropertyView implements «ISelectionListener.name», «IValuesProposalProvider.name» {

	private «PictogramElement.name» lastSelected;
	private static «ISelectionListener.name» listener;

	public static void initEStructuralFeatureInformation(){

		if (listener == null) {
			listener = new «gm.fuName»PropertyView();
			«CincoPropertyView.name».addSelectionListener(listener);
		}

		«CincoPropertyView.name».init_EStructuralFeatures(«gm.beanPackage».internal.impl.Internal«gm.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : gm.attributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«gm.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		
		«FOR n : gm.nodes»
		«CincoPropertyView.name».init_EStructuralFeatures(«n.beanPackage».internal.impl.Internal«n.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : n.allAttributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«n.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»
		
		«FOR e : gm.edges»
		«CincoPropertyView.name».init_EStructuralFeatures(«e.beanPackage».internal.impl.Internal«e.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : e.allAttributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«e.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»

		«FOR t : gm.types.filter[t | t instanceof UserDefinedType].map[t | t as UserDefinedType]»
		«CincoPropertyView.name».init_EStructuralFeatures(«t.beanPackage».internal.impl.Internal«t.fuName»Impl.class, 
			new «EStructuralFeature.name»[] {
			«FOR attr : t.allAttributes.filter[!isAttributeHidden] SEPARATOR ","»
				«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«t.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
			}
		);
		«ENDFOR»

		«CincoPropertyView.name».init_MultiLineAttributes(new «EStructuralFeature.name»[] {
		«FOR attr : gm.allModelAttributes.filter[isAttributeMultiLine] SEPARATOR ","»
«««			«gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»			
		});

		«CincoPropertyView.name».init_ReadOnlyAttributes(new «EStructuralFeature.name»[] {
		«FOR me : gm.modelElements.filter[allAttributes.exists[isAttributeReadOnly]] SEPARATOR ","»
		«FOR attr : me.allAttributes.filter[isAttributeReadOnly] SEPARATOR ","»
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«me.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»
		«ENDFOR»
		});
		
		«CincoPropertyView.name».init_FileAttributes(new «EStructuralFeature.name»[] {
		«FOR attr : gm.allModelAttributes.filter[isAttributeFile] SEPARATOR ","»
			«FOR subtype : attr.modelElement.allSubclasses + #[attr.modelElement] SEPARATOR ","»
				«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«subtype.fuName»_«attr.name.toFirstUpper»()
			«ENDFOR»
		«ENDFOR»                        
		});

		«IF gm.allModelAttributes.exists[isAttributeFile]»
		«FOR attr : gm.allModelAttributes.filter[isAttributeFile]»
			«CincoPropertyView.name».init_FileAttributesExtensionFilters(
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»(),
				new String[] {"«attr.annotations.filter[name == "file"].map[value].flatten.join("\",\"")»"});
		«ENDFOR»
		«ENDIF»
	
	
		«FOR t : gm.types.filter[t | t instanceof UserDefinedType].map[t | t as UserDefinedType]»
		«CincoPropertyView.name».init_ColorAttributes(new «EStructuralFeature.name»[] {
		«FOR attr :t.allAttributes.filter[isAttributeColor] SEPARATOR ","»
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«t.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»                        
		   });
		«ENDFOR»

		«FOR n : gm.nodes»
		«CincoPropertyView.name».init_ColorAttributes(new «EStructuralFeature.name»[] {
		«FOR attr :n.allAttributes.filter[isAttributeColor] SEPARATOR ","»
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»                        
		   });
		«ENDFOR»
		
		«FOR e : gm.edges»
		«CincoPropertyView.name».init_ColorAttributes(new «EStructuralFeature.name»[] {
		«FOR attr : e.allAttributes.filter[isAttributeColor] SEPARATOR ","»
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»()
		«ENDFOR»                        
		   });
		«ENDFOR»
	
		
		«FOR t : gm.types.filter[t| t instanceof UserDefinedType].map[t| t as UserDefinedType]»
		«IF gm.allModelAttributes.exists[isAttributeColor]»
		«FOR attr : t.allAttributes.filter[isAttributeColor]»
		«CincoPropertyView.name».init_ColorAttributesParameter(
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«t.fuName»_«attr.name.toFirstUpper»(),
				"«attr.annotations.filter[name == "color"].map[value].get(0).get(0)»");
		«ENDFOR»
		«ENDIF»
		«ENDFOR»
		
		«FOR n : gm.nodes»
		«IF gm.allModelAttributes.exists[isAttributeColor]»
		«FOR attr : n.allAttributes.filter[isAttributeColor]»
		«CincoPropertyView.name».init_ColorAttributesParameter(
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»(),
				"«attr.annotations.filter[name == "color"].map[value].get(0).get(0)»");
		«ENDFOR»
		«ENDIF»
		«ENDFOR»


		«FOR e : gm.edges»
		«IF gm.allModelAttributes.exists[isAttributeColor]»
		«FOR attr : e.allAttributes.filter[isAttributeColor]»
		«CincoPropertyView.name».init_ColorAttributesParameter(
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.fuName»_«attr.name.toFirstUpper»(),
				"«attr.annotations.filter[name == "color"].map[value].get(0).get(0)»");
		«ENDFOR»
		«ENDIF»
		«ENDFOR»
		
		«FOR t : gm.types.filter(UserDefinedType).filter[hasLabel]»
		«CincoPropertyView.name».init_TypeLabel(
			«gm.beanPackage».internal.impl.Internal«t.fuName»Impl.class,
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«t.fuName»_«t.annotations.filter[name == "label"].head.value.head.toFirstUpper»()
		);
		«ENDFOR»
		
		«IF gm.allModelAttributes.exists[isGrammarAttribute]»
		«FOR attr : gm.allModelAttributes.filter[isGrammarAttribute]»
			«FOR subType : attr.modelElement.allSubclasses + #[attr.modelElement]»
			«CincoPropertyView.name».init_GrammarEditor(
			«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«subType.fuName»_«attr.name.toFirstUpper»(),
				 «attr.annotations.filter[name == "grammar"].head.value.get(1)».getInstance().getInjector("«attr.annotations.filter[name == "grammar"].head.value.get(0)»"));
			«ENDFOR»
		«ENDFOR»
		«ENDIF»
		
	}
	
	@Override
	public void selectionChanged(«IWorkbenchPart.name» part, «ISelection.name» selection) {
		«WorkbenchExtension.name» wb = new «WorkbenchExtension.name»();
		if (isStructuredSelection(selection)) {
			«Object.name» element = ((«IStructuredSelection.name») selection).getFirstElement();
			«PictogramElement.name» pe = null;
			if (element instanceof «GraphicalEditPart.name»)
				pe = getPictogramElement(element);
			
			«IDiagramBehavior.name» diagramBehavior = null;
			«DiagramEditor.name» editor = wb.getActiveDiagramEditor();
			if (editor != null){
				diagramBehavior = editor.getDiagramBehavior();
			}
			if (diagramBehavior instanceof «DiagramBehavior.name») {
				«DiagramBehavior.name» db = («DiagramBehavior.name») diagramBehavior;		
				«EObject.name» bo = getBusinessObject(pe);
			
				«FOR attr : gm.allModelAttributes.filter[isAttributePossibleValuesProvider]»
					if (bo instanceof «attr.modelElement.fqBeanName»)
						«CincoPropertyView.name».refreshPossibleValues(«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.name»_«attr.name.toFirstUpper»(), new «attr.getPossibleValuesProviderClass»().getPossibleValues((«attr.modelElement.fqBeanName») bo));
				«ENDFOR»
				
				«FOR postSelect : gm.modelElements.map[findAnnotationPostSelect].filterNull»
					if (bo instanceof «postSelect.parent.fqBeanName») {
						new «postSelect.value.get(0)»().postSelect((«postSelect.parent.fqBeanName») bo);
					}
				«ENDFOR»

				if (pe instanceof «ConnectionDecorator.name» && !pe.equals(lastSelected)) {
					«Connection.name» connection = ((«ConnectionDecorator.name») pe).getConnection();
				
					lastSelected = pe;
					db.getDiagramContainer().selectPictogramElements(new «PictogramElement.name»[] {
						pe, connection
					});
				}
			}
			lastSelected = pe;
		}
		
	}


	private «EObject.name» getBusinessObject(«PictogramElement.name» pe) {
		return «Graphiti.name».getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}

	private «PictogramElement.name» getPictogramElement(«Object.name» element) {
		if (element instanceof «GraphitiShapeEditPart.name») 
			return ((«GraphitiShapeEditPart.name») element).getPictogramElement();
		
		if (element instanceof «GraphitiConnectionEditPart.name»)
			return ((«GraphitiConnectionEditPart.name») element).getPictogramElement();
		
		return null;
	}

	private boolean isStructuredSelection(«ISelection.name» selection) {
		return selection instanceof «IStructuredSelection.name»;
	}
	
	@Override
	public void refreshValues(«EObject.name» bo) {
		«FOR attr : gm.allModelAttributes.filter[isAttributePossibleValuesProvider]»
		if (bo instanceof «attr.modelElement.fqBeanName»)
			«CincoPropertyView.name».refreshPossibleValues(«gm.beanPackage».internal.InternalPackage.eINSTANCE.getInternal«attr.modelElement.name»_«attr.name.toFirstUpper»(), new «attr.getPossibleValuesProviderClass»().getPossibleValues((«attr.modelElement.fqBeanName») bo));
		
		«ENDFOR»
	}
	
}

'''
}