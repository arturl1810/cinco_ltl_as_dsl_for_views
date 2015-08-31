package de.jabc.cinco.meta.core.ui.properties;

import org.eclipse.core.databinding.observable.IObservable;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.databinding.observable.masterdetail.IObservableFactory;
import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.databinding.internal.EMFListProperty;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.jface.databinding.viewers.ObservableListTreeContentProvider;
import org.eclipse.jface.databinding.viewers.TreeStructureAdvisor;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;

public class CincoPropertyViewCreator {

	private EStructuralFeature inputFeature;
	
	public CincoPropertyViewCreator(EStructuralFeature inputFeature) {
		this.inputFeature = inputFeature;
	}
	
	public void createTreeView(Composite comp, EObject bo) {
		Tree tree = new Tree(comp, SWT.BORDER | SWT.SINGLE);
		tree.setLayoutData(new GridData(SWT.LEFT, SWT.FILL, false, true));
		
		TreeViewer viewer = new TreeViewer(tree);
		
		ObservableListTreeContentProvider cp = new ObservableListTreeContentProvider(
				new CincoTreeFactory(), 
				new CincoTreeStructureAdvisor());
		
		viewer.setContentProvider(cp);
		IEMFListProperty input = EMFProperties.list(inputFeature);
		viewer.setInput(input);
	}
}

class CincoTreeFactory implements IObservableFactory {

	IEMFListProperty props;
	
	public CincoTreeFactory(EStructuralFeature... features) {
		props = EMFProperties.multiList(features);
	}
	
	@Override
	public IObservable createObservable(Object target) {
		
		if (target instanceof IObservableList)
			return (IObservable) target;
		
		if (target instanceof EObject)
			return props.observe(target);
		
		return null;
	}
	
}

class CincoTreeStructureAdvisor extends TreeStructureAdvisor {
	
	@Override
	public Object getParent(Object element) {
		if (element instanceof EReference) {
			if (((EReference) element).isContainment())
				return ((EReference) element).eContainer();
		}
		return super.getParent(element);
	}
	
	@Override
	public Boolean hasChildren(Object element) {
		if (element instanceof EObject) {
			return true;
		}
		return super.hasChildren(element);
	}
	
}