package de.jabc.cinco.meta.plugin.pyro.model;

import style.Color;

public class StyledLabel {
	private int labelFontSize;
	private LabelAlignment labelAlignment;
	private String fontName;
	private FontType fontType;
	private Color labelColor;
	private String value;
	private double location;
	public int getLabelFontSize() {
		return labelFontSize;
	}
	public void setLabelFontSize(int labelFontSize) {
		this.labelFontSize = labelFontSize;
	}
	public LabelAlignment getLableAlignment() {
		return labelAlignment;
	}
	public void setLableAlignment(LabelAlignment lableAlignment) {
		this.labelAlignment = lableAlignment;
	}
	public String getFontName() {
		return fontName;
	}
	public void setFontName(String fontName) {
		this.fontName = fontName;
	}
	public FontType getFontType() {
		return fontType;
	}
	public void setFontType(FontType fontType) {
		this.fontType = fontType;
	}
	public Color getLabelColor() {
		return labelColor;
	}
	public void setLabelColor(Color labelColor) {
		this.labelColor = labelColor;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public double getLocation() {
		return location;
	}
	public void setLocation(double location) {
		this.location = location;
	}
	
	
	
	
}
