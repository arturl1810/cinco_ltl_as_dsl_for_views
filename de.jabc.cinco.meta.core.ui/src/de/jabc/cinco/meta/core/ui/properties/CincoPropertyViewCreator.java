package de.jabc.cinco.meta.core.ui.properties;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.OptionalInt;
import java.util.stream.Collectors;

import org.eclipse.core.databinding.observable.IObservable;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.databinding.observable.list.ObservableList;
import org.eclipse.core.databinding.observable.masterdetail.IObservableFactory;
import org.eclipse.emf.databinding.EMFDataBindingContext;
import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.databinding.edit.EMFEditProperties;
import org.eclipse.emf.databinding.edit.IEMFEditValueProperty;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.jface.databinding.swt.IWidgetValueProperty;
import org.eclipse.jface.databinding.swt.WidgetProperties;
import org.eclipse.jface.databinding.viewers.ObservableListTreeContentProvider;
import org.eclipse.jface.databinding.viewers.TreeStructureAdvisor;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;

public class CincoPropertyViewCreator {

	private Map<EObject, Composite> compositesMap;
	private Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap;
	private Map<Class<? extends EObject>, List<EStructuralFeature>> attributesMap;
	private Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap;
	
	private final GridData labelData = new GridData(SWT.LEFT, SWT.CENTER, false, false);
	private final GridData textData = new GridData(SWT.FILL, SWT.CENTER, true, false);

	private static CincoPropertyViewCreator instance;
	
	private TransactionalEditingDomain domain;
	
	private CincoPropertyViewCreator() {
		compositesMap = new HashMap<EObject, Composite>();
		emfListPropertiesMap = new HashMap<Class<? extends EObject>, IEMFListProperty>();
		attributesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
		referencesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
	}
	
	public static CincoPropertyViewCreator getInstance() {
		if (instance == null)
			instance = new CincoPropertyViewCreator();
		return instance;
	}
	
	public void init_EStructuralFeatures(Class<? extends EObject> clazz, EStructuralFeature... features) {
		List<EStructuralFeature> featureList = Arrays.asList(features);
		List<EStructuralFeature> attributeList = featureList.stream().filter(f -> f instanceof EAttribute).collect(Collectors.toList());
		List<EStructuralFeature> referenceList = featureList.stream().filter(f -> f instanceof EReference).collect(Collectors.toList());
		
		init_ListPorperties(clazz, referenceList.toArray(new EStructuralFeature[] {}));
		
		if (referencesMap.get(clazz) == null)
			referencesMap.put(clazz, referenceList);
		
		if (attributesMap.get(clazz) == null)
			attributesMap.put(clazz, attributeList);
	}
	
	public void init_ListPorperties(Class<? extends EObject> clazz, EStructuralFeature... features) {
		if (emfListPropertiesMap.get(clazz) == null) { 
			emfListPropertiesMap.put(clazz, EMFProperties.multiList(features));
		}
	}
	
	public void init_PropertyView(EObject bo, Composite parent) {
		clearComposite(parent);
		
		Composite mainComposite = new Composite(parent, SWT.NONE);
		setTwoColumnGridLayout(mainComposite);
		
		Composite composite = compositesMap.get(bo.getClass());
		if (composite != null) 
			composite.setParent(parent);
		else {
			createTreePropertyView(bo, mainComposite);
			createSimplePropertyView(bo, mainComposite);
			compositesMap.put(bo, mainComposite);
		}
		
		parent.layout(true);
	}
	
	
	public void createTreePropertyView(EObject bo, Composite parent) {
		Tree tree = new Tree(parent, SWT.BORDER | SWT.SINGLE);
		GridData data = new GridData(SWT.LEFT, SWT.FILL, false, true);
		data.widthHint = 255;
		tree.setLayoutData(data);
		TreeViewer viewer = new TreeViewer(tree);
		
		ObservableListTreeContentProvider cp = new ObservableListTreeContentProvider(
				new CincoTreeFactory(bo, emfListPropertiesMap), 
				new CincoTreeStructureAdvisor());
		
		viewer.setContentProvider(cp);
		viewer.setLabelProvider(getLabelProvider());
		
		List<EStructuralFeature> inputList = referencesMap.get(bo.getClass());
		IEMFListProperty input = EMFProperties.multiList(inputList.toArray(new EStructuralFeature[] {}));
		viewer.setInput(input.observe(bo));
	}
	
	public void createSimplePropertyView(EObject bo, Composite parent) {
		
		Composite comp = new Composite(parent, SWT.BORDER);
		comp.setLayoutData(new GridData(SWT.FILL,SWT.FILL, true, true));
		setTwoColumnGridLayout(comp);
		
		EMFDataBindingContext context = new EMFDataBindingContext();
		domain = TransactionUtil.getEditingDomain(bo);
		if (domain == null)
			domain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(bo.eResource().getResourceSet());
		
		List<EStructuralFeature> attributes = attributesMap.get(bo.getClass());
		OptionalInt max = attributes.stream().mapToInt(a -> a.getName().length()).max();
		labelData.widthHint = max.getAsInt() * 10;
		
		for (EStructuralFeature attr : attributes) {
			if (attr.getUpperBound() == 1) {
				createSingleAttributeProperty(comp, (EAttribute) attr, context);
			}
			if (attr.getUpperBound() == -1) {
				createMultiAttributeProperty(comp, (EAttribute) attr, context);
			}
		}
	}


	private void createSingleAttributeProperty(Composite comp, EAttribute attr, EMFDataBindingContext context) {
		Label label = new Label(comp, SWT.NONE);
		label.setText(attr.getName() + ": ");
		label.setLayoutData(labelData);
		
		Text text = new Text(comp, SWT.BORDER);
		text.setLayoutData(textData);
		
		IWidgetValueProperty uiProp = WidgetProperties.text(new int[] {SWT.DefaultSelection, SWT.FocusOut});
		IEMFEditValueProperty boPorp = EMFEditProperties.value(domain, attr);
		
		context.bindValue(uiProp.observe(text), boPorp.observe(attr.eContainer()));
	}
	
	private void createMultiAttributeProperty(Composite comp, EAttribute attr, EMFDataBindingContext context) {
		// TODO Auto-generated method stub
		
	}

	private void clearComposite(Composite composite) {
		for (Control c : composite.getChildren()) 
			c.dispose();
	}
	
	private void setTwoColumnGridLayout(Composite composite) {
		composite.setLayout(new GridLayout(2, false));
	}
	
	public void createAttributeView(Composite comp, EObject bo, EAttribute... attributes) {
		
		for (EAttribute attr : attributes) {
			Label label = new Label(comp, SWT.NONE);
			label.setText(attr.getName());
			label.setLayoutData(labelData);
			
			Text text = new Text(comp, SWT.BORDER);
			text.setText(""+ bo.eGet(attr));
			text.setLayoutData(textData);
		}
	}
	
	private LabelProvider getLabelProvider() {
		return new LabelProvider() {
			@Override
			public String getText(Object element) {
//				if (element instanceof Type)
//					return "Type: "+ ((Type) element).getAttrOne();
//				if (element instanceof Inner)
//					return "Inner: "+((Inner) element).getAnInteger();
				
				if (element instanceof EObject)
					return ((EObject) element).eClass().getName();
				return super.getText(element);
			}
		};
	}

	
}

class CincoTreeFactory implements IObservableFactory {

	Map<Class<? extends EObject>, IEMFListProperty> emfListPropertesMap;
	EObject bo;
	
	public CincoTreeFactory(EObject bo, Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap) {
		this.bo = bo;
		this.emfListPropertesMap = emfListPropertiesMap;
	}
	
	@Override
	public IObservable createObservable(Object target) {
		
		if (target instanceof IObservableList) {
			ArrayList<Object> arrayList = new ArrayList<Object>();
			arrayList.add(bo);
			IObservableList list = new ObservableList(arrayList, bo) {
			};
			
			return list;
		}
		
		if (target instanceof EObject) {
			IEMFListProperty iEmfListProperty = emfListPropertesMap.get(target.getClass());
			if (iEmfListProperty != null)
				return iEmfListProperty.observe(target);
			else {
				throw new RuntimeException("The IEMFListProperty for class " + target.getClass() + " does not exist");
			}
		}
		
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
//		if (element instanceof SomeNode) {
//			return ((SomeNode) element).getT1() != null || ((SomeNode) element).getT2() != null;
//		}
//		
//		if (element instanceof Type)
//			return ((Type) element).getRekursive() != null || ((Type) element).getInner() != null;
//		
//		if (element instanceof Inner)
//			return false;
		
		if (element instanceof EObject) {
			return true;
		}
		return super.hasChildren(element);
	}
	
}