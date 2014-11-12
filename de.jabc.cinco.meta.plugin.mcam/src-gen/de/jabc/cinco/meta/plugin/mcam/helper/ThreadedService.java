package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Following the "Decorator" pattern, this class decorates a service in order to
 * be executed in a separate thread.
 * 
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public class ThreadedService extends de.jabc.cinco.meta.plugin.mcam.helper.AbstractService {
	/* The decorated service. */
	protected de.jabc.cinco.meta.plugin.mcam.helper.Service service;

	/**
	 * Decorates the given service to be executed in a separate thread.
	 * 
	 * @param service
	 *            The decorated service, must not be <code>null</code>.
	 */
	public ThreadedService(de.jabc.cinco.meta.plugin.mcam.helper.Service service) {
		this.service = service;
	}

	/**
	 * Executes the service in a separate thread.
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
		final java.lang.Thread task = new java.lang.Thread() {
			private de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment envThread = new de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment(
					executionEnvironment);

			@Override
			public void run() {
				try {
					service.execute(this.envThread);
				} catch (de.jabc.cinco.meta.plugin.mcam.helper.ServiceException exp) {
					exp.printStackTrace();
				}
			}
		};
		task.start();
		return "default";
	}
}