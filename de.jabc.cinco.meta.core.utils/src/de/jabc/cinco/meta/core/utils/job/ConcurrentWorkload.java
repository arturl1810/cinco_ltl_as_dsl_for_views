package de.jabc.cinco.meta.core.utils.job;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.eclipse.core.runtime.SubMonitor;

public class ConcurrentWorkload extends Workload {

	private ExecutorService pool = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
	private List<Task> tasks;
	private int done;
	private SubMonitor monitor; 
	
	public ConcurrentWorkload(CompoundJob job, int percent) {
		super(job, percent);
	}
	
	@Override
	protected Task createTask(String name, Runnable runnable) {
		return new Task(name, runnable) {
			@Override
			protected void onDone() {
				done++;
				if (monitor.isCanceled())
					pool.shutdownNow();
				updateMonitor(name);
			}
		};
	}
	
	@Override
	public void perform(SubMonitor monitor) {
		this.monitor = monitor;
		tasks = buildTasks();
		if (tasks.isEmpty()) {
			monitor.newChild(quota).subTask("");
		} else {
			tasks.forEach(task -> pool.submit(task.runnable));
			pool.shutdown();
			updateMonitor("");
			try {
				pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
			} catch (InterruptedException e) {}
		}
	}
	
	protected void updateMonitor(String taskName) {
		if (monitor.isCanceled()) {
			monitor.newChild(0).subTask("Canceled by user, awaiting termination...");
		} else {
			tick += (double) quota / tasks.size();
			monitor.newChild((int) tick).subTask(
					"Completed " + done + "/" + tasks.size() + ". " + taskName);
			tick -= (int) tick;
		}
	}
}