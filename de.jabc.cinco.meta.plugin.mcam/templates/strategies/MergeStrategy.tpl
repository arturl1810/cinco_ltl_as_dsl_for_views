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

	private ${GraphModelName}Adapter mergeModel = null;
	
	@Override
	public void execute(${GraphModelName}Adapter model, Collection<MergeInformation<${GraphModelName}Id, ${GraphModelName}Adapter>> mergeInformations) {

		DefaultMergeStrategy<${GraphModelName}Id, ${GraphModelName}Adapter> defaultMergeStrategy = new DefaultMergeStrategy<>();
		
		defaultMergeStrategy.execute(model, getMergeInformationListByType(MergeType.ADDED, mergeInformations));
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

}
