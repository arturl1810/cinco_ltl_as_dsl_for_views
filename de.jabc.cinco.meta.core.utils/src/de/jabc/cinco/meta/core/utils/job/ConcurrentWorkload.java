package de.jabc.cinco.meta.core.utils.job;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.eclipse.core.runtime.SubMonitor;

public class ConcurrentWorkload extends Workload {

	private ExecutorService pool = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
	private List<Task> tasks;
	private int tasksDone;
	private String doneTaskName = "";
	private boolean done;
	private SubMonitor monitor; 
	
	public ConcurrentWorkload(CompoundJob job, int percent) {
		super(job, percent);
	}
	
	@Override
	protected Task createTask(String name, Runnable runnable) {
		return new Task(name, runnable) {
			@Override
			protected void onDone() {
				tasksDone++;
				doneTaskName = name;
				tickMonitor();
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
			startMonitorUpdates();
			try {
				pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
			} catch (InterruptedException e) {}
			done = true;
			this.monitor.done();
		}
	}
	
	protected void startMonitorUpdates() {
		new ReiteratingThread(500,200) {
			protected void work() {
				if (done || canceled) {
					System.out.println("[## Job ##] Quit updater");
					quit();
				}
			}
			protected void tick() { updateMonitor(doneTaskName); }
		}.start();
	}
	
	protected void updateMonitor(String taskName) {
		if (monitor.isCanceled() || canceled) {
			if (!canceled) cancel();
			monitor.newChild(0)
				.subTask("Canceled by user, awaiting termination...");
		} else {
			monitor.newChild(0)
				.subTask("Completed " + tasksDone + "/" + tasks.size() + ". "
					+ (taskName != null ? taskName : ""));
		}
	}
	
	protected void tickMonitor() {
		if (!monitor.isCanceled() && !canceled) {
			tick += (double) quota / tasks.size();
			monitor.newChild((int) tick);
			tick -= (int) tick;
		}
	}
	
	@Override
	protected void cancel() {
		super.cancel();
		pool.shutdownNow();
	}
}