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
	public static String pagePackageSuffix = "pages";

	private GraphModel gModel;
	private String graphModelName = null;

	private IProject mcamViewProject = null;

	private String mcamViewBasePackage = null;
	private String mcamProjectBasePackage = null;

	private String graphModelProjectName = null;
	private String graphModelPackage = null;

	private boolean generateMerge = false;
	private boolean generateCheck = false;

	public Map<String, Object> data = new HashMap<>();

	public McamViewGenerator(GraphModel gModel, IProject project,
			String graphModelPackage, String graphModelProjectName,
			McamImplementationGenerator genMcam) {
		super();
		this.gModel = gModel;
		this.graphModelName = gModel.getName();
		this.graphModelProjectName = graphModelProjectName;
		this.graphModelPackage = graphModelPackage;

		this.mcamViewProject = project;

		this.mcamProjectBasePackage = genMcam.getMcamProjectBasePackage();
		this.mcamViewBasePackage = graphModelProjectName + "."
				+ McamImplementationGenerator.mcamPackageSuffix + "."
				+ viewPackageSuffix;

		parseAnnotations();

		data.put("GraphModelName", this.graphModelName);
		data.put("GraphModelExtension", this.gModel.getFileExtension());
		data.put("GraphModelPackage", this.graphModelPackage);
		data.put("GraphModelProject", this.graphModelProjectName);

		data.put("McamViewBasePackage", this.mcamViewBasePackage);
		data.put("McamViewPagePackage", this.mcamViewBasePackage + "."
				+ pagePackageSuffix);

		data.put("McamProject", genMcam.getProject().getName());

		data.put("AdapterPackage", this.mcamProjectBasePackage + "."
				+ McamImplementationGenerator.adapterPackageSuffix);
		data.put("CliPackage", this.mcamProjectBasePackage + "."
				+ McamImplementationGenerator.cliPackageSuffix);

		data.put("ViewViewPackage", this.mcamViewBasePackage + "."
				+ this.graphModelName.toLowerCase() + "." + viewPackageSuffix);

	}

	public String getMcamViewBasePackage() {
		return mcamViewBasePackage;
	}

	public String getMcamViewPackage() {
		return this.mcamViewBasePackage + "."
				+ this.graphModelName.toLowerCase();
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
				generateConflictViewPage();
			}

			if (generateCheck) {
				generateCheckViewPage();
			}

			generatePageFactory();

			generateActivator();
			generatePluginXml();
			generateManifest();
			generateBuildProperties();
			generateContextsXml();

			return "default";
		} catch (IOException | TemplateException e) {
			e.printStackTrace();
		}
		return "error";
	}

	private void generateActivator() throws IOException, TemplateException {
		data.put("ClassName", "Activator");

		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/Activator.tpl", mcamViewProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewBasePackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generatePluginXml() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/plugin.tpl", mcamViewProject);
		templateGen.setFilename("plugin.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateManifest() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/Manifest.tpl", mcamViewProject);
		templateGen.setFilename("MANIFEST.MF");
		templateGen.setPkg("");
		templateGen.setBasePath("META-INF");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateBuildProperties() throws IOException,
			TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/build.properties", mcamViewProject);
		templateGen.setFilename("build.properties");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateContextsXml() throws IOException, TemplateException {
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/contexts.tpl", mcamViewProject);
		templateGen.setFilename("contexts.xml");
		templateGen.setPkg("");
		templateGen.setBasePath("");
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateCheckViewPage() throws IOException, TemplateException {
		data.put("ClassName", graphModelName + "CheckViewPage");
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/CheckViewPage.tpl", mcamViewProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewPagePackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generateConflictViewPage() throws IOException,
			TemplateException {
		data.put("ClassName", graphModelName + "ConflictViewPage");
		TemplateGenerator templateGen = new TemplateGenerator(
				"templates/views/ConflictViewPage.tpl", mcamViewProject);
		templateGen.setFilename((String) data.get("ClassName") + ".java");
		templateGen.setPkg((String) data.get("McamViewPagePackage"));
		templateGen.setData(data);
		templateGen.generateFile();
	}

	private void generatePageFactory() throws IOException, TemplateException {
		data.put("ClassName", "PageFactoryImpl");

		String filename = "src-gen"
				+ File.separator
				+ ((String) data.get("McamViewBasePackage")).replace(".",
						File.separator) + File.separator
				+ (String) data.get("ClassName") + ".java";

		IFile res = mcamViewProject.getFile(filename);
		if (res == null || !res.exists()) {
			TemplateGenerator templateGen = new TemplateGenerator(
					"templates/views/PageFactoryImpl.tpl", mcamViewProject);
			templateGen.setFilename((String) data.get("ClassName") + ".java");
			templateGen.setPkg((String) data.get("McamViewBasePackage"));
			templateGen.setData(data);
			templateGen.generateFile();

			System.out.println("CheckFactory not found... now generated!");
		}

		IFile file = mcamViewProject.getFile(filename);

		if (generateCheck) {
			String code_check = "if (obj instanceof " + graphModelPackage + "."
					+ graphModelName.toLowerCase() + "." + graphModelName
					+ ") return new "
					+ (String) data.get("McamViewPagePackage") + "."
					+ graphModelName + "CheckViewPage(file); \n";
			insertCodeAfterMarker(
					file.getRawLocation().makeAbsolute().toFile(),
					"// @FACTORY_CHECK", code_check);
		}

		if (generateMerge) {
			String code_conflict = "if (obj instanceof " + graphModelPackage
					+ "." + graphModelName.toLowerCase() + "." + graphModelName
					+ ") return new "
					+ (String) data.get("McamViewPagePackage") + "."
					+ graphModelName + "ConflictViewPage(file); \n";
			insertCodeAfterMarker(
					file.getRawLocation().makeAbsolute().toFile(),
					"// @FACTORY_CONFLICT", code_conflict);
		}
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

				if (!originalText.contains(code))
					originalText = originalText.replaceAll(marker, marker
							+ "\n" + code);

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
