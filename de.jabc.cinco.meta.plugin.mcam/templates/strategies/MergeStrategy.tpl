package ${StrategyPackage};

import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.strategies.merge.DefaultMergeStrategy;
import info.scce.mcam.framework.strategies.merge.MergeStrategy;

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
			executePhase(model, MergeType.ADDED, mergeInformations);
			executePhase(model, MergeType.CHANGED, mergeInformations);
			executePhase(model, MergeType.DELETED, mergeInformations);
		} catch (ChangeDeadlockException e) {
			System.err.println(e.getMessage());
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : e.getChanges()) {
				System.err.println(" - " + change);
			}
		}
	}

	private List<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> getMergeInformationListByType(
			MergeType type,
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {
		List<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> list = new ArrayList<>();
		for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInformation : mergeInformations) {
			if (mergeInformation.getType().equals(type))
				list.add(mergeInformation);
		}
		return list;
	}

	public void executePhase(
			${GraphModelName}Adapter model,
			MergeType type,
			Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations)
			throws ChangeDeadlockException {

		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesToDo = new ArrayList<>();
		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone = new ArrayList<>();

		for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInformation : getMergeInformationListByType(
				type, mergeInformations)) {
			changesToDo.addAll(mergeInformation.getLocalChanges());
			changesToDo.addAll(mergeInformation.getRemoteChanges());
		}

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canPreExecute(model)) {
					change.preExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			if (!somethingDone)
				throw new ChangeDeadlockException(type
								+ ": All canPreExecute-Methods fail. Couldn't do anything!", changesToDo);
			changesToDo.removeAll(changesDone);
		}
		changesToDo.addAll(changesDone);

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canExecute(model)) {
					change.execute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			if (!somethingDone)
				throw new ChangeDeadlockException(type
						+ ": All canExecute-Methods fail. Couldn't do anything!", changesToDo);
			changesToDo.removeAll(changesDone);
		}
		changesToDo.addAll(changesDone);

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changesToDo) {
				if (change.canPostExecute(model)) {
					change.postExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			if (!somethingDone)
				throw new ChangeDeadlockException(type
						+ ": All canPostExecute-Methods fail. Couldn't do anything!", changesToDo);
			changesToDo.removeAll(changesDone);
		}
		changesToDo.addAll(changesDone);
	}
}
