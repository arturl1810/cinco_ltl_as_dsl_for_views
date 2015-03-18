package ${StrategyPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.ChangeModule;

import java.util.ArrayList;
import java.util.List;

public class ChangeDeadlockException extends Exception {
	private static final long serialVersionUID = -1312943541565374222L;

	List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();
	
	public ChangeDeadlockException(String message,
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes) {
		super(message);
		this.changes = changes;
	}

	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChanges() {
		return changes;
	}
	
}

