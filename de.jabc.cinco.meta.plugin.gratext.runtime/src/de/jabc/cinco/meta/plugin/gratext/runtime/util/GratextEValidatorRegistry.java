package de.jabc.cinco.meta.plugin.gratext.runtime.util;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.common.util.DiagnosticChain;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EValidator;
import org.eclipse.emf.ecore.EValidator.Registry;

public class GratextEValidatorRegistry implements Registry {

	static Registry instance = EValidator.Registry.INSTANCE;
	
	@Override
	public int size() {
		return instance.size();
	}

	@Override
	public boolean isEmpty() {
		return instance.isEmpty();
	}

	@Override
	public boolean containsKey(Object key) {
		return instance.containsKey(key);
	}

	@Override
	public boolean containsValue(Object value) {
		return instance.containsValue(value);
	}

	@Override
	public Object get(Object key) {
		return new EValidator() {

			@Override
			public boolean validate(EObject eObject,
					DiagnosticChain diagnostics,
					Map<Object, Object> context) {
				return true;
			}

			@Override
			public boolean validate(EClass eClass, EObject eObject,
					DiagnosticChain diagnostics,
					Map<Object, Object> context) {
				return true;
			}

			@Override
			public boolean validate(EDataType eDataType, Object value,
					DiagnosticChain diagnostics,
					Map<Object, Object> context) {
				return true;
			}
			
		};
	}

	@Override
	public Object put(EPackage key, Object value) {
		return instance.put(key, value);
	}

	@Override
	public Object remove(Object key) {
		return instance.remove(key);
	}

	@Override
	public void putAll(Map<? extends EPackage, ? extends Object> m) {
		instance.putAll(m);
	}

	@Override
	public void clear() {
		instance.clear();
	}

	@Override
	public Set<EPackage> keySet() {
		return instance.keySet();
	}

	@Override
	public Collection<Object> values() {
		return instance.values();
	}

	@Override
	public Set<java.util.Map.Entry<EPackage, Object>> entrySet() {
		return instance.entrySet();
	}

	@Override
	public EValidator getEValidator(EPackage ePackage) {
		return instance.getEValidator(ePackage);
	}
}