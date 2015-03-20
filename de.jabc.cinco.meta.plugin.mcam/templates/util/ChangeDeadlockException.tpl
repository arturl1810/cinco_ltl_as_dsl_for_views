package ${UtilPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.ChangeModule;

import java.util.ArrayList;
import java.util.List;

public class ChangeDeadlockException extends Exception {
	private static final long serialVersionUID = -1312943541565374222L;

	List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo = new ArrayList<>();
	List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = new ArrayList<>();
	
	public ChangeDeadlockException(String message,
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo,
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone) {
		super(message);
		this.changesToDo = changesToDo;
		this.changesDone = changesDone;
	}

	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChangesToDo() {
		return changesToDo;
	}

	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChangesDone() {
		return changesDone;
	}
}

