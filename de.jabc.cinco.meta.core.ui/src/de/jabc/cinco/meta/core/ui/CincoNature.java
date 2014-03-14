package de.jabc.cinco.meta.core.ui;

import java.util.ArrayList;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IProjectNature;
import org.eclipse.core.runtime.CoreException;

public class CincoNature implements IProjectNature {

    private IProject project;

    public void configure() throws CoreException {
    	 try {
    	      IProjectDescription description = project.getDescription();
    	      String[] natures = description.getNatureIds();
    	      String[] newNatures = new String[natures.length + 1];
    	      System.arraycopy(natures, 0, newNatures, 0, natures.length);
    	      newNatures[natures.length] = "de.jabc.cinco.meta.core.CincoNature";
    	      description.setNatureIds(newNatures);
    	      project.setDescription(description, null);
    	   } catch (CoreException e) {
    	      // Something went wrong
    	   }
    }
    public void deconfigure() throws CoreException {
    	IProjectDescription description = project.getDescription();
	    String[] natures = description.getNatureIds();
	    ArrayList<String> newNatures = new ArrayList<>();
	    for(String nature: natures){
	    	if(!nature.equals("de.jabc.cinco.meta.core.CincoNature"))
	    		newNatures.add(nature);
	    }
	    description.setNatureIds(newNatures.toArray(new String[newNatures.size()]));
        project.setDescription(description, null);

    }
    public IProject getProject() {
       return project;
    }
    public void setProject(IProject value) {
       project = value;
    }

}
