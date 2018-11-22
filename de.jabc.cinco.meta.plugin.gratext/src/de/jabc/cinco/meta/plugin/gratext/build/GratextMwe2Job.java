package de.jabc.cinco.meta.plugin.gratext.build;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.jobs.IJobManager;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationType;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.debug.core.ILaunchListener;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.debug.core.model.IProcess;

import com.google.common.collect.Lists;

import de.jabc.cinco.meta.core.utils.CincoProperties;
import de.jabc.cinco.meta.core.utils.job.ReiteratingThread;

/**
 * Created by Steve Bosselmann on 07/03/15.
 */
public abstract class GratextMwe2Job extends ReiteratingThread {

	private static final int INTERVAL = 1000;
	
	private IProject project;
	private IFile mwe2File;
    
    private List<IProcess> processes;
	private List<ILaunchConfiguration> launches;
	private List<ILaunchConfiguration> unseen;
	private ILaunchListener launchListener;
	
	public GratextMwe2Job(IProject project) {
		super(INTERVAL, INTERVAL / 10);
        this.project = project;
    }
	
	public GratextMwe2Job(IProject project, IFile mwe2File) {
		super(INTERVAL, INTERVAL / 10);
        this.project = project;
        this.mwe2File = mwe2File;
    }
	
	public abstract void onTerminated(IProcess process);
	
	public abstract void onQuit();
    
    @Override
    protected void prepare() {
    	if (mwe2File == null) try {
    		mwe2File = getProjectFiles(project, "mwe2").stream()
				.filter(file -> file.getName().endsWith("Gratext.mwe2"))
				.collect(Collectors.toList()).get(0);
    	} catch(Exception e) {
    		e.printStackTrace();
    		quit();
    		return;
    	}
		launches = new ArrayList<>();
		//System.out.println("[Gratext.Listener" + hashCode() + "] Created launches list: " + launches.hashCode());
		
		unseen = new ArrayList<>();
    	processes = new ArrayList<>();
		registerLaunchListener();
		launch(project, mwe2File);
    }

    @Override
    protected void work() {
    	for (IProcess process : new ArrayList<>(processes)) try {
    		if (process.isTerminated()) {
    			int value = process.getExitValue();
    			//System.out.println("[Gratext.Listener" + hashCode() + "] Process " + process.hashCode() + " terminated > exit code = " + value);
    			terminate(process);
    		}
		} catch (DebugException e) {
			e.printStackTrace();
		}
    }
    
    @Override
    protected void afterwork() {
    	ILaunchManager manager = DebugPlugin.getDefault().getLaunchManager();
		ILaunchConfigurationType type = manager.getLaunchConfigurationType("org.eclipse.emf.mwe2.launch.Mwe2LaunchConfigurationType");
		try {
			Arrays.stream(manager.getLaunchConfigurations(type))
				.filter(cfg -> cfg.getName().equals(mwe2File.getName()))
				.forEach(cfg -> { try { 
					cfg.delete();
				} catch(CoreException e) { e.printStackTrace(); }});
		} catch (CoreException e) {
			e.printStackTrace();
		}
    }
    
    @Override
    protected void cleanup() {
    	ILaunchManager manager = DebugPlugin.getDefault().getLaunchManager();
    	manager.removeLaunchListener(launchListener);
    }
    
    private void launch(IProject project, IFile file) {
		ILaunchManager manager = DebugPlugin.getDefault().getLaunchManager();
		ILaunchConfigurationType type = manager.getLaunchConfigurationType("org.eclipse.emf.mwe2.launch.Mwe2LaunchConfigurationType");
		try {
			Arrays.stream(manager.getLaunchConfigurations(type))
				.filter(cfg -> cfg.getName().equals(file.getName()))
				.forEach(cfg -> { try { 
					cfg.delete();
				} catch(CoreException e) { e.printStackTrace(); }});
			launch(type, project, file);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
    
    private void launch(ILaunchConfigurationType type, IProject project, IFile file) throws CoreException {
		ILaunchConfigurationWorkingCopy cfg = type.newInstance(null, file.getName());
		
		cfg.setAttribute("org.eclipse.debug.core.ATTR_REFRESH_SCOPE", "${project}");
		cfg.setAttribute("org.eclipse.debug.core.MAPPED_RESOURCE_PATHS", Lists.newArrayList(new String[] {"/" + project.getName()}));
		cfg.setAttribute("org.eclipse.debug.core.MAPPED_RESOURCE_TYPES", Lists.newArrayList(new String[] {"4"}));
		cfg.setAttribute("org.eclipse.jdt.launching.ATTR_USE_START_ON_FIRST_THREAD", true);
		cfg.setAttribute("org.eclipse.jdt.launching.MAIN_TYPE", "org.eclipse.emf.mwe2.launch.runtime.Mwe2Launcher");
		cfg.setAttribute("org.eclipse.jdt.launching.PROGRAM_ARGUMENTS", file.getProjectRelativePath().toPortableString() /* "src/info/scce/dime/dad/gratext/DADGratext.mwe2" */);
		cfg.setAttribute("org.eclipse.jdt.launching.VM_ARGUMENTS", CincoProperties.getVmArgs());
		cfg.setAttribute("org.eclipse.jdt.launching.PROJECT_ATTR", project.getName() /* "info.scce.dime.dad.gratext" */);
		cfg.setAttribute("org.eclipse.ptp.launch.ATTR_AUTO_RUN_COMMAND", true);
		ILaunchConfiguration launchCfg = cfg.doSave();
		register(launchCfg);
		
		/*
		 * Wait for an eventual auto-build process to complete
		 * before launching the Mwe2 workflow
		 */
		IJobManager manager = Job.getJobManager();
		Job[] build = manager.find(ResourcesPlugin.FAMILY_AUTO_BUILD); 
		if (build.length == 1) try {
			build[0].join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		try {
			launchCfg.launch(ILaunchManager.RUN_MODE, null);
		} catch(ConcurrentModificationException e) {
			// do nothing here, does not seem to break it
		}
	}
    
    private void registerLaunchListener() {
		ILaunchManager manager = DebugPlugin.getDefault().getLaunchManager();
		//System.out.println("[Gratext.Listener" + hashCode() + "] Register launch listener");
		launchListener = new ILaunchListener() {

			@Override
			public void launchChanged(ILaunch launch) {
				//System.out.println("[Gratext.Listener" + hashCode() + "] Launch changed: " + launches.hashCode());
				if (launches.contains(launch.getLaunchConfiguration()))
					for (IProcess process : launch.getProcesses()) {
						//System.out.println("[Gratext.Listener" + hashCode() + "]  > Process known= " + processes.contains(process));
						if (process != null && !processes.contains(process)) {
							register(process, launch.getLaunchConfiguration());
						}
					}
			}

			@Override public void launchRemoved(ILaunch launch) {}
			@Override public void launchAdded(ILaunch launch) {
				//System.out.println("[Gratext.Listener" + hashCode() + "] Launch added: " + launches.hashCode());
			}
		};
		manager.addLaunchListener(launchListener);
	}
    
    private void register(ILaunchConfiguration cfg) {
    	launches.add(cfg);
		unseen.add(cfg);
		//System.out.println("[Gratext.Listener" + hashCode() + "] Register launch in " + launches.hashCode() + " size = " + launches.size());
    }
    
    private void register(IProcess process, ILaunchConfiguration cfg) {
    	//System.out.println("[Gratext.Listener" + hashCode() + "] Register process " + process);
		processes.add(process);
		unseen.remove(cfg);
    }
    
    private void terminate(IProcess process) {
    	onTerminated(process);
		processes.remove(process);
		if (processes.isEmpty() && unseen.isEmpty()) {
			//System.out.println("[Gratext.Listener" + hashCode() + "] No processes left, quit.");
			quit();
		}
    }
    
    protected List<IFile> getProjectFiles(IProject project, String fileExtension) {
		return getFiles(project, fileExtension, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
	    List<IFile> files = new ArrayList<>();
	    IResource[] members = null;
	    try {
	    	members = container.members();
	    } catch(CoreException e) {
	    	e.printStackTrace();
	    }
	    if (members != null)
			Arrays.stream(members).forEach(mbr -> {
			   if (recurse && mbr instanceof IContainer)
				   files.addAll(getFiles((IContainer) mbr, fileExtension, recurse));
			   else if (mbr instanceof IFile && !mbr.isDerived()) {
				   IFile file = (IFile) mbr;
				   if (fileExtension == null || fileExtension.equals(file.getFileExtension()))
				       files.add(file);
			   }
		   });
		return files;
	}
	
	public static IFile createFile(IProject project, String name, InputStream content) {
		final IFile file = project.getFile(new Path(name));
		try {
			if (file.exists())
				file.setContents(content, true, true, null);
			else file.create(content, true, null);
		} catch (final Exception e) {
			e.printStackTrace();
		} finally {
			try {
				content.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return file;
	}
	
    @Override
    public void quit() {
    	super.quit();
    	onQuit();
    }
    
}
