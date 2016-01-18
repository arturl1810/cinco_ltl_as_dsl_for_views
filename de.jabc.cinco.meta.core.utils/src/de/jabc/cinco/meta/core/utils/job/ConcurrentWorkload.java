package de.jabc.cinco.meta.core.utils.job;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import org.eclipse.core.runtime.SubMonitor;

public class ConcurrentWorkload extends Workload {

	private ExecutorService pool = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
	private int tasksDone;
	private Map<Task,Future<?>> results = new HashMap<>();
	private boolean done;
	private SubMonitor monitor; 
	
	public ConcurrentWorkload(CompoundJob job, int percent) {
		super(job, percent);
	}
	
	@Override
	public void perform(SubMonitor monitor) {
		this.monitor = monitor;
		tasks = buildTasks();
		if (tasks.isEmpty()) {
			monitor.newChild(quota).subTask("");
		} else {
			tasks.forEach(this::submit);
			pool.shutdown();
			startMonitorUpdates();
			try {
				pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
			} catch (InterruptedException e) {}
			done = true;
			this.monitor.done();
		}
	}
	
	private void submit(Task task) {
		results.put(task, pool.submit(task.runnable));
	}
	
	@Override
	protected void taskDone(Task task) {
		tasksDone++;
		currentTask = task;
		displayName = task.name;
		tickMonitor();
		super.taskDone(task);
	}
	
	protected void startMonitorUpdates() {
		new ReiteratingThread(500,200) {
			protected void work() {
				if (done || canceled) {
					quit();
				}
			}
			protected void tick() {
				updateMonitor();
			}
		}.start();
	}
	
	protected void updateMonitor() {
		if (monitor.isCanceled() || canceled) {
			if (!canceled) cancel();
			monitor.newChild(0)
				.subTask("Job canceled, awaiting termination...");
		}
//		else if (failed) {
//			monitor.newChild(0)
//				.subTask("Task failed, awaiting termination...");
//		}
		else {
			String label = "Completed " + tasksDone + "/" + tasks.size() + ".";
			if (displayName != null)
				label += " Recent: " + displayName;
			monitor.newChild(0)
				.subTask(label);
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
		pool.shutdownNow();
		super.cancel();
	}
	
	@Override
	public void requestCancel() {
		pool.shutdownNow();
		super.requestCancel();
	}
}