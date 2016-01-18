package de.jabc.cinco.meta.core.utils.job;

import java.util.function.Consumer;

public class Task {
	
	String name;
	Runnable runnable;
	Exception exception;
	Consumer<Task> onDone;
	
	public Task(Runnable work) {
		this.runnable = () -> {
			try {
				work.run();
			} catch(Exception e) {
				exception = e;
			} finally {
				if (onDone != null)
					onDone.accept(this);
			}
		};
	}

	public Task(String name, Runnable runnable, Consumer<Task> onDone) {
		this(runnable);
		this.name = name;
		this.onDone = onDone;
	}
	
	protected void run() {
		runnable.run();
	}
}