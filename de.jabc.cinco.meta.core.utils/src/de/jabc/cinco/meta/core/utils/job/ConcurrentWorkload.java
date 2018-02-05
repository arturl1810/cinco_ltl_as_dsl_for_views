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
	private int quotaLeft;
	private Map<Task,Future<?>> results = new HashMap<>();
	private boolean done;
	private SubMonitor monitor;
	private int maxThreads = 0;
	
	public ConcurrentWorkload(CompoundJob job, int percent) {
		super(job, percent);
	}
	
	@Override
	public void perform(SubMonitor monitor) {
		this.monitor = monitor;
		quotaLeft = quota;
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
			if (quotaLeft > 0) {
				monitor.newChild(quotaLeft);
				monitor.newChild(0);
			}
			done = true;
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
			monitor.subTask("Job canceled, awaiting termination...");
		}
//		else if (failed) {
//			monitor.newChild(0)
//				.subTask("Task failed, awaiting termination...");
//		}
		else {
			String label = "Completed " + tasksDone + "/" + tasks.size() + ".";
			if (displayName != null)
				label += " Recent: " + displayName;
			monitor.subTask(label);
		}
	}
	
	protected void tickMonitor() {
		if (!monitor.isCanceled() && !canceled) {
			tick += (double) quota / tasks.size();
			monitor.newChild((int) tick);
			quotaLeft -= (int) tick;
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
	
	public ConcurrentWorkload setMaxThreads(int max) {
		if (max < 0) {
			System.err.println("WARN: Value for max number of threads ignored: " + max);
			return this;
		}
		maxThreads = max;
		int nThreads = Runtime.getRuntime().availableProcessors();
		if (max > 0) {
			nThreads = Math.min(max, nThreads);
		}
		pool = Executors.newFixedThreadPool(nThreads);
		return this;
	}
	
}