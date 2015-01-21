package ${AdapterPackage};

import org.eclipse.emf.ecore.EClass;

import info.scce.mcam.framework.adapter.EntityId;

public class ${GraphModelName}Id implements EntityId {
	
	private String id = "";
	private EClass eClass = null;
	private String label = null;
	
	public ${GraphModelName}Id(String id, EClass eClass) {
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

	public void setLabel(String label) {
		this.label = label;
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
		if (getClass() != obj.getClass())
			return false;
		${GraphModelName}Id other = (${GraphModelName}Id) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	@Override
	public String toString() {
		if (label == null)
			return eClass.getName() + " [id=" + id + "]";
		return label + " [" + eClass.getName() + "]";
	}
	
}
