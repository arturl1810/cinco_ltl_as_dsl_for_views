package de.jabc.cinco.meta.core.ui.properties;

import java.util.Map;

import org.eclipse.core.databinding.observable.IObservable;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.databinding.observable.list.WritableList;
import org.eclipse.core.databinding.observable.masterdetail.IObservableFactory;
import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.ecore.EObject;

public class CincoTreeFactory implements IObservableFactory {

	Map<Class<? extends EObject>, IEMFListProperty> emfListPropertesMap;
	EObject bo;

	public CincoTreeFactory(EObject bo,
			Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap) {
		this.bo = bo;
		this.emfListPropertesMap = emfListPropertiesMap;
	}

	@Override
	public IObservable createObservable(Object target) {
		
		if (target instanceof IObservableList) {

			WritableList list = new WritableList();
			list.add(bo);
			
			return list;
		}

		if (target instanceof EObject) {
			IEMFListProperty iEmfListProperty = EMFProperties.multiList(emfListPropertesMap.get(target.getClass()));
			return iEmfListProperty.listFactory().createObservable(target);
		}
			
		return null;
	}

}
