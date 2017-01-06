package de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling;


public class CincoInvalidTargetException extends RuntimeException {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3199920811810848990L;
	
	private String message;
	
	public CincoInvalidTargetException(String message) {
		this.message = message;  
	}
	
	@Override
	public String getMessage() {
		return message;
	}
}
