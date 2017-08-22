package ${CliPackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};

import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistry;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistryClassTreeBased;
import info.scce.mcam.framework.registry.check.CheckModuleRegistry;
import info.scce.mcam.framework.registry.check.CheckModuleRegistryListBased;

import java.io.File;
import org.eclipse.emf.ecore.resource.Resource;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoMergeStrategy;

public class ${GraphModelName}Execution extends de.jabc.cinco.meta.plugin.mcam.runtime.core.FrameworkExecution<${GraphModelName}Id, ${GraphModelName}, ${GraphModelName}Adapter> {

	@Override
	public ${GraphModelName}Adapter initApiAdapter(File file) {
		${GraphModelName}Adapter model = new ${GraphModelName}Adapter();
		model.readModel(file);
		return model;
	}

	@Override
	public ${GraphModelName}Adapter initApiAdapterFromResource(Resource resource, File file) {
		${GraphModelName}Adapter model = new ${GraphModelName}Adapter();
		model.readModel(resource, file);
		return model;
	}

	@Override
	public ChangeModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> getChangeModuleRegistry() {
		ChangeModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> reg = new ChangeModuleRegistryClassTreeBased<>();
		
		<#list ChangeModules as module>
		reg.add(new ${module}());
		</#list>

		return reg;
	}

	@Override
	public CheckModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> getCheckModuleRegistry() {
		CheckModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> reg = new CheckModuleRegistryListBased<>();

		<#list CheckModules as module>
		reg.add(new ${module}());
		</#list>

		return reg;
	}

	@Override
	public MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createMergePhase(
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare,
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare,
			${GraphModelName}Adapter mergeModel) {

		MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mergeProcess = new MergeProcess<>(
				mergeModel, localCompare, remoteCompare);
		<#if CustomMergeStrategy == "">
		mergeProcess.setMergeStrategy(new _CincoMergeStrategy<${GraphModelName}Id, ${GraphModelName}Adapter>());
		<#else>
		mergeProcess.setMergeStrategy(new ${CustomMergeStrategy}());
		</#if>
		return mergeProcess;
	}

}
