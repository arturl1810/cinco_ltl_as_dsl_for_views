package de.jabc.cinco.meta.plugin.mcam;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;

import freemarker.template.TemplateException;

public class McamViewGenerator {
	public static String viewPackageSuffix = "views";
	public static String utilPackageSuffix = "util";

	private GraphModel gModel;
	private String graphModelName = null;

	private IProject project = null;

	private String basePackage = null;
	private String mcamBasePackage = null;

	private boolean generateMerge = false;
	private boolean generateCheck = false;

	public Map<String, Object> data = new HashMap<>();

	public McamViewGenerator(GraphModel gModel, IProject project,
			String basePackage, McamImplementationGenerator genMcam) {
		super();
		this.gModel = gModel;
		this.project = project;
		this.graphModelName = gModel.getName();
		this.basePackage = basePackage + "."
				+ McamImplementationGenerator.mcamPackageSuffix + "."
				+ viewPackageSuffix + "." + graphModelName.toLowerCase();
		this.mcamBasePackage = genMcam.getBasePackage();

		parseAnnotations();

		data.put("GraphModelName", graphModelName);
		data.put("GraphModelExtension", gModel.getFileExtension());

		data.put("GraphModelPackage",
				basePackage + "." + graphModelName.toLowerCase());
		data.put("BasePackage", basePackage);

		data.put("McamProject", genMcam.getProject().getName());
		data.put("McamViewProject", project.getName());

		data.put("AdapterPackage", mcamBasePackage + "."
				+ McamImplementationGenerator.adapterPackageSuffix);
		data.put("StrategyPackage", mcamBasePackage + "."
				+ McamImplementationGenerator.strategiesPackageSuffix);
		data.put("UtilPackage", mcamBasePackage + "."
				+ McamImplementationGenerator.utilPackageSuffix);
		data.put("CliPackage", mcamBasePackage + "."
				+ McamImplementationGenerator.cliPackageSuffix);

		data.put("ViewPackage", this.basePackage);
		data.put("ViewViewPackage", this.basePackage + "." + viewPackageSuffix);
		data.put("ViewUtilPackage", this.basePackage + "." + utilPackageSuffix);
	}

	public String getBasePackage() {
		return basePackage;
	}

	public boolean doGenerateMerge() {
		return generateMerge;
	}

	public boolean doGenerateCheck() {
		return generateCheck;
	}

	private void parseAnnotations() {
		for (Annotation annotation : gModel.getAnnotations()) {
			if ("mcam".equals(annotation.getName())) {
				List<String> values = annotation.getValue();
				if (values.size() == 0 || values.contains("check"))
					generateCheck = true;
				if (values.size() == 0 || values.contains("merge"))
					generateMerge = true;
			}
		}
	}

	public String generate() {
		try {
			if (generateMerge) {
				generateConflictView();
				generateConflictViewInformation();
				generateConflictViewInformationAbstract();
				generateConflictViewInformationFactory();
				generateMergeProcessTreeView();
			}

			if (generateCheck) {
				generateCheckView();
				generateCheckViewInformation();
				generateCheckViewInformationAbstract();
				generateCheckViewInformationFactory();
				generateCheckProcessTreeView();
			}

			generateActivator();
			generatePluginXml();
			generateManifest();
			generateBuildProperties();
			generateContextsXml();
			generateResourceChangeListener();
			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}

	private void generateActivator() throws IOException, TemplateException {
		data.put("ClassName", "Activator");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/Activator.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewProject"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateMergeProcessTreeView() throws IOException,
			TemplateException {
		data.put("ClassName", "MergeProcessContentProvider");
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessContentProvider.tpl",
				project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();

		data.put("ClassName", "MergeProcessLabelProvider");
		TemplateGenerator templateGen2 = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessLabelProvider.tpl",
				project);
		templateGen2.setFilename((String) data.get("ClassName") + ".java");
		templateGen2.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen2.setData(data);
		templateGen2.generateFile();

		data.put("ClassName", "MergeProcessTypeFilter");
		TemplateGenerator templateGen3 = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessTypeFilter.tpl", project);
		templateGen3.setFilename((String) data.get("ClassName") + ".java");
		templateGen3.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen3.setData(data);
		templateGen3.generateFile();

		data.put("ClassName", "MergeProcessSorterAlphabetical");
		TemplateGenerator templateGen4 = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessSorterAlphabetical.tpl",
				project);
		templateGen4.setFilename((String) data.get("ClassName") + ".java");
		templateGen4.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen4.setData(data);
		templateGen4.generateFile();

		data.put("ClassName", "MergeProcessSorterType");
		TemplateGenerator templateGen5 = new TemplateGenerator(
				"templates/eclipse_views/MergeProcessSorterType.tpl", project);
		templateGen5.setFilename((String) data.get("ClassName") + ".java");
		templateGen5.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen5.setData(data);
		templateGen5.generateFile();
	}

	private void generateCheckProcessTreeView() throws IOException,
			TemplateException {
		data.put("ClassName", "CheckProcessContentProvider");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckProcessContentProvider.tpl",
				project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();

		data.put("ClassName", "CheckProcessLabelProvider");

		TemplateGenerator templateGen2 = new TemplateGenerator(
				"templates/eclipse_views/CheckProcessLabelProvider.tpl",
				project);
		templateGen2.setFilename((String) data.get("ClassName") + ".java");
		templateGen2.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen2.setData(data);
		templateGen2.generateFile();
	}

	private void generateCheckViewInformation() throws IOException,
			TemplateException {
		data.put("ClassName", "CheckViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckViewInformation.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateCheckView() throws IOException, TemplateException {
		data.put("ClassName", "CheckView");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckView.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewProject"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateConflictViewInformation() throws IOException,
			TemplateException {
		data.put("ClassName", "ConflictViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ConflictViewInformation.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".views");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateConflictView() throws IOException, TemplateException {
		data.put("ClassName", "ConflictView");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ConflictView.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewProject"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateConflictViewInformationFactory() throws IOException,
			TemplateException {
		data.put("ClassName", "ConflictViewInformationFactory");
		String filename = "src-gen"
				+ File.separator
				+ ((String) data.get("McamViewProject")).replace(".",
						File.separator) + File.separator
				+ (String) data.get("ClassName") + ".java";

		IFile res = project.getFile(filename);
		if (res == null || !res.exists()) {
			TemplateGenerator templateGen = new TemplateGenerator(
					"templates/eclipse_views/ConflictViewInformationFactory.tpl",
					project);
			templateGen.setFilename((String) data.get("ClassName") + ".java");
			templateGen.setPkg((String) data.get("McamViewProject"));
			templateGen.setData(data);
			templateGen.generateFile();

			System.out.println("ConflictFactory not found... now generated!");
		}

		IFile file = project.getFile(filename);
		String code = "if (obj instanceof "
				+ (String) data.get("GraphModelPackage")
				+ "."
				+ graphModelName
				+ ") return new "
				+ (String) data.get("ViewViewPackage")
				+ ".ConflictViewInformation(origFile, remoteFile, localFile, file, res); \n";
		insertCodeAfterMarker(file.getRawLocation().makeAbsolute().toFile(),
				"// @FACTORY", code);
	}

	private void generateCheckViewInformationFactory() throws IOException,
			TemplateException {
		data.put("ClassName", "CheckViewInformationFactory");

		String filename = "src-gen"
				+ File.separator
				+ ((String) data.get("McamViewProject")).replace(".",
						File.separator) + File.separator
				+ (String) data.get("ClassName") + ".java";

		IFile res = project.getFile(filename);
		if (res == null || !res.exists()) {
			TemplateGenerator templateGen = new TemplateGenerator(
					"templates/eclipse_views/CheckViewInformationFactory.tpl",
					project);
			templateGen.setFilename((String) data.get("ClassName") + ".java");
			templateGen.setPkg((String) data.get("McamViewProject"));
			templateGen.setData(data);
			templateGen.generateFile();

			System.out.println("CheckFactory not found... now generated!");
		}

		IFile file = project.getFile(filename);
		String code = "if (obj instanceof "
				+ (String) data.get("GraphModelPackage") + "." + graphModelName
				+ ") return new " + (String) data.get("ViewViewPackage")
				+ ".CheckViewInformation(origFile, res); \n";
		insertCodeAfterMarker(file.getRawLocation().makeAbsolute().toFile(),
				"// @FACTORY", code);
	}

	private void generateCheckViewInformationAbstract() throws IOException,
			TemplateException {
		data.put("ClassName", "CheckViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/CheckViewInformationAbstract.tpl",
				project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewProject"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateConflictViewInformationAbstract() throws IOException,
			TemplateException {
		data.put("ClassName", "ConflictViewInformation");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ConflictViewInformationAbstract.tpl",
				project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewProject"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generatePluginXml() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/plugin.tpl", project);
		templateGen.setFilename("plugin.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateManifest() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/Manifest.tpl", project);
		templateGen.setFilename("MANIFEST.MF");
		templateGen.setPkg("");
		templateGen.setBasePath("META-INF");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateBuildProperties() throws IOException,
			TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/build.properties", project);
		templateGen.setFilename("build.properties");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateContextsXml() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/contexts.tpl", project);
		templateGen.setFilename("contexts.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateResourceChangeListener() throws IOException,
			TemplateException {
		data.put("ClassName", "ResourceChangeListener");
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/eclipse_views/ResourceChangeListener.tpl", project);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen.setData(data);
		templateGen.generateFile();

		TemplateGenerator templateGen2 = new TemplateGenerator(
				"templates/eclipse_views/DeltaPrinter.tpl", project);
		templateGen2.setFilename("DeltaPrinter.java");
		templateGen2.setPkg((String) data.get("ViewPackage") + ".util");
		templateGen2.setData(data);
		templateGen2.generateFile();
	}

	private void insertCodeAfterMarker(File file, String marker, String code) {
		try {
			if (file.exists()) {
				FileInputStream fis;

				fis = new FileInputStream(file);

				BufferedReader reader = new BufferedReader(
						new InputStreamReader(fis));
				String line = null;
				String originalText = new String();
				while ((line = reader.readLine()) != null) {
					originalText += line.concat("\n");
				}
				fis.close();

				originalText = originalText.replaceAll(marker, marker + "\n"
						+ code);

				System.out.println(originalText);

				FileOutputStream fos = new FileOutputStream(file);
				fos.write(originalText.getBytes());
				fos.close();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
