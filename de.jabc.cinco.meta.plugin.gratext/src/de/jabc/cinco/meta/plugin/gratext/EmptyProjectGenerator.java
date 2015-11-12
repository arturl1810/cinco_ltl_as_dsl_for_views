package de.jabc.cinco.meta.plugin.gratext;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IProject;

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
	protected void createFiles(FileCreator creator) {
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

}
