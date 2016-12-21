package de.jabc.cinco.meta.core.wizards.project;

public enum ExampleFeature {
	CONTAINERS ("&Containers") ,
	ICONS ("&Icons"),
	APPEARANCE_PROVIDER ("&Appearance provider"),
	CUSTOM_ACTION ("C&ustom action"),
	CODE_GENERATOR ("Code &generator"),
	PRIME_REFERENCES ("&Prime references"),
	POST_CREATE_HOOKS ("Post-create hooks"),
	PALETTE_GROUPS ("Palette groups"),
	TRANSFORMATION_API ("Transformation API"),
	PRODUCT_BRANDING ("Product branding"),
	STYLETEST ("Styletest");
	
	private final String label;
	private ExampleFeature(String label) {
		this.label = label;
	}
	
	public String getLabel() {
		return label;
	}
}