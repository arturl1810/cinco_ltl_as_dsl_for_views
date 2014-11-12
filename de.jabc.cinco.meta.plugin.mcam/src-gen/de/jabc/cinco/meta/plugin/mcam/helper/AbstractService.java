package de.jabc.cinco.meta.plugin.mcam.helper;

/**
 * Abstract superclass for all services.
 *
 * @author Java Class Generator (2014-11-12 15:36:16.989)
 */
public abstract class AbstractService implements de.jabc.cinco.meta.plugin.mcam.helper.Service {
	/** The subsequent services (branch name -> subsequent service). */
	private java.util.Map<java.lang.String, de.jabc.cinco.meta.plugin.mcam.helper.Service> successors;

	/** Constructor. */
	public AbstractService() {
		this.successors = new java.util.HashMap<java.lang.String, de.jabc.cinco.meta.plugin.mcam.helper.Service>();
	}

	/**
	 * Adds a successor (i.e. subsequent service) to this service.
	 * 
	 * @param branchName
	 *            The name of the branch connecting this service with the given
	 *            successor.
	 * @param successor
	 *            The successor (i.e. subsequent service).
	 */
	public void addSuccessor(java.lang.String branchName, de.jabc.cinco.meta.plugin.mcam.helper.Service successor) {
		this.successors.put(branchName, successor);
	}

	/**
	 * Returns the successor (i.e. subsequent service) for the given branch.
	 * 
	 * @param branchName
	 *            The branch for looking up the successor.
	 * @return The successor (i.e. subsequent service) for the given branch or
	 *         {@code null} if no successor could be found.
	 */
	public de.jabc.cinco.meta.plugin.mcam.helper.Service getSuccessorForBranch(java.lang.String branchName) {
		return this.successors.get(branchName);
	}
}
