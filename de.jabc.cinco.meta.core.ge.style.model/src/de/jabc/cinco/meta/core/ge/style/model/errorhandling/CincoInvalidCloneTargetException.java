package de.jabc.cinco.meta.core.ge.style.model.errorhandling;


public class CincoInvalidCloneTargetException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -7544811387119383443L;
	
	private String message;
	
	public CincoInvalidCloneTargetException(String message) {
		this.message = message;  
	}
	
	@Override
	public String getMessage() {
		return message;
	}
}
