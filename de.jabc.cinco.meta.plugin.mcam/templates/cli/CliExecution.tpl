package ${CliPackage};

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Date;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionGroup;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class CliExecution {
	
	private ${GraphModelName}Execution fe = new ${GraphModelName}Execution();

	private Options cliOptions = new Options();
	private CommandLine cmdCall = null;

	private int exitStatus = 0;
	private boolean verboseOutput = false;

	private String logFilePath = null;

	public CliExecution(String[] args) {
		super();
		initializeOptions();
		parse(args);
	}

	private void initializeOptions() {
		cliOptions.addOption("h", "help", false, "Shows this help");

		cliOptions.addOption("v", "verbose", false,
				"Show detailed output of Merge and Check");

		Option optionLogOutput = new Option("l", "log", false,
				"Log output to file");
		optionLogOutput.setArgs(1);
		optionLogOutput.setArgName("file");
		optionLogOutput.setValueSeparator(' ');
		optionLogOutput.setOptionalArg(false);
		cliOptions.addOption(optionLogOutput);

		OptionGroup groupUsage = new OptionGroup();

		Option optionManualMerge = new Option("mm", "manualMerge", false,
				"Manual Merge of 3 Files into an Output-File");
		optionManualMerge.setArgs(4);
		optionManualMerge.setArgName("orig file1 file2 output");
		optionManualMerge.setValueSeparator(' ');
		optionManualMerge.setOptionalArg(false);
		groupUsage.addOption(optionManualMerge);

		Option optionManualDiff = new Option("md", "manualDiff", false,
				"Manual diff 2 Files");
		optionManualDiff.setArgs(2);
		optionManualDiff.setArgName("file1 file2");
		optionManualDiff.setValueSeparator(' ');
		optionManualDiff.setOptionalArg(false);
		groupUsage.addOption(optionManualDiff);

		Option optionManualCheck = new Option("chk", "manualCheck", false,
				"Manual Check of target model");
		optionManualCheck.setArgs(1);
		optionManualCheck.setArgName("file");
		optionManualCheck.setValueSeparator(' ');
		optionManualCheck.setOptionalArg(false);
		groupUsage.addOption(optionManualCheck);

		Option optionGitMerge = new Option("gm", "gitMerge", false,
				"Used for integration as Git-Merge-Driver");
		optionGitMerge.setArgs(3);
		optionGitMerge.setArgName("orig local remote");
		optionGitMerge.setValueSeparator(' ');
		optionGitMerge.setOptionalArg(false);
		groupUsage.addOption(optionGitMerge);

		Option optionGitDiff = new Option("gd", "gitDiff", false,
				"Diff a File in a Git-Repository");
		optionGitDiff.setArgs(8);
		optionGitDiff.setArgName("7 git compare parameters");
		optionGitDiff.setValueSeparator(' ');
		optionGitDiff.setOptionalArg(false);
		groupUsage.addOption(optionGitDiff);

		cliOptions.addOptionGroup(groupUsage);
	}

	private void parse(String[] args) {
		CommandLineParser parser = new BasicParser();

		try {
			cmdCall = parser.parse(cliOptions, args);

			if (cmdCall.hasOption("l")) {
				String[] logFileArgs = cmdCall.getOptionValues("l");
				logFilePath = logFileArgs[0];
			}

			if (cmdCall.hasOption("v"))
				verboseOutput = true;

		} catch (ParseException pvException) {
			System.err.println(pvException.getMessage());
			System.exit(1);
		}
	}

	public void executeCall() {
		Date now = new Date();
		outputData("\n" + "----------------------------------------\n"
				+ now.toString() + "\n"
				+ "----------------------------------------\n" + "\n");

		if (cmdCall.hasOption("h") || cmdCall.getOptions().length == 0) {
			printHelp();
		}

		/*
		 * Run Manual Diff
		 */
		if (cmdCall.hasOption("md")) {
			String[] args = cmdCall.getOptionValues("md");
			runCompare(args[0], args[1]);
		}

		/*
		 * Run Manual Merge
		 */
		if (cmdCall.hasOption("mm")) {
			String[] args = cmdCall.getOptionValues("mm");
			runMerge(args[0], args[1], args[2], args[3]);
		}

		/*
		 * Run Git Diff
		 */
		if (cmdCall.hasOption("gd")) {
			String[] args = cmdCall.getOptionValues("gd");
			runCompare(args[1], args[4]);
		}

		/*
		 * Run Git Merge
		 */
		if (cmdCall.hasOption("gm")) {
			String[] args = cmdCall.getOptionValues("gm");
			runMerge(args[0], args[1], args[2], args[1]);
		}

		/*
		 * Run Manual Check
		 */
		if (cmdCall.hasOption("chk")) {
			String[] args = cmdCall.getOptionValues("chk");
			runCheck(args[0]);
		}

		System.exit(exitStatus);
	}

	private void printHelp() {
		HelpFormatter hFormater = new HelpFormatter();
		hFormater
				.printHelp("program <v> <l file> <gd|gm|md|mm|chk parameters>",
						cliOptions);
	}

	private void printError(Exception e, String customMsg, File file,
			${GraphModelName}Adapter model) {
		String errorMsg = "";
		errorMsg += ("!!! ------------[ Error ]------------ !!! \n");
		errorMsg += ("Section: " + customMsg + "\n");
		if (model != null)
			errorMsg += ("Model: " + model.getModelName() + "\n");
		if (file != null)
			errorMsg += ("File: " + file.getAbsolutePath() + "\n");
		errorMsg += ("Exception-Msg: " + e.getMessage() + "\n");
		errorMsg += ("!!! --------------------------------- !!! \n");

		outputData(errorMsg);
		System.err.print(errorMsg);
	}

	private void backupFiles(File localFile, File remoteFile, File origFile) {
		String basePath = localFile.getParent() + File.separator;
		String baseFileName = localFile.getName();

		File newRemoteFile = new File(basePath + baseFileName + ".remote");
		File newOrigFile = new File(basePath + baseFileName + ".orig");

		try {
			if (remoteFile != null)
				Files.copy(remoteFile.toPath(), newRemoteFile.toPath(),
						StandardCopyOption.REPLACE_EXISTING);
			if (origFile != null)
				Files.copy(origFile.toPath(), newOrigFile.toPath(),
						StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			e.printStackTrace();
		}

		System.err.println("Remote/Origin - Backups created for '" + basePath
				+ baseFileName + "'");
		System.err.println("!!! --------------------------------- !!!");
	}

	private void outputData(String data) {
		System.out.println(data);
		if (cmdCall.hasOption("l")) {
			try {
				Files.write(Paths.get(logFilePath), data.toString().getBytes(),
						StandardOpenOption.CREATE, StandardOpenOption.APPEND);
			} catch (IOException e) {
				System.err.println("Log file not found?! \n" + e.getMessage());
				System.exit(1);
			}
		}

	}

	private void runMerge(String origPath, String localPath, String remotePath,
			String mergePath) {
		File origFile = null;
		File localFile = null;
		File mergeFile = null;
		File remoteFile = null;
		try {
			origFile = fe.getFile(origPath, true);
			remoteFile = fe.getFile(remotePath, true);
			localFile = fe.getFile(localPath, true);
			mergeFile = fe.getFile(mergePath);
		} catch (Exception e) {
			backupFiles(localFile, remoteFile, origFile);
			printError(e, "Merge - Load Files", localFile, null);
		}

		${GraphModelName}Adapter local = null;
		try {
			local = fe.initApiAdapter(localFile);
		} catch (Exception e) {
			printError(e, "Merge - Load Model 'Local'", localFile, local);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		${GraphModelName}Adapter orig = null;
		try {
			orig = fe.initApiAdapter(origFile);
		} catch (Exception e) {
			printError(e, "Merge - Load Model 'Original'", origFile, orig);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		${GraphModelName}Adapter remote = null;
		try {
			remote = fe.initApiAdapter(remoteFile);
		} catch (Exception e) {
			printError(e, "Merge - Load Model 'Remote'", remoteFile, remote);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		${GraphModelName}Adapter mergeModel = null;
		try {
			mergeModel = fe.initApiAdapter(origFile);
		} catch (Exception e) {
			printError(e, "Merge - Load Model 'Merged'", mergeFile, mergeModel);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = null;
		try {
			localCompare = fe.executeComparePhase(orig, local);
		} catch (Exception e) {
			printError(e, "Merge - Executing localCompare", null, null);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = null;
		try {
			remoteCompare = fe
					.executeComparePhase(orig, remote);
		} catch (Exception e) {
			printError(e, "Merge - Executing remoteCompare", null, null);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;
		try {
			mp = fe.executeMergePhase(localCompare,
					remoteCompare, mergeModel);
		} catch (Exception e) {
			printError(e, "Merge - Executing Merge", null, null);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;
		try {
			cp = fe.executeCheckPhase(mergeModel);
		} catch (Exception e) {
			printError(e, "Merge - Executing Check", null, null);
			backupFiles(localFile, remoteFile, origFile);
			System.exit(1);
		}

		try {
			outputData(mp.toString(verboseOutput));

			if (mp.hasConflicts())
				exitStatus += 1;

			outputData(cp.toString(verboseOutput));
			outputData("----------------------------------------\n"
					+ "----------------------------------------\n \n");

			if (cp.hasErrors() || cp.hasWarnings())
				exitStatus += 2;

			cp.getModel().writeModel(mergeFile);
		} catch (Exception e) {
			printError(e, "Merge - Writing File", mergeFile, null);
			System.exit(1);
		}
	}

	private void runCompare(String origPath, String localPath) {
		${GraphModelName}Adapter model1 = null;
		File file1 = null;
		try {
			file1 = fe.getFile(origPath, true);
			model1 = fe.initApiAdapter(file1);
		} catch (Exception e) {
			printError(e, "Diff - Load Model1", file1, model1);
			System.exit(1);
		}

		${GraphModelName}Adapter model2 = null;
		File file2 = null;
		try {
			file2 = fe.getFile(localPath, true);
			model2 = fe.initApiAdapter(file2);
		} catch (Exception e) {
			printError(e, "Diff - Load Model2", file2, model2);
			System.exit(1);
		}

		try {
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compare = fe
					.executeComparePhase(model1, model2);
			outputData(compare.toString());
		} catch (Exception e) {
			printError(e, "Diff - CompareProcess", file1, model1);
			System.exit(1);
		}
	}

	private void runCheck(String filePath) {
		${GraphModelName}Adapter model1 = null;
		File file1 = null;
		try {
			file1 = fe.getFile(filePath, true);
			model1 = fe.initApiAdapter(file1);

			CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> check = fe
					.executeCheckPhase(model1);
			outputData(check.toString(verboseOutput));

			if (check.hasErrors())
				exitStatus += 1;

			model1.writeModel(file1);
		} catch (Exception e) {
			ArrayList<${GraphModelName}Adapter> models = new ArrayList<>();
			models.add(model1);
			printError(e, "Manual Check", file1, model1);
			System.exit(1);
		}
	}
}

