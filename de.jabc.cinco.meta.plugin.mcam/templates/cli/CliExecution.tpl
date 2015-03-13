package ${CliPackage};

import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import java.io.File;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionGroup;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class CliExecution {
	private Options cliOptions = new Options();
	private CommandLine cmdCall = null;

	private int exitStatus = 0;
	private boolean verboseOutput = false;

	public CliExecution(String[] args) {
		super();
		initializeOptions();
		parse(args);
	}

	private void initializeOptions() {
		cliOptions.addOption("h", "help", false, "Shows this help");
		
		cliOptions.addOption("v", "verbose", false, "Show detailed output of Merge and Check");

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
			
			if (cmdCall.hasOption("v"))
				verboseOutput = true;
				
		} catch (ParseException pvException) {
			System.out.println(pvException.getMessage());
			System.exit(1);
		}
	}

	public void executeCall() {
		if (cmdCall.hasOption("h") || cmdCall.getOptions().length == 0) {
			printHelp();
		}

		/*
		 *  Run Manual Diff
		 */
		if (cmdCall.hasOption("md")) {
			String[] args = cmdCall.getOptionValues("md");

			File file1 = FrameworkExecution.getFile(args[0], true);
			${GraphModelName}Adapter model1 = FrameworkExecution.initApiAdapter(file1);

			File file2 = FrameworkExecution.getFile(args[1], true);
			${GraphModelName}Adapter model2 = FrameworkExecution.initApiAdapter(file2);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compare = FrameworkExecution.executeComparePhase(
					model1, model2);
			System.out.println(compare.toString());
		}
		
		/*
		 *  Run Manual Merge
		 */
		if (cmdCall.hasOption("mm")) {
			String[] args = cmdCall.getOptionValues("mm");

			File origFile = FrameworkExecution.getFile(args[0], true);
			${GraphModelName}Adapter orig = FrameworkExecution.initApiAdapter(origFile);
			
			File localFile = FrameworkExecution.getFile(args[1], true);
			${GraphModelName}Adapter local = FrameworkExecution.initApiAdapter(localFile);

			File remoteFile = FrameworkExecution.getFile(args[2], true);
			${GraphModelName}Adapter remote = FrameworkExecution.initApiAdapter(remoteFile);

			File mergeFile = FrameworkExecution.getFile(args[3]);
			${GraphModelName}Adapter mergeModel = FrameworkExecution.initApiAdapter(origFile);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = FrameworkExecution
					.executeComparePhase(orig, local);
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = FrameworkExecution
					.executeComparePhase(orig, remote);
			MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = FrameworkExecution.executeMergePhase(
					localCompare, remoteCompare, mergeModel);

			System.out.println(mp.toString(verboseOutput));

			if (mp.hasConflicts())
				exitStatus += 1;

			CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = FrameworkExecution.executeCheckPhase(mergeModel);
			System.out.println(cp.toString(verboseOutput));

			if (cp.hasErrors() || cp.hasWarnings())
				exitStatus += 2;
				
			if (exitStatus > 0) {
				FrameworkExecution.createTmpFiles(origFile, localFile, remoteFile);
			} else {
				mergeModel.writeModel(mergeFile);
			}
		}

		/*
		 *  Run Git Diff
		 */
		if (cmdCall.hasOption("gd")) {
			String[] args = cmdCall.getOptionValues("gd");

			File file1 = FrameworkExecution.getFile(args[1], true);
			${GraphModelName}Adapter model1 = FrameworkExecution.initApiAdapter(file1);

			File file2 = FrameworkExecution.getFile(args[4], true);
			${GraphModelName}Adapter model2 = FrameworkExecution.initApiAdapter(file2);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> compare = FrameworkExecution.executeComparePhase(
					model1, model2);
			System.out.println(compare.toString());
		}

		/*
		 *  Run Git Merge
		 */
		if (cmdCall.hasOption("gm")) {
			String[] args = cmdCall.getOptionValues("gm");

			File origFile = FrameworkExecution.getFile(args[0], true);
			${GraphModelName}Adapter orig = FrameworkExecution.initApiAdapter(origFile);

			File localFile = FrameworkExecution.getFile(args[1], true);
			${GraphModelName}Adapter local = FrameworkExecution.initApiAdapter(localFile);

			File remoteFile = FrameworkExecution.getFile(args[2], true);
			${GraphModelName}Adapter remote = FrameworkExecution.initApiAdapter(remoteFile);

			File mergeFile = FrameworkExecution.getFile(args[1], true);
			${GraphModelName}Adapter mergeModel = FrameworkExecution
					.initApiAdapter(mergeFile);

			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = FrameworkExecution
					.executeComparePhase(orig, local);
			CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = FrameworkExecution
					.executeComparePhase(orig, remote);
			MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = FrameworkExecution.executeMergePhase(
					localCompare, remoteCompare, mergeModel);

			System.out.println(mp.toString(verboseOutput));

			if (mp.hasConflicts())
				exitStatus += 1;

			CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = FrameworkExecution.executeCheckPhase(mergeModel);
			System.out.println(cp.toString(verboseOutput));
			System.out.println("----------------------------------------");
			System.out.println("----------------------------------------");
			System.out.println();

			if (cp.hasErrors() || cp.hasWarnings())
				exitStatus += 2;

			if (exitStatus > 0) {
				FrameworkExecution.createTmpFiles(origFile, localFile, remoteFile);
			} else {
				mergeModel.writeModel(mergeFile);
			}
		}
		
		/*
		 *  Run Manual Check
		 */
		if (cmdCall.hasOption("chk")) {
			String[] args = cmdCall.getOptionValues("chk");

			File file1 = FrameworkExecution.getFile(args[0], true);
			${GraphModelName}Adapter model1 = FrameworkExecution.initApiAdapter(file1);

			CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> check = FrameworkExecution.executeCheckPhase(model1);
			System.out.println(check.toString(verboseOutput));

			if (check.hasErrors())
				exitStatus += 1;
			
			model1.writeModel(file1);
		}
		
		System.exit(exitStatus);
	}

	private void printHelp() {
		HelpFormatter hFormater = new HelpFormatter();
		hFormater.printHelp("programm <v> <gd|gm|md|mm|chk> <parameters>",
				cliOptions);
	}
}
