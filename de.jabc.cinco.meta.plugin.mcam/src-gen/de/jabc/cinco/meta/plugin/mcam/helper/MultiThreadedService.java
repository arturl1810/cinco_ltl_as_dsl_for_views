package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Bundles several services and executes each of them in a separate thread.
 * 
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public class MultiThreadedService extends de.jabc.cinco.meta.plugin.mcam.helper.AbstractService {
	/** Thread exit branches of the given services. */
	protected java.lang.String[] threadExits;
	/** The services that will be executed in a separate thread. */
	protected de.jabc.cinco.meta.plugin.mcam.helper.Service[] services;

	/**
	 * Creates a new bundle of threaded services.
	 * 
	 * @param threadExits
	 *            Thread exit branches of the given services.
	 * @param services
	 *            The services that will be executed in a separate thread.
	 */
	public MultiThreadedService(java.lang.String[] threadExits, de.jabc.cinco.meta.plugin.mcam.helper.Service[] services) {
		if ((threadExits == null) || (services == null) || (threadExits.length != services.length)) {
			throw new java.lang.IllegalArgumentException("Error constructing multi threaded services!");
		}
		this.threadExits = threadExits;
		this.services = services;
	}

	/**
	 * Executes the bundled services, each of them in a separate thread.
	 * 
	 * @param executionEnvironment
	 *            The execution environment that will be passed to the service
	 *            functionality.
	 * @return The result of the service execution, i.e. the name of the branch
	 *         leading to the successor that should be executed next.
	 * @throws ServiceException
	 *             if the execution of the service failed.
	 */
	public java.lang.String execute(
			final de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment)
			throws de.jabc.cinco.meta.plugin.mcam.helper.ServiceException {
		java.util.List<java.lang.Thread> taskList = new java.util.ArrayList<java.lang.Thread>();
		for (int i = 0; i < this.services.length; i++) {
			de.jabc.cinco.meta.plugin.mcam.helper.Service service = this.services[i];
			taskList.add(new SingleServiceThread(service, this.threadExits[i], executionEnvironment));
		}

		java.lang.Thread[] tasks = taskList.toArray(new java.lang.Thread[taskList.size()]);
		executionEnvironment.clearThreadExitBranches();

		for (int i = tasks.length - 1; i >= 0; i--) {
			tasks[i].start();
		}

		for (int i = tasks.length - 1; i >= 0; i--) {
			while (true) {
				try {
					tasks[i].join();
					break;
				} catch (java.lang.InterruptedException e) {
					// ignore and keep on waiting for child task to finish
				}
			}
		}

		return "join";
	}

	/**
	 * Execution thread for a single service.
	 */
	protected class SingleServiceThread extends java.lang.Thread {
		/** Service that will be executed. */
		private de.jabc.cinco.meta.plugin.mcam.helper.Service service;
		/** Thread exit branch of the service. */
		private java.lang.String exitThread;
		/** Execution environment passed to the service. */
		private final de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment;

		/**
		 * Creates a new execution thread for the given service.
		 * 
		 * @param service Service that will be executed.
		 * @param exitThread Thread exit branch of the service.
		 * @param executionEnvironment Execution environment passed to the service.
		 */
		public SingleServiceThread(de.jabc.cinco.meta.plugin.mcam.helper.Service service, java.lang.String exitThread,
				de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment) {
			this.service = service;
			this.exitThread = exitThread;
			this.executionEnvironment = executionEnvironment;
		}
		
		/**
		 * @see java.lang.Thread#run()
		 */
		@Override
		public void run() {
			try {
				final java.lang.String exitBranch = this.service
						.execute(new de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment(
								this.executionEnvironment));
				this.executionEnvironment.setThreadExitBranch(this.exitThread, exitBranch);
			} catch (de.jabc.cinco.meta.plugin.mcam.helper.ServiceException exp) {
				exp.printStackTrace();
			}
		}
	}
}