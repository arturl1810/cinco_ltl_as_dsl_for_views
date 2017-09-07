package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IWorkbenchPart;

public enum EdgeLayoutMode {
	
	C_TOP (
		"C-Layout Top",
		"icon/c_top.png",
		"icon/c_top_disabled.png"),
	
	C_BOTTOM (
		"C-Layout Bottom",
		"icon/c_top.png", // "icon/c_bottom.gif",
		"icon/c_top_disabled.png"), // "icon/c_bottom_disabled.gif"),
	
	C_LEFT (
		"C-Layout Left",
		"icon/c_top.png", // "icon/c_left.gif",
		"icon/c_top_disabled.png"), // "icon/c_left_disabled.gif"),
	
	C_RIGHT (
		"C-Layout Right",
		"icon/c_top.png", // "icon/c_right.gif",
		"icon/c_top_disabled.png"), // "icon/c_right_disabled.gif"),
	
	Z_HORIZONTAL (
		"Z-Layout Horizontal",
		"icon/c_top.png", // "icon/z_horizontal.gif",
		"icon/c_top_disabled.png"), // "icon/z_horizontal_disabled.gif"),
	
	Z_VERTICAL (
		"Z-Layout Vertical",
		"icon/c_top.png", // "icon/z_vertical.gif",
		"icon/c_top_disabled.png"); // "icon/z_vertical_disabled.gif");

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
	
	public EdgeLayoutAction createEdgeLayoutAction(IWorkbenchPart part) {
		return new EdgeLayoutAction(part, this);
	}
	
	public EdgeLayoutRetargetAction createEdgeLayoutRetargetAction() {
		return new EdgeLayoutRetargetAction(this);
	}
	
	private static ImageDescriptor createDescriptor(String filename) {
		return ImageDescriptor.createFromFile(EdgeLayoutMode.class, filename);
	}
}
