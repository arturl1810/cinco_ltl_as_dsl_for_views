package de.jabc.cinco.meta.core.utils.job;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;
import java.util.stream.Stream;

import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;

/**
 * Represents a workload object, that basically is a sequence
 * of tasks that together consume a specific proportion of the
 * total work that makes up a job.
 */
public class Workload implements ComplexStep {
	
	protected CompoundJob job;
	protected int quota;
	protected double tick;
	protected boolean canceled;
	protected List<Supplier<Stream<Task>>> tasksSuppliers = new ArrayList<>();
	protected List<Task> tasks;
	protected Task currentTask;
	protected String displayName;
	
	public Workload(CompoundJob job, int quota) {
		this.job = job;
		this.quota = quota;
	}
	
	@Override
	public int getQuota() {
		return quota;
	}
	
	/**
	 * Initiates the creation of a task sequence that in
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
		if (tasksSuppliers.isEmpty()) {
			this.quota += quota;
			return this;
		}
		else return job.consume(quota);
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
	 * Initiates the creation of a task sequence that in
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
		if (tasksSuppliers.isEmpty()) {
			this.quota += quota;
			return this;
		}
		else {
			this.quota = 0;
			return job.consumeConcurrent(this.quota + quota);
		}
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
	 * Creates a task to be added to the group of tasks
	 * that share the current work quota.
	 * 
	 * @param runnable  The runnable that represents the
	 *   executable work of the task.
	 * @return Workload object
	 */
	public Workload task(Runnable runnable) {
		return task(null, runnable);
	}

	/**
	 * Creates a task to be added to the group of tasks
	 * that share the current work quota.
	 * 
	 * @param name  The display name of the task.
	 * @param runnable  The runnable that represents the
	 *   executable work of the task.
	 * @return Workload object
	 */
	public Workload task(String name, Runnable runnable) {
		addTask(createTask(name, runnable));
		return this;
	}
	
	/**
	 * Creates a task to be added to the group of tasks
	 * that share the current work quota.
	 * 
	 * @param job  The job that manages the executable work
	 *   of the task. At runtime the job is scheduled and
	 *   joined internally, i.e. the task waits for the job
	 *   to complete. The job's name is taken as task name.
	 *   The job will be executed as background job to prevent
	 *   an additional progress window.
	 * @return Workload object
	 */
	public Workload task(Job job) {
		return task(job.getName(), job);
	}

	/**
	 * Creates a task to be added to the group of tasks
	 * that share the current work quota.
	 * 
	 * @param name  The display name of the task.
	 * @param job  The job that manages the executable work
	 *   of the task. At runtime the job is scheduled and
	 *   joined internally, i.e. the task waits for the job
	 *   to complete. The job will be executed as background
	 *   job to prevent an additional progress window.
	 * @return Workload object
	 */
	public Workload task(String name, Job job) {
		addTask(createTask(name, () -> {
			job.setUser(false);
			job.schedule();
			try {
				job.join();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}));
		return this;
	}
	
	protected Task createTask(String name, Runnable runnable) {
		return new Task(name, runnable, this::taskDone);
	}
	
	protected void addTask(Task task) {
		tasksSuppliers.add(() -> Stream.of(task));
	}
	
	/**
	 * Builds tasks from a Stream supplier and adds them to the group
	 * of tasks that share the current work quota.
	 * <p>Useful if the Stream of items has not been initialized, yet.
	 * Special case: In the following example the Stream is initialized
	 * in a preceding task:</p>
	   <pre>
       Stream&lt;IFile&gt; files = Stream.empty();   // create the Stream
       JobFactory.job("TestJob")
         .label("Inititalizing...")
         .consume(5)
           .task(() -> init(files))     // initialize the Stream
         .label("Working...")
         .consumeConcurrent(95)
           .taskForEach(() -> files,    // supply the Stream
               file -> process(file))
         .schedule();
	   </pre>
	 * 
	 * @param supplier  The supplier of the item stream.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the stream.
	 */
	public <T> Workload taskForEach(Supplier<Stream<T>> supplier, Consumer<T> consumer) {
		tasksSuppliers.add(() -> supplier.get().map(item -> 
			createTask(null, () -> consumer.accept(item))));
		return this;
	}
	
	/**
	 * Builds tasks from a Stream supplier and adds them to the group
	 * of tasks that share the current work quota.
	 * <p>Useful if the Stream of items has not been initialized, yet.
	 * Special case: In the following example the Stream is initialized
	 * in a preceding task:</p>
	   <pre>
       Stream&lt;IFile&gt; files = Stream.empty();   // create the Stream
       JobFactory.job("TestJob")
         .label("Inititalizing...")
         .consume(5)
           .task(() -> init(files))     // initialize the Stream
         .label("Working...")
         .consumeConcurrent(95)
           .taskForEach(() -> files,    // supply the Stream
               file -> process(file),
               file -> "Processing file: " + file.getName())
         .schedule();
	   </pre>
	 * 
	 * @param supplier  The supplier of the item stream.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the stream.
	 * @param nameProvider  A function that is called for each item of the
	 *   stream in order to get a display name for the task to be created.
	 */
	public <T> Workload taskForEach(Supplier<Stream<T>> supplier, Consumer<T> consumer, Function<T, String> nameProvider) {
		tasksSuppliers.add(
			() -> supplier.get().map(
				item -> createTask(nameProvider.apply(item), () -> consumer.accept(item))));
		return this;
	}
	
	/**
	 * Creates a task for every item in the Stream and adds it to
	 * the group of tasks that share the current work quota.
	 * 
	 * @param stream  The item stream.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the stream.
	 * 
	 */
	public <T> Workload taskForEach(Stream<T> stream, Consumer<T> consumer) {
		stream.forEach(item -> task(() -> consumer.accept(item)));
		return this;
	}
	
	/**
	 * Creates a task for every item in the Stream and adds it to
	 * the group of tasks that share the current work quota.
	 * 
	 * @param stream  The item stream.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the stream.
	 * @param nameProvider  A function that is called for each item of the
	 *   stream in order to get a display name for the task to be created.
	 */
	public <T> Workload taskForEach(Stream<T> stream, Consumer<T> consumer, Function<T, String> nameProvider) {
		stream.forEach(item -> 
			task(nameProvider.apply(item), () -> consumer.accept(item)));
		return this;
	}
	
	/**
	 * Creates a task for every iterable item and adds it to
	 * the group of tasks that share the current work quota.
	 * 
	 * @param iterables  The list of items.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the list.
	 */
	public <T> Workload taskForEach(Iterable<T> iterables, Consumer<T> consumer) {
		for (T item : iterables)
			task(() -> consumer.accept(item));
		return this;
	}
	
	/**
	 * Creates a task for every iterable item and adds it to
	 * the group of tasks that share the current work quota.
	 * 
	 * @param iterables  The list of items.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the list.
	 * @param nameProvider  A function that is called for each item of the
	 *   list in order to get a display name for the task to be created.
	 */
	public <T> Workload taskForEach(Iterable<T> iterables, Consumer<T> consumer, Function<T, String> nameProvider) {
		for (T item : iterables)
			task(nameProvider.apply(item), () -> consumer.accept(item));
		return this;
	}
	
	/**
	 * Creates a task for every iterable item and adds it to
	 * the group of tasks that share the current work quota.
	 * 
	 * @param iterables  The list of items.
	 * @param consumer  The consumer that represents the executable work
	 *   for each item of the list.
	 */
	public Workload taskForEach(Iterable<Job> jobs) {
		jobs.forEach(this::task);
		return this;
	}
	
	public Workload cancelIf(Supplier<Boolean> test) {
		task("", () -> { if (test.get()) cancel(); });
		return this;
	}
	
	public Workload cancelIf(Supplier<Boolean> test, String message) {
		task("", () -> {
			if (test.get()) {
				cancel();
				showMessage(message);
			}
		});
		return this;
	}

	@Override
	public void perform(SubMonitor monitor) {
		tasks = buildTasks();
		if (tasks.isEmpty()) {
			monitor.newChild(quota).subTask("");
		} else {
			tick = 0;
			tasks.forEach(task -> {
				if (!monitor.isCanceled() && !canceled) {
					currentTask = task;
					displayName = toDisplayName(task, tasks);
					tick += (double) quota / tasks.size();
					monitor.newChild((int) tick).subTask(displayName);
					tick -= (int) tick;
					task.run();
				}
			});	
		}
	}
	
	protected List<Task> buildTasks() {
		List<Task> tasks = new ArrayList<>();
		tasksSuppliers.forEach(sup -> sup.get().forEach(tasks::add));
		return tasks;
	}
	
	private String toDisplayName(Task task, List<Task> tasks) {
		return (task.name != null)
			? task.name
			: "Task " + tasks.indexOf(task) + " / " + tasks.size();
	}
	
	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param label  Display name of the current task group.
	 * @return The job object.
	 * 
	 * @see #CompoundJob.label(String) CompoundJob.label(String label)
	 */
	public CompoundJob label(String label) {
		return job.label(label);
	}
	
	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @see org.eclipse.core.runtime.jobs.Job#schedule() Job.schedule()
	 */
	public void schedule() {
		job.schedule();
	}
	
	/**
	 * Cancel the current execution.
	 */
	protected void cancel() {
		if (!canceled) {
			canceled = true;
			job.requestCancel();
		}
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of the current group of tasks has
	 *   stopped for whatever reason, i.e. finished, canceled
	 *   or failed.
	 * 
	 * @see #CompoundJob.ifDone(Runnable) CompoundJob.ifDone(Runnable handler)
	 */
	public Workload ifDone(Runnable handler) {
		job.ifDone(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of the current group of tasks has
	 *   been canceled.
	 * 
	 * @see #CompoundJob.ifCanceled(Runnable) CompoundJob.ifCanceled(Runnable handler)
	 */
	public Workload ifCanceled(Runnable handler) {
		job.ifCanceled(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of the current group of tasks has
	 *   failed.
	 * 
	 * @see #CompoundJob.ifFailed(Runnable) CompoundJob.ifFailed(Runnable handler)
	 */
	public Workload ifFailed(Runnable handler) {
		job.ifFailed(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of all tasks of the job has
	 *   stopped for whatever reason, i.e. finished, canceled
	 *   or failed.
	 * 
	 * @see #CompoundJob.onDone(Runnable) CompoundJob.onDone(Runnable handler)
	 */
	public Workload onDone(Runnable handler) {
		job.onDone(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of all the tasks of the job has
	 *   been completed successfully.
	 * 
	 * @see #CompoundJob.onFinished(Runnable) CompoundJob.onFinished(Runnable handler)
	 */
	public Workload onFinished(Runnable handler) {
		job.onFinished(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of the tasks of the job has been
	 *   canceled eventually.
	 * 
	 * @see #CompoundJob.onCanceled(Runnable) CompoundJob.onCanceled(Runnable handler)
	 */
	public Workload onCanceled(Runnable handler) {
		job.onCanceled(handler);
		return this;
	}

	/**
	 * Reference to the API of the job that corresponds
	 * to this Workload object.
	 * 
	 * @param handler  Runnable to be executed if
	 *   the execution of any task of the job has failed.
	 * 
	 * @see #CompoundJob.onFailed(Runnable) CompoundJob.onFailed(Runnable handler)
	 */
	public Workload onFailed(Runnable handler) {
		job.onFailed(handler);
		return this;
	}
	
	
	@Override
	public Task currentTask() {
		return currentTask;
	}
	
	protected void taskDone(Task task) {
		if (task.exception != null)
			job.onTaskFailed(this, task);
	}
	
	public void requestCancel() {
		canceled = true;
	}
	
	private void showMessage(String msg) {
		Display d = Display.getCurrent();
		if (d == null)
			d = Display.getDefault();
		final Display display = d;
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
				job.getName(), display.getSystemImage(SWT.ICON_INFORMATION),
	            msg, MessageDialog.INFORMATION, new String[] {"OK"}, 0
	        ).open()
		);
	}
}