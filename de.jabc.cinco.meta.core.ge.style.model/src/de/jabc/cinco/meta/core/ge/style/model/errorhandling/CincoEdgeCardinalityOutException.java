package de.jabc.cinco.meta.core.ge.style.model.errorhandling;


public class CincoEdgeCardinalityOutException extends RuntimeException {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 2909207685816434588L;
	
	private String message;
	
	public CincoEdgeCardinalityOutException(String message) {
		this.message = message;
	}
	
	@Override
	public String getMessage() {
		return message;
	}
}
