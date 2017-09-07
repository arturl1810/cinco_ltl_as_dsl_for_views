package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.jface.resource.ImageDescriptor;

public enum EdgeLayoutMode {
	
	C_TOP (
		"C-Layout Top",
		"icons/c_top.png",
		"icons/c_top_disabled.png"),
	
	C_BOTTOM (
		"C-Layout Bottom",
		"icons/c_bottom.gif",
		"icons/c_bottom_disabled.gif"),
	
	C_LEFT (
		"C-Layout Left",
		"icons/c_left.gif",
		"icons/c_left_disabled.gif"),
	
	C_RIGHT (
		"C-Layout Right",
		"icons/c_right.gif",
		"icons/c_right_disabled.gif"),
	
	Z_HORIZONTAL (
		"Z-Layout Horizontal",
		"icons/z_horizontal.gif",
		"icons/z_horizontal_disabled.gif"),
	
	Z_VERTICAL (
		"Z-Layout Vertical",
		"icons/z_vertical.gif",
		"icons/z_vertical_disabled.gif");

	final String id;
	final String text;
	final ImageDescriptor imageDescriptor;
	final ImageDescriptor disabledImageDescriptor;
	
	private EdgeLayoutMode(String text, String image, String disabledImage) {
		this.id = "de.jabc.cinco.meta.ui.action.layout." + this.name();
		this.text = text;
		this.imageDescriptor = createDescriptor(image);
		this.disabledImageDescriptor = createDescriptor(disabledImage);
	}
	
	private static ImageDescriptor createDescriptor(String filename) {
		return ImageDescriptor.createFromFile(EdgeLayoutMode.class, filename);
	}
}
