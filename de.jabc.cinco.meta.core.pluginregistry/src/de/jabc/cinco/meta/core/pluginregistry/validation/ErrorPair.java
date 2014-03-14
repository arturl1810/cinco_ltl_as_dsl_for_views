package de.jabc.cinco.meta.core.pluginregistry.validation;

public class ErrorPair<MESSAGE,FEATURE> {
	private FEATURE feature;
	private MESSAGE message;

	public ErrorPair(MESSAGE msg, FEATURE feat){
		this.message = msg;
		this.feature = feat;
	}

	public FEATURE getFeature() {
		return feature;
	}

	public void setFeature(FEATURE feature) {
		this.feature = feature;
	}

	public MESSAGE getMessage() {
		return message;
	}

	public void setMessage(MESSAGE message) {
		this.message = message;
	}
	
	
}
