package de.jabc.cinco.meta.core.ui.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.databinding.internal.EMFListProperty;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

public class CincoPropertyUtils {

	/**
	 * This method iterates over the {@link bo}'s class and super classes and
	 * retrieves all EAttributes.
	 * 
	 * @param bo
	 *            The EObject for which the EAttributes should be retrieved
	 * @param attributesMap
	 * @return All EAttributes of EObject {@link bo}
	 */
	public static List<EStructuralFeature> getAllEStructuralFeatures(Class<? extends Object> clazz,
			Map<Class<? extends EObject>, List<EStructuralFeature>> attributesMap) {

		Class<? extends Object> currentClass = clazz;
		List<EStructuralFeature> attributes = new ArrayList<EStructuralFeature>();
		while (currentClass != null) {
			List<EStructuralFeature> list = attributesMap.get(currentClass);
			if (list != null)
				attributes.addAll(list);
			currentClass = (Class<? extends Object>) currentClass.getSuperclass();
		}
		return attributes;
	}

	public static IEMFListProperty getAllListProperties(Class<? extends Object> clazz,
			Map<Class<? extends EObject>, IEMFListProperty> emfListPropertesMap) {

		Class<? extends Object> currentClass = clazz;
		List<IEMFListProperty> properties = new ArrayList<IEMFListProperty>();
		while (currentClass != null) {
			IEMFListProperty emfProperty = emfListPropertesMap.get(currentClass);
			if (emfProperty != null) {
				properties.add(emfProperty);
			}
			currentClass = (Class<? extends Object>) currentClass.getSuperclass();
		}

		IEMFListProperty retVal = EMFProperties.multiList(properties.toArray(new IEMFListProperty[properties.size()]));

		return retVal;
	}

	public static EStructuralFeature getLabeledFeature(Class<? extends Object> clazz, Map<Class<? extends EObject>, EStructuralFeature> typeLabeles) {
		Class<? extends Object> currentClass = clazz;
		while (currentClass != null) {
			EStructuralFeature feature = typeLabeles.get(currentClass);
			if (feature  != null)
				return feature;
			currentClass = (Class<? extends Object>) currentClass.getSuperclass();
		}
		return null;
	}
	
}
