package de.jabc.cinco.meta.core.ui.listener;

import java.util.List;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EObject;
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
import org.eclipse.jface.viewers.TableViewer;

import de.jabc.cinco.meta.core.ui.properties.AttributeCreator;

public class CincoTableMenuListener implements IMenuListener2 {

private TableViewer viewer;
	
	private EObject bo;
	private EAttribute attribute;
	private Object selectedObject;
	
	
	public CincoTableMenuListener(TableViewer tv, EObject bo, EAttribute attr) {
		this.viewer = tv;
		
		this.bo = bo;
		this.attribute = attr;
	}

	@Override
	public void menuAboutToShow(IMenuManager manager) {
		ISelection selection = viewer.getSelection();
		if (selection.isEmpty()) 
			manager.add(getCreateAction());
		else {
			selectedObject = ((IStructuredSelection) selection).getFirstElement();
			manager.add(getCreateAction());
			manager.add(new Separator());
			manager.add(getDeleteAction(selectedObject));
		}
	}

	private IAction getCreateAction() {
		Action action = new Action() {
	
			@Override
			public String getText() {
				return "New " + attribute.getName();
			}
			
			@Override
			public boolean isEnabled() {
				int upperBound = attribute.getUpperBound();
				if (upperBound == 1) {
					return bo.eGet(attribute) == null;
				} else {
					EList<EObject> list = (EList<EObject>) bo.eGet(attribute);
					return list.size() < upperBound || upperBound == -1;
				}
			}
			
			@Override
			public void run() {
				TransactionalEditingDomain dom = getOrCreateTransactionalEditingDomain(bo);
				
				final String newValue = AttributeCreator.createAttribute(attribute);
				if (newValue == null)
					return;
				
				dom.getCommandStack().execute(new RecordingCommand(dom, this.getText()) {
					
					@Override
					protected void doExecute() {
						if (attribute.getUpperBound() == 1)
							bo.eSet(attribute, newValue);
						else {
							List<Object> result = (List<Object>) bo.eGet(attribute);
							result.add(EcoreUtil.createFromString(attribute.getEAttributeType(), (String) newValue));
						}
					}
				});
				viewer.refresh();
			}
			
		};
		return action;
	}

	private IAction getDeleteAction(Object eObject) {
		Action action = new Action() {
			
			@Override
			public String getText() {
				return "Delete";
			}
			
			@Override
			public boolean isEnabled() {
				return selectedObject != null;
			}
			
			@Override
			public void run() {
				TransactionalEditingDomain dom = getOrCreateTransactionalEditingDomain(bo);
				dom.getCommandStack().execute(new RecordingCommand(dom, this.getText()) {
					
					@Override
					protected void doExecute() {
							List<Object> list = (List<Object>) bo.eGet(attribute);
							list.remove(selectedObject);
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
