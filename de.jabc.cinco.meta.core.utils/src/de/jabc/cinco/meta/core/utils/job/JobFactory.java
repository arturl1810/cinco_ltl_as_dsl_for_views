package de.jabc.cinco.meta.core.utils.job;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;

import com.google.common.collect.Iterables;

/**
   Job API. Example:
   <pre>
   JobFactory.job("TestJob")
     .label("Running sequential tasks...")
     .consume(25)
       .task("Task A", () -> this.work(2000))
       .task("Task B", this::work)
       .ifCanceled(() -> showMessage("Canceled before concurrent tasks"))
     .label("Running concurrent tasks...")
     .consume(50)
       .taskForEach(items, this::processItem)
       .ifCanceled(() -> showMessage("Canceled during concurrent tasks"))
     .onCanceled(() -> showMessage("Canceled anywhere"))
     .onFinished(() -> showMessage("Finished"))
     .schedule();
   </pre>
 */
public class JobFactory {
	
	public static CompoundJob job(String name) {
		return new CompoundJob(name);
	}
	
	public static CompoundJob job(String name, boolean user) {
		return new CompoundJob(name, user);
	}
	
	public static class CompoundJob extends Job {
		
		SubMonitor monitor;
		IStatus status;
		List<Step> steps = new ArrayList<>();
		
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
		
		public CompoundJob label(final String taskName) {
			steps.add((monitor) -> monitor.setTaskName(taskName));
			return this;
		}
		
		public Workload consume(int work) {
			Workload consumer = new Workload(this, work);
			steps.add(consumer);
			return consumer;
		}
		
		public Workload consumeConcurrent(int work) {
			ConcurrentWorkload consumer = new ConcurrentWorkload(this, work);
			steps.add(consumer);
			return consumer;
		}
		
		private int getWorkload() {
			int load = steps.stream()
				.filter(ComplexStep.class::isInstance)
				.map(ComplexStep.class::cast)
				.mapToInt(step -> step.getWorkload())
				.sum();
			return load;
		}

		@Override
		protected IStatus run(IProgressMonitor pm) {
			monitor = SubMonitor.convert(pm, getWorkload() + 5);
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

		public CompoundJob ifDone(Runnable handler) {
			ifDone.add(handler);
			steps.add((monitor) -> ifDone.remove(0));
			return this;
		}

		public CompoundJob ifCanceled(Runnable handler) {
			ifCanceled.add(handler);
			steps.add((monitor) -> ifCanceled.remove(0));
			return this;
		}

		public CompoundJob ifFailed(Runnable handler) {
			ifFailed.add(handler);
			steps.add((monitor) -> ifFailed.remove(0));
			return this;
		}

		public CompoundJob onDone(Runnable handler) {
			onDone = handler;
			return this;
		}

		public CompoundJob onFinished(Runnable handler) {
			onFinished = handler;
			return this;
		}

		public CompoundJob onCanceled(Runnable handler) {
			onCanceled = handler;
			return this;
		}

		public CompoundJob onFailed(Runnable handler) {
			onFailed = handler;
			return this;
		}
	}
	
	@FunctionalInterface
	public static interface Step {
		
		public void perform(SubMonitor monitor);
	}
	
	public static interface ComplexStep extends Step {
		
		public String description();
		public int getWorkload();
	}
	
	
	
	public static class Workload implements ComplexStep {
		
		protected CompoundJob job;
		protected int workload;
		protected double tick;
		protected List<Task> tasks = new ArrayList<>();
		
		public Workload(CompoundJob job, int workload) {
			this.job = job;
			this.workload = workload;
		}
		
		@Override
		public int getWorkload() {
			return workload;
		}

		public Workload task(Runnable task) {
			return task(null, task);
		}

		public Workload task(String name, Runnable task) {
			tasks.add(new Task(name, task));
			return this;
		}
		
		public <T> Workload taskForEach(Iterable<T> iterables, java.util.function.Consumer<T> op) {
			List<T> items = StreamSupport.stream(iterables.spliterator(), false)
				.collect(Collectors.toList());
			int i=1;
			for (T item : items)
				task("Grouped task " + (i++) + " / " + items.size(), () -> op.accept(item));
			return this;
		}
		
		@Override
		public void perform(SubMonitor monitor) {
			if (tasks.isEmpty()) {
				monitor.newChild(workload).subTask("");
			} else {
				tick = 0;
				tasks.forEach(task -> {
					if (!monitor.isCanceled()) {
						tick += (double) workload / tasks.size();
						monitor.newChild((int) tick).subTask(task.name != null ? task.name : "");
						tick -= (int) tick;
						task.run();
					}
				});	
			}
		}
		
		@Override
		public String description() {
			return tasks.stream()
					.map(t -> t.toString())
					.collect(Collectors.joining("\n"));
		}
		
		public Workload consume(int work) {
			if (tasks.isEmpty()) {
				this.workload += work;
				return this;
			}
			else return job.consume(work);
		}
				
		public Workload consumeConcurrent(int work) {
			if (tasks.isEmpty()) {
				this.workload += work;
				return this;
			}
			else {
				this.workload = 0;
				return job.consumeConcurrent(this.workload + work);
			}
		}
		
		public CompoundJob label(String taskName) {
			return job.label(taskName);
		}
		
		public void schedule() {
			job.schedule();
		}

		public Workload ifDone(Runnable handler) {
			job.ifDone(handler);
			return this;
		}

		public Workload ifCanceled(Runnable handler) {
			job.ifCanceled(handler);
			return this;
		}

		public Workload ifFailed(Runnable handler) {
			job.ifFailed(handler);
			return this;
		}

		public Workload onDone(Runnable handler) {
			job.onDone(handler);
			return this;
		}

		public Workload onFinished(Runnable handler) {
			job.onFinished(handler);
			return this;
		}

		public Workload onCanceled(Runnable handler) {
			job.onCanceled(handler);
			return this;
		}

		public Workload onFailed(Runnable handler) {
			job.onFailed(handler);
			return this;
		}
	}
	
	public static class ConcurrentWorkload extends Workload {

		private List<Thread> threads = new ArrayList<>();
		private int done;
		
		public ConcurrentWorkload(CompoundJob job, int percent) {
			super(job, percent);
		}
		
		@Override
		public void perform(SubMonitor monitor) {
			if (tasks.isEmpty()) {
				monitor.newChild(workload).subTask("");
			} else {
				tasks.forEach(task -> {
					if (!monitor.isCanceled()) {
						spawnThread(task);
					}
				});
				int numThreads = threads.size();
				threads.stream().forEach(thread -> thread.start());
				tick = (double) workload / numThreads;
				monitor.newChild((int) tick).subTask("Concurrent tasks completed: " + done + "/" + numThreads);
				tick -= (int) tick;
				threads.stream().forEach(thread -> { try {
					thread.join();
					done++;
					tick += (double) workload / numThreads;
					monitor.newChild((int) tick).subTask("Concurrent tasks completed: " + done + "/" + numThreads);
					tick -= (int) tick;
				} catch(InterruptedException e) {}});
			}
		}
		
		private void spawnThread(Task task) {
			Thread thread = new Thread(task.task);
			threads.add(thread);
		}
	}
	
	@FunctionalInterface
	public static interface TaskProducer {
		
		public void run(Object item);
	}
	
	public static class Task {
		
		private String name;
		private Runnable task;
		
		public Task(String name, Runnable task) {
			this.name = name;
			this.task = task;
		}
		
		private void run() {
			task.run();
		}
	}
}
