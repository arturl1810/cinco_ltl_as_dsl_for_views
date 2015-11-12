package de.jabc.cinco.meta.plugin.gratext;


public class GenerationException extends RuntimeException {

	// generated
	private static final long serialVersionUID = -768441551878227818L;

	public GenerationException() {
		super();
	}
	
	public GenerationException(String msg) {
		super(msg);
	}
	
	public GenerationException(String msg, Exception e) {
		this(msg);
		setStackTrace(e.getStackTrace());
	}
}
