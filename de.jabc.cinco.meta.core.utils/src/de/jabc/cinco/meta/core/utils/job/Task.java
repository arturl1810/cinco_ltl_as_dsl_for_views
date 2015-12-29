package de.jabc.cinco.meta.core.utils.job;

public class Task {
	
	String name;
	Runnable runnable;
	
	public Task(Runnable work) {
		this.runnable = () -> {
			try {
				work.run();
			} finally {
				onDone();
			}
		};
	}

	public Task(String name, Runnable runnable) {
		this(runnable);
		this.name = name;
	}
	
	protected void run() {
		runnable.run();
	}
	
	protected void onDone() { }
}