package de.jabc.cinco.meta.plugin.papyrus.model;

import style.Color;

public class StyledLabel {
	private int labelFontSize;
	private LableAlignment lableAlignment;
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
	public LableAlignment getLableAlignment() {
		return lableAlignment;
	}
	public void setLableAlignment(LableAlignment lableAlignment) {
		this.lableAlignment = lableAlignment;
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
