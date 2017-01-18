package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ILayoutContext;
import org.eclipse.graphiti.features.impl.AbstractLayoutFeature;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.utils.CincoLayoutUtils;
import graphmodel.ModelElement;

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
	public boolean canLayout(org.eclipse.graphiti.features.context.ILayoutContext context) {
		Object bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (bo instanceof ModelElement)
			return true;
		return false;
	}

	@Override
	public boolean layout(org.eclipse.graphiti.features.context.ILayoutContext context) {
		org.eclipse.graphiti.mm.pictograms.PictogramElement pe = context.getPictogramElement();
		if (pe instanceof org.eclipse.graphiti.mm.pictograms.ContainerShape) {
			layout((org.eclipse.graphiti.mm.pictograms.ContainerShape) pe);
			return true;
		}
		return false;
	}
	
	/** 
	 * Checks if the node was layouted
	 * @param cs : The containershape
	 * @return Returns true, if update process was successful
	 */
	private boolean layout(org.eclipse.graphiti.mm.pictograms.ContainerShape cs) {
		for (org.eclipse.graphiti.mm.pictograms.Shape child : cs.getChildren()) {
			CincoLayoutUtils.layout(cs.getGraphicsAlgorithm(), child.getGraphicsAlgorithm());
			if (child instanceof org.eclipse.graphiti.mm.pictograms.ContainerShape) {
				layout((org.eclipse.graphiti.mm.pictograms.ContainerShape) child);
			}
		}
		return true;
	}

}
