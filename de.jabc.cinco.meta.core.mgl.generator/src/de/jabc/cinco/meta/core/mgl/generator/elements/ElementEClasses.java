package de.jabc.cinco.meta.core.mgl.generator.elements;

import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.emf.ecore.EClass;

import mgl.ModelElement;

public class ElementEClasses {
	private EClass mainEClass = null;
	private EClass internalEClass = null;
	private EClass mainView = null;
	private ArrayList<EClass> views = new ArrayList<>();
	private ModelElement modelElement;

	public EClass getMainEClass() {
		return mainEClass;
	}

	public void setMainEClass(EClass mainEClass) {
		this.mainEClass = mainEClass;
	}

	public EClass getInternalEClass() {
		return internalEClass;
	}

	public void setInternalEClass(EClass internalEClass) {
		this.internalEClass = internalEClass;
	}

	public EClass getMainView() {
		return mainView;
	}

	public void setMainView(EClass mainView) {
		this.mainView = mainView;
	}

	public ArrayList<EClass> getViews() {
		return views;
	}

	public boolean addView(EClass view) {
		return views.add(view);
	}
	
	public boolean addAllViews(Collection<? extends EClass> views){
		return this.views.addAll(views);
	}

	public ModelElement getModelElement() {
	  return this.modelElement;
	}
	
	public void setModelElement(ModelElement modelElement){
		this.modelElement = modelElement;
	}
	
}
