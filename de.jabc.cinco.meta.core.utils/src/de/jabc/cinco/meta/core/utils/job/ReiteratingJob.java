package de.jabc.cinco.meta.core.utils.job;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.Job;

/**
 * Created by Steve Bosselmann on 07/03/15.
 */
public abstract class ReiteratingJob extends Job {

    private int interval = 1000;
    private int tick = 100;
    private boolean paused = false;
    private boolean failed = false;
    private Thread myself;
    private long next = System.currentTimeMillis();
	private SubMonitor monitor;
	private IStatus status = Status.OK_STATUS;

    public ReiteratingJob(String name) {
    	super(name);
    }

    public ReiteratingJob(String name, int intervalMs) {
        this(name);
        this.interval = intervalMs;
    }

    public ReiteratingJob(String name, int intervalMs, int tickMs) {
        this(name, intervalMs);
        this.tick = tickMs;
    }

    protected void prepare() {}

    protected abstract void repeat();

    protected void afterwork() {}

    protected void cleanup() {
    	getMonitor().done();
    }

    protected void tick() {
    	if (getMonitor().isCanceled()) quit(Status.CANCEL_STATUS);
    }

    @Override
    public IStatus run(IProgressMonitor monitor) {
    	myself = Thread.currentThread();
    	setMonitor(monitor);
        prepare();
        while (myself == Thread.currentThread()) {
            try {
            	/*
            	 * deadlock-safe pausing of the thread (notice the 'synchronized'
            	 * modifier here as well as at the 'pause' and 'unpause' methods)
            	 */
                if (paused) synchronized(this) {
                    while (paused) wait();
                }
                if (next < System.currentTimeMillis()) {
                    next = interval + System.currentTimeMillis();
                    repeat();
                } else synchronized(this) {
                    wait(tick);
                }
            } catch (InterruptedException e) {
                // nothing to do here
            } finally {
            	tick();
            }
        }
        if (!failed) afterwork();
        cleanup();
        return getStatus();
    }
    
    /**
     * Runs this job and waits for it via {@code job.join()}
     */
    public void runAndWait() {
		schedule();
		try {
			join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

    public synchronized void pause() {
        paused = true;
    }

    public synchronized void unpause() {
        paused = false;
        notify();
    }
    
    public boolean isPaused() {
    	return paused;
    }

    public void quit() {
    	quit(Status.OK_STATUS);
    }
    
    protected void quit(IStatus status) {
    	setStatus(status);
    	myself = null;
    }

    protected void fail(String msg, Exception e) {
    	failed = true;
    	quit(new Status(Status.ERROR, getName(), msg, e));
    }
    
    public SubMonitor getMonitor() {
		return monitor;
	}
    
    protected void setMonitor(IProgressMonitor monitor) {
    	this.monitor = SubMonitor.convert(monitor, 100);
	}
    
    public IStatus getStatus() {
		return status;
	}
    
    protected void setStatus(IStatus status) {
		this.status = status;
	}
}
