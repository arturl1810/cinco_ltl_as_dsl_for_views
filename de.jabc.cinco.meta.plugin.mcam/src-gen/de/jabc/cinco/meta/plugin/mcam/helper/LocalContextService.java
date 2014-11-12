package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Following the "Decorator" pattern, this class decorates a service in order to
 * be executed with a local, separated context. Contexts are managed as a stack,
 * with the context of a superordinate process becoming the parent of the new
 * local context.
 * 
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public class LocalContextService extends de.jabc.cinco.meta.plugin.mcam.helper.AbstractService {
	/* The decorated service. */
	protected de.jabc.cinco.meta.plugin.mcam.helper.Service service;

	/**
	 * Decorates the given service to be executed in a local context.
	 * 
	 * @param service
	 *            The decorated service, must not be <code>null</code>.
	 */
	public LocalContextService(de.jabc.cinco.meta.plugin.mcam.helper.Service service) {
		this.service = service;
	}

	/**
	 * Executes the service in a local context.
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
		executionEnvironment.pushContext(executionEnvironment.getLocalContext().createNewChildContext());
		java.lang.String cg_result = service.execute(executionEnvironment);
		executionEnvironment.popContext();
		return cg_result;
	}
}
