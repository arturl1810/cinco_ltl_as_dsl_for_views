package de.jabc.cinco.meta.core.utils.job;


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
	 * 
	 * @param name  Display name of the task.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name) {
		return new CompoundJob(name);
	}
	
	/**
	 * 
	 * @param name  Display name of the task.
	 * @param user  If {@code true}, the user is provided with 
	 *   a cancelable progress monitor at runtime. Otherwise, an
	 *   uncancelable job is executed in the background.
	 * @return  The job object.
	 */
	public static CompoundJob job(String name, boolean user) {
		return new CompoundJob(name, user);
	}
}
