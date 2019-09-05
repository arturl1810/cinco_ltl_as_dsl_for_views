package de.jabc.cinco.meta.plugin.modelchecking.runtime.core;


public enum Result {
	TRUE,
	FALSE,
	ERROR,
	NOT_CHECKED;
	
	
	public boolean isValid() {
		return this == TRUE || this == FALSE;
	}
}
