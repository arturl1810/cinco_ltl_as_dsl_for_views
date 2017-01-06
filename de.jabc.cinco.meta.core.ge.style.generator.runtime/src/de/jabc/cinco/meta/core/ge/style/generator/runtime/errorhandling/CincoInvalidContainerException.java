package de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling;


public class CincoInvalidContainerException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5539081754569314091L;
	private String message;
	
	public CincoInvalidContainerException(String message) {
		this.message = message;  
	}
	
	@Override
	public String getMessage() {
		return message;
	}
}
