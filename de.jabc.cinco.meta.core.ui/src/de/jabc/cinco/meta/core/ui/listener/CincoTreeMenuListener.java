package de.jabc.cinco.meta.core.ui.listener;

import graphmodel.GraphModel;
import graphmodel.ModelElement;
import graphmodel.ModelElementContainer;
import graphmodel.Type;
import graphmodel.internal.InternalGraphModel;
import graphmodel.internal.InternalModelElement;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuListener2;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredViewer;

import de.jabc.cinco.meta.core.ui.utils.CincoPropertyUtils;

public class CincoTreeMenuListener implements IMenuListener2{

	private StructuredViewer viewer;
	private Map<Class<? extends EObject>, List<EStructuralFeature>> map;
	
	public CincoTreeMenuListener(StructuredViewer viewer, Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap) {
		this.viewer = viewer;
		this.map = referencesMap;
	}

	@Override
	public void menuAboutToShow(IMenuManager manager) {
		
		ISelection selection = viewer.getSelection();
		if (!(selection instanceof IStructuredSelection)) 
			return;
		
		Object object = ((IStructuredSelection) selection).getFirstElement();
		if (!(object instanceof EObject))
			return;
		
		if (object instanceof Type)
			object = ((Type) object).getInternalElement();
		
		List<EStructuralFeature> references = CincoPropertyUtils.getAllEStructuralFeatures(object.getClass(), map);//map.get(object.getClass());
		
		if (references == null)
			return;
		
		for (EStructuralFeature f : references) {
			IAction createAction = getCreateAction((EObject) object, f);
			manager.add(createAction);
		}
		
		manager.add(new Separator());
		
		manager.add(getDeleteAction((EObject) object));
		
	}


	private IAction getCreateAction(EObject eObject, EStructuralFeature f) {
		Action action = new Action() {
			
			@Override
			public String getText() {
				return "Create new " + f.getName();
			}
			
			@Override
			public boolean isEnabled() {
				int upperBound = f.getUpperBound();
				if (upperBound == 1) {
					return eObject.eGet(f) == null;
				} else {
					EList<EObject> list = (EList<EObject>) eObject.eGet(f);
					return list.size() < upperBound || upperBound == -1;
				}
			}
			
			@Override
			public void run() {
				TransactionalEditingDomain dom = getOrCreateTransactionalEditingDomain(eObject);
				final EObject newValue = EcoreUtil.create((EClass) f.getEType());
				
				dom.getCommandStack().execute(new RecordingCommand(dom, this.getText()) {
					
					@Override
					protected void doExecute() {
						if (f.getUpperBound() == 1)
							eObject.eSet(f, newValue);
						else {
							List<EObject> result = (List<EObject>) eObject.eGet(f);
							result.add(newValue);
							//System.out.println(result);
						}
					}
				});
				viewer.refresh();
			}
		};
		
		return action;
	}

	
	private IAction getDeleteAction(EObject eObject) {
		Action action = new Action() {
			
			@Override
			public String getText() {
				return "Delete";
			}
			
			@Override
			public boolean isEnabled() {
				return !((eObject instanceof ModelElement) || (eObject instanceof GraphModel) || (eObject instanceof InternalModelElement) || (eObject instanceof InternalGraphModel));
			}
			
			@Override
			public void run() {
				TransactionalEditingDomain dom = getOrCreateTransactionalEditingDomain(eObject);
				dom.getCommandStack().execute(new RecordingCommand(dom, this.getText()) {
					
					@Override
					protected void doExecute() {
						EcoreUtil.remove(eObject);
					}
				});
				viewer.refresh();
			}
			
		};
		
		return action;
	}
	
	@Override
	public void menuAboutToHide(IMenuManager manager) {
		
	}
	
	private TransactionalEditingDomain getOrCreateTransactionalEditingDomain(EObject bo) {
		TransactionalEditingDomain dom = TransactionUtil.getEditingDomain(bo);
		if (dom == null) {
			dom = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(bo.eResource().getResourceSet());
		}
		
		return dom;
	}
	
}
