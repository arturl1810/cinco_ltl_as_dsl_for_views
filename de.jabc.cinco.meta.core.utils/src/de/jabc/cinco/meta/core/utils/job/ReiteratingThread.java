package de.jabc.cinco.meta.core.utils.job;


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

    private Runnable onDoneCallback;
    private Runnable onFailedCallback;
    private Runnable onFinishedCallback;
    
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
    	
	public void onFinished(Runnable callback) {
		onFinishedCallback = callback;
	}
	
	private void onFinished() {
		if (onFinishedCallback != null) {
			onFinishedCallback.run();
		}
	}
	
	public void onFailed(Runnable callback) {
		onFailedCallback = callback;
	}

	private void onFailed() {
		if (onFailedCallback != null) {
			onFailedCallback.run();
		}
	}
	
	public void onDone(Runnable callback) {
		onDoneCallback = callback;
	}

	private void onDone() {
		if (onDoneCallback != null) {
			onDoneCallback.run();
		}
	}
}
