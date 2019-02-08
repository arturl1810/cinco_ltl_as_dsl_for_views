package de.jabc.cinco.meta.core.utils.job;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Steve Bosselmann on 07/03/15.
 */
public abstract class ReiteratingThread extends Thread {

    private int interval = 1000;
    private int tick = 100;
    private boolean paused = false;
    private boolean failed = false;
    private Thread myself;
    private long next = System.currentTimeMillis();

    private List<Runnable> onDoneCallbacks = new ArrayList<>();
    private List<Runnable> onFailedCallbacks = new ArrayList<>();
    private List<Runnable> onFinishedCallbacks = new ArrayList<>();
    
    public ReiteratingThread() {}

    public ReiteratingThread(int intervalMs) {
        this();
        this.interval = intervalMs;
        this.tick = intervalMs / 10;
    }

    public ReiteratingThread(int intervalMs, int tickMs) {
        this();
        this.interval = intervalMs;
        this.tick = tickMs;
    }

    protected void prepare() {}

    protected abstract void work();

    protected void afterwork() {}

    protected void cleanup() {}

    protected void tick() {}

    @Override
    public void run() {
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
                    work();
                } else synchronized(this) {
                    wait(tick);
                }
            } catch (InterruptedException e) {
                // nothing to do here
            } finally {
                tick();
            }
        }
        if (failed) {
        	onFailed();
        } else {
        	afterwork();
        	onFinished();
        }
        cleanup();
        onDone();
    }

    @Override
    public synchronized void start() {
        myself = new Thread(this);
        myself.start();
    }

    public synchronized void pause() {
        paused = true;
    }

    public synchronized void unpause() {
        paused = false;
        notify();
    }

    public void quit() {
        myself = null;
        if (paused) unpause();
    }

    protected void fail() {
    	failed = true;
    	quit();
    }
    
    public void waitUntilDone() {
    	if (!isStarted()) {
    		throw new IllegalStateException("Thread is not running!");
    	}
    	try {
    		myself.join();
		} catch(InterruptedException e) {
			e.printStackTrace();
		}
    }
    
    public boolean isStarted() {
    	return myself != null;
    }
    
    public boolean isPaused() {
    	return paused;
    }
    	
	public void onFinished(Runnable callback) {
		onFinishedCallbacks.add(callback);
	}
	
	private void onFinished() {
		for (Runnable callback : onFinishedCallbacks) {
			callback.run();
		}
	}
	
	public void onFailed(Runnable callback) {
		onFailedCallbacks.add(callback);
	}

	private void onFailed() {
		for (Runnable callback : onFailedCallbacks) {
			callback.run();
		}
	}
	
	public void onDone(Runnable callback) {
		onDoneCallbacks.add(callback);
	}

	private void onDone() {
		for (Runnable callback : onDoneCallbacks) {
			callback.run();
		}
	}
}
