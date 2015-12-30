package de.jabc.cinco.meta.core.utils.job;

import org.eclipse.core.runtime.IProgressMonitor;


/**
   Job factory that provides static methods to create runtime
   jobs whose progress can be monitored. Example:
   <pre>
   JobFactory.job("TestJob")
     .label("Running sequential tasks...")
     .consume(25)
       .task("Task A", () -> this.work(2000))
       .task("Task B", this::work)
       .ifCanceled(() -> showMessage("Canceled before concurrent tasks"))
     .label("Running concurrent tasks...")
     .consume(50)
       .taskForEach(items, this::processItem, this::getItemName)
       .ifCanceled(() -> showMessage("Canceled during concurrent tasks"))
     .onCanceled(() -> showMessage("Canceled anywhere"))
     .onFinished(() -> showMessage("Finished"))
     .schedule();
   </pre>
 */
public class JobFactory {
	
	/**
	 * Creates and returns a job object that can handle separate
	 * groups of tasks and cares about progress monitoring.
	 * 
	 * @param name  Display name of the job that is used as
	 *   title of the progress dialog.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name) {
		return new CompoundJob(name);
	}
	
	/**
	 * Creates and returns a job object that can handle separate
	 * groups of tasks and cares about progress monitoring.
	 * 
	 * @param name  Display name of the job that is used as
	 *   title of the progress dialog.
	 * @param user  If {@code true}, the user is provided with 
	 *   a cancelable progress monitor at runtime. Otherwise, an
	 *   uncancelable job is executed in the background.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name, boolean user) {
		return new CompoundJob(name, user);
	}
	
	/**
	 * Creates and returns a job object that can handle separate
	 * groups of tasks and cares about progress monitoring.
	 * 
	 * @param name  Display name of the job that is used as
	 *   title of the progress dialog.
	 * @param monitor  Progress monitor to be used instead of the default
	 *   monitor that is provided at runtime.
	 * @param user  If {@code true}, the user is provided with 
	 *   a cancelable progress monitor at runtime. Otherwise, an
	 *   uncancelable job is executed in the background.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name, IProgressMonitor monitor) {
		return new CompoundJob(name, monitor);
	}
	
	/**
	 * Creates and returns a job object that can handle separate
	 * groups of tasks and cares about progress monitoring.
	 * 
	 * @param name  Display name of the job that is used as
	 *   title of the progress dialog.
	 * @param monitor  Progress monitor to be used instead of the default
	 *   monitor that is provided at runtime.
	 * @param user  If {@code true}, the user is provided with 
	 *   a cancelable progress monitor at runtime. Otherwise, an
	 *   uncancelable job is executed in the background.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name, IProgressMonitor monitor, boolean user) {
		return new CompoundJob(name, monitor, user);
	}
}
