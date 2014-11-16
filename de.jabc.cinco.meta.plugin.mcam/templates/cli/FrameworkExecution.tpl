package ${Package};

import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistry;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistryClassTreeBased;
import info.scce.mcam.framework.registry.check.CheckModuleRegistry;
import info.scce.mcam.framework.registry.check.CheckModuleRegistryListBased;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

<#list ChangeModules as module>
import ${ChangeModulePackage}.${module};
</#list>

import java.io.File;
import java.io.FileNotFoundException;

public class FrameworkExecution {
	public static File getFile(String filepath) {
		File file = new File(filepath);
		return file;
	}

	public static File getFile(String filepath, boolean checkExists) {
		File file = new File(filepath);
		if (!file.exists() && checkExists)
			try {
				throw new FileNotFoundException("File '" + filepath
						+ "' does not exist!");
			} catch (FileNotFoundException e) {
				System.err.println(e);
				System.exit(1);
			}
		return file;
	}

	public static ${GraphModelName}Adapter initApiAdapter(File file) {
		${GraphModelName}Adapter model = new ${GraphModelName}Adapter();
		model.readModel(file);
		return model;
	}

	public static ChangeModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> getChangeModuleRegistry() {
		ChangeModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> reg = new ChangeModuleRegistryClassTreeBased<>();
		
		<#list ChangeModules as module>
		reg.add(new ${module}());
		</#list>

		return reg;
	}

	public static CheckModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> getCheckModuleRegistry() {
		CheckModuleRegistry<${GraphModelName}Id, ${GraphModelName}Adapter> reg = new CheckModuleRegistryListBased<>();

		return reg;
	}

	public static CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeComparePhase(
			${GraphModelName}Adapter model1, ${GraphModelName}Adapter model2) {

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compareProcess = new CompareProcess<>(
				getChangeModuleRegistry(), model1, model2);
		compareProcess.compare();
		return compareProcess;
	}

	public static MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeMergePhase(
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare,
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare,
			${GraphModelName}Adapter mergeModel) {

		MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mergeProcess = new MergeProcess<>(
				mergeModel, localCompare, remoteCompare);
		mergeProcess.createMergeModel();
		return mergeProcess;
	}

	public static CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeCheckPhase(
			${GraphModelName}Adapter model) {
		CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> checkProcess = new CheckProcess<>(
				getCheckModuleRegistry(), model);
		checkProcess.checkModel();
		return checkProcess;
	}
}
