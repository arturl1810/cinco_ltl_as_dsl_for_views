package de.jabc.cinco.meta.core.wizards;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.jdt.core.JavaConventions;

public class CincoWizardUtils {
	
	public static String validateModelName(String modelName) {
		if (!modelName.isEmpty()) {
			IStatus nameStatus = JavaConventions.validateIdentifier(modelName, "1.7", "1.7");
			if (nameStatus.getCode() != IStatus.OK) {
				return "Model Name: " + nameStatus.getMessage();
			}
			else if (!Character.isUpperCase(modelName.charAt(0))) {
				return "Model Name: must start with capital letter";
			}
		}
		else {
			return "Model Name: must not be empty";
		}
		return null;
	}

	public static String validatePackageName(String packageName) {
		if (!packageName.isEmpty()) {
			IStatus nameStatus = JavaConventions.validatePackageName(packageName, "1.7", "1.7");
			if (nameStatus.getCode() != IStatus.OK) {
				return "Package Name: " + nameStatus.getMessage();
			}
		} else {
			return "Package Name: must not be empty";
		}
		return null;
	}

	public static String validateProjectName(String projectName) {
		if (projectName.isEmpty())
			return "Enter project name";
		IProject[] projects = ResourcesPlugin.getWorkspace().getRoot()
				.getProjects();
		for (IProject p : projects) {
			if (p.getName().equals(projectName))
				return "Project: " + projectName + " already exists";
		}
		if (projectName.matches(".*[:/\\\\\"&<>\\?#,;].*")) {
			return "The project name contains illegal characters (:/\"&<>?#,;)";
		}

		return null;
	}

}
