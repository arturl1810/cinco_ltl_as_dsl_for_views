package de.jabc.cinco.meta.plugin.mcam.runtime.core;

import graphmodel.GraphModel;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;
import info.scce.mcam.framework.registry.change.ChangeModuleRegistry;
import info.scce.mcam.framework.registry.check.CheckModuleRegistry;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import org.eclipse.emf.ecore.resource.Resource;

public abstract class FrameworkExecution<E extends _CincoId, G extends GraphModel, M extends _CincoAdapter<E, G>> {

	public File getFile(String filepath) {
		File file = new File(filepath);
		return file;
	}

	public void createTmpFiles(File origFile, File localFile, File remoteFile) {
		String basePath = localFile.getParent() + File.separator;
		String baseFileName = localFile.getName();
		File tmpRemoteFile = new File(basePath + baseFileName + ".remote");
		File tmpLocalFile = new File(basePath + baseFileName + ".local");
		try {
			Files.copy(localFile.toPath(), tmpLocalFile.toPath(),
					StandardCopyOption.REPLACE_EXISTING);
			Files.copy(remoteFile.toPath(), tmpRemoteFile.toPath(),
					StandardCopyOption.REPLACE_EXISTING);
			Files.copy(origFile.toPath(), localFile.toPath(),
					StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public File getFile(String filepath, boolean checkExists) {
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

	public abstract M initApiAdapter(File file);

	public abstract M initApiAdapterFromResource(Resource resource, File file);

	public abstract CheckModuleRegistry<E, M> getCheckModuleRegistry();

	public abstract ChangeModuleRegistry<E, M> getChangeModuleRegistry();

	public abstract MergeProcess<E, M> createMergePhase(
			CompareProcess<E, M> localCompare,
			CompareProcess<E, M> remoteCompare, M mergeModel);

	public CompareProcess<E, M> executeComparePhase(M model1, M model2) {
		CompareProcess<E, M> compareProcess = this.createComparePhase(model1,
				model2);
		compareProcess.compare();
		return compareProcess;
	}

	public MergeProcess<E, M> executeMergePhase(
			CompareProcess<E, M> localCompare,
			CompareProcess<E, M> remoteCompare, M mergeModel) {

		MergeProcess<E, M> mergeProcess = this.createMergePhase(localCompare,
				remoteCompare, mergeModel);
		mergeProcess.createMergeModel();
		return mergeProcess;
	}

	public CheckProcess<E, M> executeCheckPhase(M model) {
		CheckProcess<E, M> checkProcess = this.createCheckPhase(model);
		checkProcess.checkModel();
		return checkProcess;
	}

	public CompareProcess<E, M> createComparePhase(M model1, M model2) {

		CompareProcess<E, M> compareProcess = new CompareProcess<>(
				getChangeModuleRegistry(), model1, model2);
		return compareProcess;
	}

	public CheckProcess<E, M> createCheckPhase(M model) {
		CheckProcess<E, M> checkProcess = new CheckProcess<>(
				getCheckModuleRegistry(), model);
		return checkProcess;
	}
}
