package ${CliPackage};

import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistry;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistryClassTreeBased;
import info.scce.mcam.framework.registry.check.CheckModuleRegistry;
import info.scce.mcam.framework.registry.check.CheckModuleRegistryListBased;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

<#if CustomMergeStrategy == "">
import ${StrategyPackage}.${MergeStrategyClass};
</#if>

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import org.eclipse.emf.ecore.resource.Resource;


public class FrameworkExecution {
	public static File getFile(String filepath) {
		File file = new File(filepath);
		return file;
	}

	public static void createTmpFiles(File origFile, File localFile, File remoteFile) {
		String basePath = localFile.getParent() + File.separator;
		String baseFileName = localFile.getName();
		File tmpRemoteFile = new File(basePath + baseFileName + ".remote");
		File tmpLocalFile = new File(basePath + baseFileName + ".local");
		try {
			Files.copy(localFile.toPath(), tmpLocalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
			Files.copy(remoteFile.toPath(), tmpRemoteFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
			Files.copy(origFile.toPath(), localFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
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

	public static ${GraphModelName}Adapter initApiAdapterFromResource(Resource resource, File file) {
		${GraphModelName}Adapter model = new ${GraphModelName}Adapter();
		model.setModel(resource, file);
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

		<#list CheckModules as module>
		reg.add(new ${module}());
		</#list>

		return reg;
	}

	public static CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeComparePhase(
			${GraphModelName}Adapter model1, ${GraphModelName}Adapter model2) {

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compareProcess = FrameworkExecution.createComparePhase(model1, model2);
		compareProcess.compare();
		return compareProcess;
	}

	public static MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeMergePhase(
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare,
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare,
			${GraphModelName}Adapter mergeModel) {

		MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mergeProcess = FrameworkExecution.createMergePhase(localCompare, remoteCompare, mergeModel);
		mergeProcess.createMergeModel();
		return mergeProcess;
	}

	public static CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> executeCheckPhase(
			${GraphModelName}Adapter model) {
		CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> checkProcess = FrameworkExecution.createCheckPhase(model);
		checkProcess.checkModel();
		return checkProcess;
	}

	public static CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createComparePhase(
			${GraphModelName}Adapter model1, ${GraphModelName}Adapter model2) {

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compareProcess = new CompareProcess<>(
				getChangeModuleRegistry(), model1, model2);
		return compareProcess;
	}

	public static MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createMergePhase(
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare,
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare,
			${GraphModelName}Adapter mergeModel) {

		MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mergeProcess = new MergeProcess<>(
				mergeModel, localCompare, remoteCompare);
		<#if CustomMergeStrategy == "">
		mergeProcess.setMergeStrategy(new ${MergeStrategyClass}());
		<#else>
		mergeProcess.setMergeStrategy(new ${CustomMergeStrategy}());
		</#if>
		return mergeProcess;
	}

	public static CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> createCheckPhase(
			${GraphModelName}Adapter model) {
		CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> checkProcess = new CheckProcess<>(
				getCheckModuleRegistry(), model);
		return checkProcess;
	}
}
