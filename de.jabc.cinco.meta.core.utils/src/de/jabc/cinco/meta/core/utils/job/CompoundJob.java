package de.jabc.cinco.meta.core.utils.job;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.xtext.xbase.lib.Pair;

/**
 * Runtime job whose progress can be monitored.
 */
public class CompoundJob extends Job {
	
	private SubMonitor monitor;
	private IProgressMonitor parentMonitor;
	private boolean canceled;
	private boolean cancelOnFail = true;
	protected List<String> failedTaskNames = new ArrayList<>();
	private IStatus status;
	private List<Step> steps = new ArrayList<>();
	
	private Runnable onDone;
	private Runnable onFinished;
	private Runnable onFinishedMessage;
	private Runnable onCanceled;
	private Runnable onCanceledMessage;
	private Runnable onFailed;
	private Runnable onFailedMessage;

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
		this(name);
		parentMonitor = monitor;
	}
	
	public CompoundJob(String name, IProgressMonitor monitor, boolean user) {
		this(name, user);
		parentMonitor = monitor;
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
	 * Workload object will be performed sequentially.
	 * If you are interested in parallel execution use
	 * {@linkplain #consumeConcurrent(int) consumeConcurrent(int quota)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @param label  Display name of the current task group.
	 * @return Workload object
	 */
	public Workload consume(int quota, String label) {
		return label(label).consume(quota);
	}
	
	/**
	 * Creates a task group that in total consumes the specified
	 * work quota. The latter does not represent a percentage but
	 * is interpreted as an installment relative to the total
	 * workload of the corresponding job. The job's total workload
	 * is the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks will be performed in the order of the specified
	 * task list.
	 * If you are interested in parallel execution use
	 * {@linkplain #consumeConcurrent(int,List) consumeConcurrent(int quota, List tasks)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @param tasks  The list of tasks to be performed.
	 * @return Workload object
	 */
	public CompoundJob consume(int quota, List<Pair<String, Runnable>> tasks) {
		Workload workload = new Workload(this, quota);
		tasks.forEach(task -> 
			workload.task(task.getKey(), task.getValue()));
		steps.add(workload);
		return this;
	}
	
	/**
	 * Creates a task group that in total consumes the specified
	 * work quota. The latter does not represent a percentage but
	 * is interpreted as an installment relative to the total
	 * workload of the corresponding job. The job's total workload
	 * is the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks will be performed in the order of the specified
	 * task list.
	 * If you are interested in parallel execution use
	 * {@linkplain #consumeConcurrent(int,List) consumeConcurrent(int quota, List tasks)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @param label  Display name of the current task group.
	 * @param tasks  The list of tasks to be performed.
	 * @return Workload object
	 */
	public CompoundJob consume(int quota, String label, List<Pair<String, Runnable>> tasks) {
		return label(label).consume(quota, tasks);
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
	public ConcurrentWorkload consumeConcurrent(int quota) {
		ConcurrentWorkload workload = new ConcurrentWorkload(this, quota);
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
	 * @param label  Display name of the current task group.
	 * @return Workload object
	 */
	public Workload consumeConcurrent(int quota, String label) {
		return label(label).consumeConcurrent(quota);
	}
	
	/**
	 * Creates a task group that in total consumes the specified
	 * work quota. The latter does not represent a percentage but
	 * is interpreted as an installment relative to the total
	 * workload of the corresponding job. The job's total workload
	 * is the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks will be performed in parallel.
	 * If you are interested in sequential execution use
	 * {@linkplain #consume(int,List) consume(int quota, List tasks)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @param tasks  The list of tasks to be performed.
	 * @return Workload object
	 */
	public CompoundJob consumeConcurrent(int quota, Iterable<Pair<String, Runnable>> tasks) {
		ConcurrentWorkload workload = new ConcurrentWorkload(this, quota);
		tasks.forEach(task -> 
			workload.task(task.getKey(), task.getValue()));
		steps.add(workload);
		return this;
	}
	
	/**
	 * Creates a task group that in total consumes the specified
	 * work quota. The latter does not represent a percentage but
	 * is interpreted as an installment relative to the total
	 * workload of the corresponding job. The job's total workload
	 * is the sum of all quotas.
	 * <p>Example: Let there be two groups of tasks. The
	 * first one consumes a workload of 23 while the second
	 * one consumes a workload of 46. Then the total
	 * workload of the corresponding job is 69 and the
	 * first group of tasks makes up 33% of the total work
	 * while the second one makes up 66%.</p>
	 * <p>The tasks will be performed in parallel.
	 * If you are interested in sequential execution use
	 * {@linkplain #consume(int,List) consume(int quota, List tasks)}.</p>
	 * 
	 * @param quota Value representing the work quota relative
	 *   to an implicit total workload of the corresponding job.
	 * @param label  Display name of the current task group.
	 * @param tasks  The list of tasks to be performed.
	 * @return Workload object
	 */
	public CompoundJob consumeConcurrent(int quota, String label, Iterable<Pair<String, Runnable>> tasks) {
		return label(label).consumeConcurrent(quota, tasks);
	}
	
	public CompoundJob cancelOnFail(boolean flag) {
		cancelOnFail = flag;
		return this;
	}
	
	protected void requestCancel() {
		if (!canceled) {
			canceled = true;
			status = Status.CANCEL_STATUS;
			super.cancel();
		}
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
	 * Sets a message to be shown in a dialog if the execution
	 * of all the tasks of the job has been completed successfully.
	 * 
	 * @param message  The message to be shown.
	 */
	public CompoundJob onFinishedShowMessage(String message) {
		onFinishedMessage = () -> showMessage(message);
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
	 * Sets a message to be shown in a dialog if the execution
	 * has been canceled by the user.
	 * 
	 * @param message  The message to be shown.
	 */
	public CompoundJob onCanceledShowMessage(String message) {
		onCanceledMessage = () -> showMessage(message);
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
	
	/**
	 * Sets a message to be shown in a dialog if the execution
	 * of any task of the job has failed.
	 * 
	 * @param message  The message to be shown.
	 */
	public CompoundJob onFailedShowMessage(String message) {
		onFailedMessage = () -> showErrorMessage(message);
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
				requestCancel();
			if (!canceled)
				perform(step);
		});
		return status;
	}
	
	private void perform(Step step) {
		try {
			step.perform(monitor);
		} catch(Exception e) {
			onStepFailed(step, e);
		}
	}
	
	private void onStepFailed(Step step, Exception e) {
		if (step instanceof ComplexStep)
			onTaskFailed((ComplexStep) step, ((ComplexStep) step).currentTask());
		else {
			if (cancelOnFail) {
				requestCancel();
			}
			String msg = "Execution failed: " + step;
			status = new Status(Status.ERROR, getName(), msg, e);
		}
	}
	
	protected void onTaskFailed(ComplexStep step, Task task) {
		if (cancelOnFail) {
			step.requestCancel();
			requestCancel();
		}
		String msg = buildErrorMessage(task);
		Exception e = buildErrorException(task);
		status = (e != null) 
			? new Status(Status.ERROR, getName(), msg, e)
			: new Status(Status.ERROR, getName(), msg);
	}
	
	protected String buildErrorMessage(Task task) {
		String msg = (cancelOnFail)
			? "The execution has been canceled.\n\n"
			: "The execution of other tasks has not been canceled.\n\n";
		
		if (failedTaskNames.isEmpty())
			msg += "Task failed:\n";
		else msg += "Tasks failed:\n";
		
		for (String failed : failedTaskNames)
			msg += failed;
		
		if (task != null) {
			String taskName = (task.name != null)
				? "\t" + task.name + "\n"
				: "\t<unnamed>\n";
			failedTaskNames.add(taskName);
			msg += taskName;
		}
		return msg;
	}
	
	protected Exception buildErrorException(Task task) {
		Exception e = task.exception;
		if (e == null) return null;
		
		String msg = (e.getMessage() != null)
			? e.getMessage()
			: "Unexpected exception.";
			
		Throwable cause = e.getCause();
		while (cause != null) {
			if (cause.getMessage() != null)
				msg += "\n\t" + cause.getMessage();
			cause = cause.getCause();
		}
		
		StringWriter stacktrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stacktrace));
		msg += "\n\n" + stacktrace.toString();
		
		return new RuntimeException(msg, e);
	}
		
	private void registerListener() {
		addJobChangeListener(new JobChangeAdapter() {
	        public void done(IJobChangeEvent event) {
	        	List<Runnable> handlers = new ArrayList<>();
	        	if (event.getResult().isOK()) {
	        		handlers.addAll(getHandlers(ifDone));
	        		handlers.addAll(getHandlers(onFinished, onFinishedMessage, onDone));
	        	}
	        	else if (event.getResult().equals(Status.CANCEL_STATUS)) {
	        		handlers.addAll(getHandlers(ifCanceled));
	        		handlers.addAll(getHandlers(ifDone));
	        		handlers.addAll(getHandlers(onCanceled, onCanceledMessage, onDone));
	        	} else {
	        		handlers.addAll(getHandlers(ifFailed));
	        		handlers.addAll(getHandlers(ifDone));
	        		handlers.addAll(getHandlers(onFailed, onFailedMessage, onDone));
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
		return Arrays.stream(handlers)
			.filter(handler -> handler != null)
			.collect(Collectors.toList());
	}
	
	private Display getDisplay() {
		return Display.getCurrent() != null
			? Display.getCurrent()
			: Display.getDefault();
	}
	
	private void showMessage(String message) {
		Display display = getDisplay();
		display.syncExec(() ->
			MessageDialog.openInformation(display.getActiveShell(),
				this.getName(), message)
		);
	}
	
	private void showErrorMessage(String message) {
		Display display = getDisplay();
		display.syncExec(() ->
			MessageDialog.openError(display.getActiveShell(),
				this.getName(), message)
		);
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