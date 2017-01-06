package de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling;


public class CincoContainerCardinalityException extends RuntimeException {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1281628473627873637L;
	
	private String message;
	
	public CincoContainerCardinalityException(String message) {
		this.message = message; 
	}
	
	@Override
	public String getMessage() {
		return message;
	}
}
