package de.jabc.cinco.meta.plugin.mcam.runtime.core;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import info.scce.mcam.framework.adapter.EntityId;
import info.scce.mcam.framework.adapter.ModelAdapter;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.strategies.merge.MergeStrategy;

public class _CincoMergeStrategy<E extends EntityId, M extends ModelAdapter<E>> implements MergeStrategy<E, M> {

	@Override
	public void execute(M model, Collection<MergeInformation<E, M>> mergeInformations) {
		try {
			executeChanges(model, mergeInformations, false);
		} catch (ChangeDeadlockException e) {
			System.err.println(e.getMessage());
//			for (ChangeModule<E, M> change : e
//					.getChangesToDo()) {
//				System.err.println(" - " + change.id + ": " + change);
//			}
		}

	}

	private ArrayList<MergeInformation<E, M>> getMergeInformationListByType(
			MergeType type,
			Collection<MergeInformation<E, M>> mergeInformations) {
		ArrayList<MergeInformation<E, M>> list = new ArrayList<>();
		for (MergeInformation<E, M> mergeInformation : mergeInformations) {
			if (mergeInformation.getType().equals(type))
				list.add(mergeInformation);
		}
		return list;
	}

	private ArrayList<ChangeModule<E, M>> getChangesFromMergeInformationList(
			Collection<MergeInformation<E, M>> mergeInformations,
			boolean includeConflicted) {
		ArrayList<ChangeModule<E, M>> changes = new ArrayList<>();
		for (MergeInformation<E, M> mergeInformation : mergeInformations) {
			for (ChangeModule<E, M> changeModule : mergeInformation
					.getLocalChanges()) {
				if (!mergeInformation.isConflictedChange(changeModule)
						|| includeConflicted)
					changes.add(changeModule);
			}
			for (ChangeModule<E, M> changeModule : mergeInformation
					.getRemoteChanges()) {
				if (!mergeInformation.isConflictedChange(changeModule)
						|| includeConflicted)
					changes.add(changeModule);
			}
		}
		return changes;
	}

	public List<ChangeModule<E, M>> executeChanges(
			M model,
			Collection<MergeInformation<E, M>> mergeInformations,
			boolean includeConflicted) throws ChangeDeadlockException {

		ArrayList<ChangeModule<E, M>> changesToDo = getChangesFromMergeInformationList(
				mergeInformations, includeConflicted);

		runPreExecutePhase(model,
				new ArrayList<ChangeModule<E, M>>(
						changesToDo));
		runExecutePhase(model,
				new ArrayList<ChangeModule<E, M>>(
						changesToDo));

		runPostExecutePhase(model,
				new ArrayList<ChangeModule<E, M>>(
						changesToDo));

		return changesToDo;
	}

	public void runExecutePhase(M model,
			List<ChangeModule<E, M>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<E, M>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<E, M> change : changesToDo) {
				if (change.canExecute(model)) {
					change.execute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException("All canExecute-Methods fail. Couldn't do anything!");
//				throw new ChangeDeadlockException(
//						"All canExecute-Methods fail. Couldn't do anything!",
//						changesToDo, changesDone);
		}
	}

	public void runPreExecutePhase(M model,
			List<ChangeModule<E, M>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<E, M>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<E, M> change : changesToDo) {
				if (change.canPreExecute(model)) {
					change.preExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException("All canPreExecute-Methods fail. Couldn't do anything!");
//				throw new ChangeDeadlockException(
//						"All canPreExecute-Methods fail. Couldn't do anything!",
//						changesToDo, changesDone);
		}
	}

	public void runPostExecutePhase(M model,
			List<ChangeModule<E, M>> changesToDo)
			throws ChangeDeadlockException {

		List<ChangeModule<E, M>> changesDone = new ArrayList<>();

		while (!changesToDo.isEmpty()) {
			boolean somethingDone = false;
			for (ChangeModule<E, M> change : changesToDo) {
				if (change.canPostExecute(model)) {
					change.postExecute(model);
					changesDone.add(change);
					somethingDone = true;
				}
			}
			changesToDo.removeAll(changesDone);

			if (!somethingDone)
				throw new ChangeDeadlockException("All canPostExecute-Methods fail. Couldn't do anything!");
//				throw new ChangeDeadlockException(
//						"All canPostExecute-Methods fail. Couldn't do anything!",
//						changesToDo, changesDone);
		}
	}

}
