package de.jabc.cinco.meta.core.ge.style.model.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ILayoutContext;
import org.eclipse.graphiti.features.impl.AbstractLayoutFeature;

public class CincoLayoutFeature extends AbstractLayoutFeature {

	public static final String KEY_HORIZONTAL = "horizontal";
	public static final String KEY_VERTICAL = "vertical";
	
	public static final String KEY_HORIZONTAL_UNDEFINED = "undef";
	public static final String KEY_HORIZONTAL_LEFT = "h_layout_left";
	public static final String KEY_HORIZONTAL_CENTER = "h_layout_center";
	public static final String KEY_HORIZONTAL_RIGHT = "h_layout_right";
	
	public static final String KEY_VERTICAL_UNDEFINED = "undef";
	public static final String KEY_VERTICAL_TOP = "v_layout_top";
	public static final String KEY_VERTICAL_MIDDLE = "v_layout_middle";
	public static final String KEY_VERTICAL_BOTTOM = "v_layout_bottom";

	public static final String KEY_MARGIN_HORIZONTAL = "margin_horizontal";
	public static final String KEY_MARGIN_VERTICAL = "margin_vertical";
	
	public static final String KEY_INITIAL_POINTS = "initial_points";
	public static final String KEY_INITIAL_PARENT_SIZE = "initial_parent_size";

	public static final String KEY_GA_NAME = "ga_name";
	
	public CincoLayoutFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canLayout(ILayoutContext context) {
		return true;
	}

	@Override
	public boolean layout(ILayoutContext context) {
		return true;
	}

}
