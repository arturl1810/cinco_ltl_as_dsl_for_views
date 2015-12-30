package de.jabc.cinco.meta.core.utils.job;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;

import com.google.common.collect.Iterables;

/**
 * Runtime job whose progress can be monitored.
 */
public class CompoundJob extends Job {
	
	private SubMonitor monitor;
	private IProgressMonitor parentMonitor;
	private IStatus status;
	private List<Step> steps = new ArrayList<>();
	
	private Runnable onDone;
	private Runnable onFinished;
	private Runnable onCanceled;
	private Runnable onFailed;

	private List<Runnable> ifDone = new ArrayList<>();
	private List<Runnable> ifCanceled = new ArrayList<>();
	private List<Runnable> ifFailed = new ArrayList<>();
	
	public CompoundJob(String name) {
		this(name, true);
	}
	
	public CompoundJob(String name, boolean user) {
		super(name);
		setUser(user);
		registerListener();
	}
	
	public CompoundJob(String name, IProgressMonitor monitor) {
		super(name);
		parentMonitor = monitor;
		registerListener();
	}
	
	public CompoundJob(String name, IProgressMonitor monitor, boolean user) {
		super(name);
		parentMonitor = monitor;
		setUser(user);
		registerListener();
	}
	
	/**
	 * Sets the display name of the current task group.
	 * 
	 * @param label  Display name of the current task group.
	 * @return The job object.
	 */
	public CompoundJob label(final String label) {
		steps.add((monitor) -> monitor.setTaskName(label));
		return this;
	}
	
	/**
	 * Initiates the creation of a task group that in
	 * total consumes the specified work quota. The latter
	 * does not represent a percentage but is interpreted
	 * as an installment relative to the total workload of
	 * the corresponding job. The job's total workload is
	 * the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks that are created with the returned
	 * Workload object will be performed sequentially.
	 * If you are interested in parallel execution use
	 * {@linkplain #consumeConcurrent(int) consumeConcurrent(int quota)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @return Workload object
	 */
	public Workload consume(int quota) {
		Workload workload = new Workload(this, quota);
		steps.add(workload);
		return workload;
	}
	
	/**
	 * Initiates the creation of a task group that in
	 * total consumes the specified work quota. The latter
	 * does not represent a percentage but is interpreted
	 * as an installment relative to the total workload of
	 * the corresponding job. The job's total workload is
	 * the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks that are created with the returned
	 * Workload object will be performed in parallel.
	 * If you are interested in sequential execution use
	 * {@linkplain #consume(int) consume(int quota)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @return Workload object
	 */
	public Workload consumeConcurrent(int quota) {
		ConcurrentWorkload workload = new ConcurrentWorkload(this, quota);
		steps.add(workload);
		return workload;
	}

	/**
	 * Sets an event handler to be called if the execution of
	 * the current group of tasks has stopped for whatever reason,
	 * i.e. finished, canceled or failed.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob ifDone(Runnable handler) {
		ifDone.add(handler);
		steps.add((monitor) -> ifDone.remove(0));
		return this;
	}

	/**
	 * Sets an event handler to be called if the execution of
	 * the current group of tasks has been canceled.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob ifCanceled(Runnable handler) {
		ifCanceled.add(handler);
		steps.add((monitor) -> ifCanceled.remove(0));
		return this;
	}

	/**
	 * Sets an event handler to be called if the execution of
	 * the current group of tasks has failed.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob ifFailed(Runnable handler) {
		ifFailed.add(handler);
		steps.add((monitor) -> ifFailed.remove(0));
		return this;
	}

	/**
	 * Sets an event handler to be called if the execution of
	 * all tasks of the job has stopped for whatever reason,
	 * i.e. finished, canceled or failed.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob onDone(Runnable handler) {
		onDone = handler;
		return this;
	}

	/**
	 * Sets an event handler to be called if the execution
	 * of all the tasks of the job has been completed successfully.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob onFinished(Runnable handler) {
		onFinished = handler;
		return this;
	}

	/**
	 * Sets an event handler to be called if the execution
	 * of the tasks of the job has been canceled eventually.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob onCanceled(Runnable handler) {
		onCanceled = handler;
		return this;
	}
	
	/**
	 * Sets an event handler to be called if the execution
	 * of any task of the job has failed.
	 * 
	 * @param handler  Runnable to be executed if the event happens.
	 */
	public CompoundJob onFailed(Runnable handler) {
		onFailed = handler;
		return this;
	}
	
	@Override
	protected IStatus run(IProgressMonitor pm) {
		wrapMonitor(pm);
		status = Status.OK_STATUS;
		try {
			// necessary to update task name in progress window
			Thread.sleep(100);
		} catch (InterruptedException e) {}
		monitor.newChild(5);
		steps.forEach(step -> {
			if (monitor.isCanceled())
				status = Status.CANCEL_STATUS;
			else perform(step);
		});
		return status;
	}
	
	private void perform(Step step) {
		try {
			step.perform(monitor);
		} catch(Exception e) {
			status = new Status(Status.ERROR, getName(),
				"Tasks failed:\n" + step, e);
		}
	}
		
	private void registerListener() {
		addJobChangeListener(new JobChangeAdapter() {
	        public void done(IJobChangeEvent event) {
	        	Iterable<Runnable> handlers = new ArrayList<>();
	        	if (event.getResult().isOK())
	        		handlers = Iterables.concat(getHandlers(ifDone), getHandlers(onFinished, onDone));
	        	else if (event.getResult().equals(Status.CANCEL_STATUS)) {
	        		handlers = Iterables.concat(getHandlers(ifCanceled), getHandlers(ifDone), getHandlers(onCanceled, onDone));
	        	} else {
	        		handlers = Iterables.concat(getHandlers(ifFailed), getHandlers(ifDone), getHandlers(onFailed, onDone));
	        	}
	        	handlers.forEach(handler -> handler.run());
	        }
	     });
	}
	
	private List<Runnable> getHandlers(List<Runnable> list) {
		List<Runnable> retVal = new ArrayList<>();
		if (!list.isEmpty())
			retVal.add(list.get(0));
		return retVal;
	}
	
	private List<Runnable> getHandlers(Runnable... handlers) {
		List<Runnable> retVal = new ArrayList<>();
		Arrays.stream(handlers)
			.filter(handler -> handler != null)
			.forEach(retVal::add);
		return retVal;
	}
	
	protected void wrapMonitor(IProgressMonitor pm) {
		monitor = SubMonitor.convert(
			parentMonitor != null ? parentMonitor : pm,
			getTotalWorkload() + 5);
	}
	
	protected int getTotalWorkload() {
		return steps.stream()
			.filter(ComplexStep.class::isInstance)
			.map(ComplexStep.class::cast)
			.mapToInt(step -> step.getQuota())
			.sum();
	}
}