package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Represents a service. A service contains information about how to call
 * the corresponding service functionality. Furthermore, it keeps track about
 * subsequent services in the overall workflow.
 *
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public interface Service {
	/**
	 * Adds a successor (i.e. subsequent service) to this service.
	 * 
	 * @param branchName
	 *            The name of the branch connecting this service with the given
	 *            successor.
	 * @param successor
	 *            The successor (i.e. subsequent service).
	 */
	public void addSuccessor(java.lang.String branchName, de.jabc.cinco.meta.plugin.mcam.helper.Service successor);

	/**
	 * Returns the successor (i.e. subsequent service) for the given branch.
	 * 
	 * @param branchName
	 *            The branch for looking up the successor.
	 * @return The successor (i.e. subsequent service) for the given branch or
	 *         {@code null} if no successor could be found.
	 */
	public de.jabc.cinco.meta.plugin.mcam.helper.Service getSuccessorForBranch(java.lang.String branchName);

	/**
	 * Executes the service.
	 * 
	 * @param executionEnvironment
	 *            The execution environment that will be passed to the service
	 *            functionality.
	 * @return The result of the service execution, i.e. the name of the branch
	 *         leading to the successor that should be executed next.
	 * @throws ServiceException if the execution of the service failed.
	 */
	public java.lang.String execute(de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment executionEnvironment) throws de.jabc.cinco.meta.plugin.mcam.helper.ServiceException;
}
