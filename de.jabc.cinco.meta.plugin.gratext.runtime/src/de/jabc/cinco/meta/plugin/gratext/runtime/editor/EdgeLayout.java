package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IWorkbenchPart;

import graphmodel.Edge;

public class EdgeLayout {
	
	public static EdgeLayout C_LEFT = new EdgeLayout(
			"C_LEFT",
			"C-Layout Left",
			"c_left.gif",
			new Layouter_C_LEFT());
	
	public static EdgeLayout C_TOP = new EdgeLayout(
			"C_TOP",
			"C-Layout Top",
			"c_top.gif",
			new Layouter_C_TOP());
	
	public static EdgeLayout C_RIGHT = new EdgeLayout(
			"C_RIGHT",
			"C-Layout Right",
			"c_right.gif",
			new Layouter_C_RIGHT());
	
	public static EdgeLayout C_BOTTOM = new EdgeLayout(
			"C_BOTTOM",
			"C-Layout Bottom",
			"c_bottom.gif",
			new Layouter_C_BOTTOM());
	
	public static EdgeLayout Z_HORIZONTAL = new EdgeLayout(
			"Z_HORIZONTAL",
			"Z-Layout Horizontal",
			"z_horizontal.gif",
			new Layouter_Z_HORIZONTAL());
	
	public static EdgeLayout Z_VERTICAL = new EdgeLayout(
			"Z_VERTICAL",
			"Z-Layout Vertical",
			"z_vertical.gif",
			new Layouter_Z_VERTICAL());
	
	public static EdgeLayout TO_LEFT = new EdgeLayout(
			"TO_LEFT",
			"Move left",
			"to_left.gif",
			new Layouter_TO_LEFT());
	
	public static EdgeLayout TO_TOP = new EdgeLayout(
			"TO_TOP",
			"Move up",
			"to_top.gif",
			new Layouter_TO_TOP());
	
	public static EdgeLayout TO_RIGHT = new EdgeLayout(
			"TO_RIGHT",
			"Move right",
			"to_right.gif",
			new Layouter_TO_RIGHT());
	
	public static EdgeLayout TO_BOTTOM = new EdgeLayout(
			"TO_BOTTOM",
			"Move down",
			"to_bottom.gif",
			new Layouter_TO_BOTTOM());

	public static EdgeLayout[] values() {
		return new EdgeLayout[] {
			C_LEFT, C_TOP, C_RIGHT, C_BOTTOM,
			Z_HORIZONTAL, Z_VERTICAL,
			TO_LEFT, TO_TOP, TO_RIGHT, TO_BOTTOM
		};
	}
	
	final String id;
	final String text;
	final ImageDescriptor imageDescriptor;
	final ImageDescriptor disabledImageDescriptor;
	final EdgeLayouter layouter;
	
	private EdgeLayout(String id, String text, String image, EdgeLayouter layouter) {
		this.id = "de.jabc.cinco.meta.ui.action.layout." + id;
		this.text = text;
		this.imageDescriptor = createDescriptor("icon/" + image);
		int dot = image.lastIndexOf(".");
		this.disabledImageDescriptor = createDescriptor(
				"icon/" + image.substring(0, dot) + "_disabled" + image.substring(dot));
		this.layouter = layouter;
	}
	
	private static ImageDescriptor createDescriptor(String filename) {
		return ImageDescriptor.createFromFile(EdgeLayout.class, filename);
	}
	
	public void apply(Edge edge) {
		layouter.apply(edge);
	}
	
	public EdgeLayoutAction createAction(IWorkbenchPart part) {
		return new EdgeLayoutAction(part, this);
	}
	
	public EdgeLayoutRetargetAction createRetargetAction() {
		return new EdgeLayoutRetargetAction(this);
	}
}
