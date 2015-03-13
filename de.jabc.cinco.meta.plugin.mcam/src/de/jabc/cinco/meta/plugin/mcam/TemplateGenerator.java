package de.jabc.cinco.meta.plugin.mcam;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Map;

import org.apache.commons.io.IOUtils;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import freemarker.cache.StringTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;

public class TemplateGenerator {

	private String pkg = null;
	private String filename = null;
	private String templateFile = null;
	
	private String basePath = "src-gen";

	private Template template = null;

	private IProject project = null;

	private Map<String, Object> data = null;

	public String getPkg() {
		return pkg;
	}

	public void setPkg(String pkg) {
		this.pkg = pkg;
	}
	
	public String getBasePath() {
		return basePath;
	}

	public void setBasePath(String basePath) {
		this.basePath = basePath;
	}

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}

	public Map<String, Object> getData() {
		return data;
	}

	public void setData(Map<String, Object> data) {
		this.data = data;
	}

	public TemplateGenerator(String templateFile, IProject project) {
		super();
		this.templateFile = templateFile;
		this.project = project;
	}

	public void generateFile() throws IOException, TemplateException {
		System.out.println("Generating " + filename + "...");

		template = loadTemplate();
		saveTemplate();
	}

	private Template loadTemplate() throws IOException {
		Bundle bundle = Platform.getBundle("de.jabc.cinco.meta.plugin.mcam");
		InputStream in = FileLocator.openStream(bundle, new Path(templateFile),
				true);

		// Load template
		StringTemplateLoader stringLoader = new StringTemplateLoader();
		String firstTemplate = "myTemplate";
		stringLoader.putTemplate(firstTemplate, IOUtils.toString(in, "UTF-8"));
		Configuration cfg = new Configuration();
		cfg.setTemplateLoader(stringLoader);
		return cfg.getTemplate(firstTemplate);
	}

	private void printTemplate() throws TemplateException, IOException {
		Writer out = new OutputStreamWriter(System.out);
		template.process(data, out);
		out.flush();
	}

	private void saveTemplate() throws IOException, TemplateException {
		String targetFilePath = createFilePath();
		File fname = new File(targetFilePath);
		fname.getParentFile().mkdirs();
		fname.createNewFile();
		Writer file = new FileWriter(fname);
		template.process(data, file);
		file.flush();
		file.close();
	}

	private String createFilePath() {
		String pPath = project.getLocation().toFile().toString();
		String sep = File.separator;
		String pkgAsPath = pkg.replace(".", sep);
		if (!basePath.equals(""))
			basePath += sep;
		return pPath + sep + basePath + pkgAsPath + sep + filename;
	}

}
