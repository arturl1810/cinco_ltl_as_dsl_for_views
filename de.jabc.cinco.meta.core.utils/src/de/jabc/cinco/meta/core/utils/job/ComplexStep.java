package de.jabc.cinco.meta.core.utils.job;



public interface ComplexStep extends Step {
	
	public int getQuota();
	
	public Task currentTask();

	public void requestCancel();
}