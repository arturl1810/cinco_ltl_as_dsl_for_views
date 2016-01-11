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
        if (!failed) afterwork();
        cleanup();
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
    }

    protected void fail() {
    	failed = true;
    	quit();
    }
}
