package ${StrategyPackage};

import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.strategies.merge.DefaultMergeStrategy;
import info.scce.mcam.framework.strategies.merge.MergeStrategy;

import ${UtilPackage}.ChangeDeadlockException;

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class ${GraphModelName}MergeStrategy implements
		MergeStrategy<${GraphModelName}Id, ${GraphModelName}Adapter> {

	@Override
	public void execute(
			${GraphModelName}Adapter model,
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {

		try {
			executeChanges(model, mergeInformations, false);
		} catch (ChangeDeadlockException e) {
			System.err.println(e.getMessage());
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : e
					.getChangesToDo()) {
				System.err.println(" - " + change.id + ": " + change);
			}
		}

	}

	private ArrayList<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> getMergeInformationListByType(
			MergeType type,
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {
		ArrayList<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> list = new ArrayList<>();
		for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInformation : mergeInformations) {
			if (mergeInformation.getType().equals(type))
				list.add(mergeInformation);
		}
		return list;
	}

	private ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChangesFromMergeInformationList(
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations,
			boolean includeConflicted) {
		ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();
		for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInformation : mergeInformations) {
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> changeModule : mergeInformation
					.getLocalChanges()) {
				if (!mergeInformation.isConflictedChange(changeModule)
						|| includeConflicted)
					changes.add(changeModule);
			}
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> changeModule : mergeInformation
					.getRemoteChanges()) {
				if (!mergeInformation.isConflictedChange(changeModule)
						|| includeConflicted)
					changes.add(changeModule);
			}
		}
		return changes;
	}

	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> executeChanges(
			${GraphModelName}Adapter model,
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations,
			boolean includeConflicted) throws ChangeDeadlockException {

		ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo = getChangesFromMergeInformationList(
				mergeInformations,
				includeConflicted);

		runPreExecutePhase(model, 
				new ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>>(
						changesToDo));
		runExecutePhase(model, 
				new ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>>(
						changesToDo));

		runPostExecutePhase(model, 
				new ArrayList<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>>(
						changesToDo));

		return changesToDo;
	}

	public void runExecutePhase(${GraphModelName}Adapter model, 
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canExecute(model)) {
					change.execute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException(
						"All canExecute-Methods fail. Couldn't do anything!",
						changesToDo, changesDone);
		}
	}

	public void runPreExecutePhase(${GraphModelName}Adapter model,
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canPreExecute(model)) {
					change.preExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException(
						"All canPreExecute-Methods fail. Couldn't do anything!",
						changesToDo, changesDone);
		}
	}

	public void runPostExecutePhase(${GraphModelName}Adapter model, 
			List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canPostExecute(model)) {
					change.postExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException(
						"All canPostExecute-Methods fail. Couldn't do anything!",
						changesToDo, changesDone);
		}
	}
}
