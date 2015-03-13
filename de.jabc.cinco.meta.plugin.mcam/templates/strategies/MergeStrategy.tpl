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


public class ${MergeStrategyClass} implements MergeStrategy<${GraphModelName}Id, ${GraphModelName}Adapter> {

	@Override
	public void execute(${GraphModelName}Adapter model, Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {

		DefaultMergeStrategy<${GraphModelName}Id, ${GraphModelName}Adapter> defaultMergeStrategy = new DefaultMergeStrategy<>();
		
		try {
			executeAddPhase(model, getMergeInformationListByType(MergeType.ADDED, mergeInformations));
		} catch (Exception e) {
			e.printStackTrace();
		}

		defaultMergeStrategy.execute(model, getMergeInformationListByType(MergeType.CHANGED, mergeInformations));
		defaultMergeStrategy.execute(model, getMergeInformationListByType(MergeType.DELETED, mergeInformations));
	}

	private List<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> getMergeInformationListByType(MergeType type, Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {
		List<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> list = new ArrayList<>();
		for (MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter> mergeInformation : mergeInformations) {
			if (mergeInformation.getType().equals(type))
				list.add(mergeInformation);
		}
		return list;
	}

	public void executeAddPhase(${GraphModelName}Adapter model,
			Collection<MergeInformation<${GraphModelName}Id,${GraphModelName}Adapter>> mergeInformations) throws Exception {
		for (MergeInformation<${GraphModelName}Id,${GraphModelName}Adapter> mergeInformation : mergeInformations) {
			List<ChangeModule<${GraphModelName}Id,${GraphModelName}Adapter>> changesToDo = new ArrayList<>();
			List<ChangeModule<${GraphModelName}Id,${GraphModelName}Adapter>> changesDone = new ArrayList<>();
			changesToDo.addAll(mergeInformation.getLocalChanges());
			changesToDo.addAll(mergeInformation.getRemoteChanges());
			
			while (!changesToDo.isEmpty()) {
				boolean somethingDone = false;
				for (ChangeModule<FlowGraphId,FlowGraphAdapter> change : changesToDo) {
					if (change.canPreExecute(model)) {
						change.preExecute(model);
						changesDone.add(change);
						somethingDone = true;
					} 
				}
				if (!somethingDone)
					throw new Exception("All canPreExecute-Methods fail. Couldn't do anything!");
				changesToDo.removeAll(changesDone);
			}
			changesToDo.addAll(changesDone);
			
			while (!changesToDo.isEmpty()) {
				boolean somethingDone = false;
				for (ChangeModule<FlowGraphId,FlowGraphAdapter> change : changesToDo) {
					if (change.canExecute(model)) {
						change.execute(model);
						changesDone.add(change);
						somethingDone = true;
					} 
				}
				if (!somethingDone)
					throw new Exception("All canExecute-Methods fail. Couldn't do anything!");
				changesToDo.removeAll(changesDone);
			}
			changesToDo.addAll(changesDone);
			
			while (!changesToDo.isEmpty()) {
				boolean somethingDone = false;
				for (ChangeModule<FlowGraphId,FlowGraphAdapter> change : changesToDo) {
					if (change.canPostExecute(model)) {
						change.postExecute(model);
						changesDone.add(change);
						somethingDone = true;
					} 
				}
				if (!somethingDone)
					throw new Exception("All canPostExecute-Methods fail. Couldn't do anything!");
				changesToDo.removeAll(changesDone);
			}
			changesToDo.addAll(changesDone);
		}
	}
}
