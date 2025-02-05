package de.jabc.cinco.meta.core.ui.properties;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.jface.databinding.viewers.TreeStructureAdvisor;

import graphmodel.IdentifiableElement;

public class CincoTreeStructureAdvisor extends TreeStructureAdvisor {

	private Map<Class<? extends EObject>, List<EStructuralFeature>> map;

	public CincoTreeStructureAdvisor(Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap) {
		this.map = referencesMap;
	}

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
		if (!(element instanceof EObject))
			return super.hasChildren(element);
		
		EObject obj = (EObject) element;
		if (obj instanceof IdentifiableElement)
			obj = ((IdentifiableElement) obj).getInternalElement();
		
		//Check for null reference, if a type is deleted. The non-internal element exists
		//but it's internal element is null.
		if (obj == null) return false;
		
		List<EStructuralFeature> refsList = map.get(obj.getClass());
		if (refsList != null) { 
			for (EStructuralFeature f : refsList) {
				Object featureValue = obj.eGet(f, true);
				if (featureValue instanceof List)
					if (!((List<?>) featureValue).isEmpty())
						return true;
				if (featureValue != null)
					return true;
			}
		}

		return super.hasChildren(element);
	}
	
}
