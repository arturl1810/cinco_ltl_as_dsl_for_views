package de.jabc.cinco.meta.core.ge.style.model.errorhandling;


public class CincoEdgeCardinalityInException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4180544291897901169L;
	private String message;
	
	public CincoEdgeCardinalityInException(String message) {
		this.message = message;
	}
	
	@Override
	public String getMessage() {
		return message;
	}
	
}
