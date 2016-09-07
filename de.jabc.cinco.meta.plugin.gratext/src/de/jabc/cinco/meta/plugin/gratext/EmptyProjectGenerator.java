package de.jabc.cinco.meta.plugin.gratext;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IProject;

import de.jabc.cinco.meta.plugin.gratext.descriptor.Descriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;

public class EmptyProjectGenerator extends ProjectGenerator {

	private String projectName;
	
	EmptyProjectGenerator(String projectName) {
		this.projectName = projectName;
	}

	@Override
	protected void init(Map<String, Object> context) {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	protected void createFiles() {
		// TODO Auto-generated method stub
		
	}

	@Override
	protected List<String> getNatures() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected String getSymbolicName() {
		return projectName;
	}

	@Override
	protected List<String> getBuildPropertiesBinIncludes() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getExportedPackages() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected Map<String, String> getPackages() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<IProject> getReferencedProjects() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected Set<String> getRequiredBundles() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getSourceFolders() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected List<String> getManifestExtensions() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public GraphModelDescriptor getModelDescriptor() {
		return null;
	}

	@Override
	public ProjectDescriptor getProjectDescriptor() {
		Descriptor<IProject> desc = new ProjectDescriptor(project)
			.setBasePackage(projectName);
		return (ProjectDescriptor) desc;
	}

	@Override
	public String getProjectAcronym() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getProjectSuffix() {
		// TODO Auto-generated method stub
		return null;
	}

}
