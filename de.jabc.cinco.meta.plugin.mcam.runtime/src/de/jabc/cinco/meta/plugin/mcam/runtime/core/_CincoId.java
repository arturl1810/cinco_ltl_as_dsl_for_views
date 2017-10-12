package de.jabc.cinco.meta.plugin.mcam.runtime.core;

import org.eclipse.emf.ecore.EClass;

import graphmodel.IdentifiableElement;
import info.scce.mcam.framework.adapter.EntityId;

public class _CincoId implements EntityId {
	
	private String id = "";
	private EClass eClass = null;
	private String label = null;
	private IdentifiableElement element = null;

	public _CincoId(IdentifiableElement element) {
		super();
		this.element = element;
		this.id = element.getId();
		this.eClass = element.eClass();
	}
	public _CincoId(IdentifiableElement element, String id, EClass eClass) {
		super();
		this.id = id;
		this.eClass = eClass;
	}

	public String getId() {
		return id;
	}

	public EClass geteClass() {
		return eClass;
	}
	
	public IdentifiableElement getElement() {
		return element;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}
	
	public void setElement(IdentifiableElement element) {
		this.element = element;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (obj instanceof _CincoId == false)
			return false;
		_CincoId other = (_CincoId) obj;
		if (id == null) {
			if (other.getId() != null)
				return false;
		} else if (!id.equals(other.getId()))
			return false;
		return true;
	}

	@Override
	public String toString() {
		if (label == null)
			return " [" + eClass.getName() + "]";
		return label + " [" + eClass.getName() + "]";
	}
	
}
