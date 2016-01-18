package de.jabc.cinco.meta.core.utils.job;

import org.eclipse.core.runtime.SubMonitor;

@FunctionalInterface
public interface Step {
	
	public void perform(SubMonitor monitor);
	
}