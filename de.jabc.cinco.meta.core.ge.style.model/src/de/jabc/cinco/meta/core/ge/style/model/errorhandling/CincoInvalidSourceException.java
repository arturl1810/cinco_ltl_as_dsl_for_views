package de.jabc.cinco.meta.core.ge.style.model.errorhandling;


public class CincoInvalidSourceException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 3204976036783346169L;
	
	private String message;
	
	public CincoInvalidSourceException(String message) {
		this.message = message;  
	}
	
	@Override
	public String getMessage() {
		return message;
	}
	
}
