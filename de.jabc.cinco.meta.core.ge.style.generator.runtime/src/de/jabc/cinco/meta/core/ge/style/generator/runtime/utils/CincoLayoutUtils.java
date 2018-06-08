package de.jabc.cinco.meta.core.ge.style.generator.runtime.utils;

import org.eclipse.graphiti.datatypes.IDimension;
import org.eclipse.graphiti.mm.algorithms.Ellipse;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.Polygon;
import org.eclipse.graphiti.mm.algorithms.Polyline;
import org.eclipse.graphiti.mm.algorithms.styles.Font;
import org.eclipse.graphiti.services.IGaService;

public class CincoLayoutUtils {
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

	private static IGaService gaService = org.eclipse.graphiti.services.Graphiti.getGaService();
	
	/**
	 * Sets the generell layout
	 * @param parent : GraphicsAlgorithm
	 * @param ga : GraphicsAlgorithm
	 */
	public static void layout(final GraphicsAlgorithm parent, final GraphicsAlgorithm ga) {
		org.eclipse.graphiti.services.IPeService peService =  org.eclipse.graphiti.services.Graphiti.getPeService();
		org.eclipse.graphiti.services.IGaService gaService =  org.eclipse.graphiti.services.Graphiti.getGaService();
		String horizontal = peService.getPropertyValue(ga, KEY_HORIZONTAL);
		String vertical = peService.getPropertyValue(ga, KEY_VERTICAL);
		int xMargin = 0;
		int yMargin = 0;
		if (peService.getPropertyValue(ga, KEY_MARGIN_HORIZONTAL) != null)
			xMargin = Integer.parseInt(peService.getPropertyValue(ga, KEY_MARGIN_HORIZONTAL));
		if (peService.getPropertyValue(ga, KEY_MARGIN_VERTICAL) != null)
			yMargin = Integer.parseInt(peService.getPropertyValue(ga, KEY_MARGIN_VERTICAL));
	
		if (parent == null || ga == null)
			return;
		
		int parentWidth = parent.getWidth(), parentHeight = parent.getHeight();
		int gaWidth = ga.getWidth(), gaHeight = ga.getHeight();
		if (ga instanceof org.eclipse.graphiti.mm.algorithms.Text) {
			org.eclipse.graphiti.datatypes.IDimension dim = getTextDimension((org.eclipse.graphiti.mm.algorithms.Text) ga);
			gaService.setWidth(ga, dim.getWidth());
			gaService.setHeight(ga, dim.getHeight());
			gaWidth = dim.getWidth();
			gaHeight = dim.getHeight();
		}

		if (ga instanceof org.eclipse.graphiti.mm.algorithms.MultiText) {
			org.eclipse.graphiti.mm.algorithms.MultiText mt = (org.eclipse.graphiti.mm.algorithms.MultiText) ga;
			String content = mt.getValue().trim();
			String[] lines = content.split("\n");
			int linesCount = lines.length + 1;
			int maxLineWidth = -1;
			int lineHeight = -1;
		
			org.eclipse.graphiti.datatypes.IDimension dim = null;
			for (String s : lines) {
				dim = getTextDimension(s, (mt.getFont() != null) ? mt.getFont() : mt.getStyle().getFont());
				maxLineWidth = Math.max(maxLineWidth, dim.getWidth());
			}
			if (dim != null)
				lineHeight = dim.getHeight();
	
			gaWidth = maxLineWidth + 5;
			gaHeight = lineHeight * linesCount;
			mt.setWidth(gaWidth);
			mt.setHeight(gaHeight);
	
			if (parent.getWidth() < gaWidth + mt.getX())
				parent.setWidth(gaWidth + mt.getX());
			if (parent.getHeight() < gaHeight + mt.getY())
				parent.setHeight(gaHeight + mt.getY());
	
			parentWidth = parent.getWidth();
			parentHeight = parent.getHeight();
		}

		if (KEY_HORIZONTAL_UNDEFINED.equals(horizontal) || KEY_VERTICAL_UNDEFINED.equals(vertical))
			return;

		int x = 0, y = 0;

		switch (horizontal) {
			case KEY_HORIZONTAL_LEFT: x = 0; break;
			case KEY_HORIZONTAL_CENTER: x = parentWidth / 2 - gaWidth / 2; break;
			case KEY_HORIZONTAL_RIGHT: x = parentWidth - gaWidth; break;
			default: break;
		}
	
		switch (vertical) {
			case KEY_VERTICAL_TOP: y = 0; break;
			case KEY_VERTICAL_MIDDLE: y = parentHeight / 2 - gaHeight / 2; break;
			case KEY_VERTICAL_BOTTOM: y = parentHeight - gaHeight; break;
			default: break;
		}

		gaService.setLocation(ga, x+xMargin, y+yMargin);
	}
	
	/**
	 * Returns the dimension of a text
	 * @param t : The text
	 * @return Returns the dimension of the text
	 */	
	public static IDimension getTextDimension(org.eclipse.graphiti.mm.algorithms.AbstractText t) {
		String value = t.getValue();
		Font font = (t.getFont() != null) ? t.getFont() : t.getStyle().getFont();
		IDimension dim = org.eclipse.graphiti.ui.services.GraphitiUi.getUiLayoutService().calculateTextSize(value, font);
		return dim;
    }
	
	/**
	 * Returns the dimension of a text
	 * @param value : The value of the text
	 * @param font : The font of the text
	 * @return Returns the dimension of the text
	 */	
	private static IDimension getTextDimension(String value, Font font) {
		IDimension dim = org.eclipse.graphiti.ui.services.GraphitiUi.getUiLayoutService().calculateTextSize(value, font);
		return dim;
	}
	
	/**
	 * Defines the appearance of the Circle
	 * @param gaContainer : GraphicsAlgorithmContainer
	 */
	public static void createCIRCLE(org.eclipse.graphiti.mm.GraphicsAlgorithmContainer gaContainer, int lineWidth) {
		org.eclipse.graphiti.services.IGaService gaService = org.eclipse.graphiti.services.Graphiti.getGaService();
		Ellipse tmp = gaService.createEllipse(gaContainer);
		int size = 12+lineWidth*2;
		gaService.setSize(tmp, size, size);
		gaService.setLocation(tmp, tmp.getX() - 2, tmp.getY());
		tmp.setFilled(true);
	}

	/**
	 * Defines the appearance of the Triangle
	 * @param gaContainer : GraphicsAlgorithmContainer
	 */
	public static  void createTRIANGLE(org.eclipse.graphiti.mm.GraphicsAlgorithmContainer gaContainer, int lineWidth) {
		org.eclipse.graphiti.services.IGaService gaService = org.eclipse.graphiti.services.Graphiti.getGaService();
		int dX = 10 + lineWidth*2;
		int dY = (int) (5 + lineWidth*1.5);
		
		Polygon tmp = gaService.createPolygon(gaContainer, new int[] { -dX,-dY,  0,0,  -dX,dY });
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
		tmp.setFilled(true);
	}

	/**
	 * Defines the appearance of the Arrow
	 * @param gaContainer : GraphicsAlgorithmContainer
	 */
	public static  void createARROW(org.eclipse.graphiti.mm.GraphicsAlgorithmContainer gaContainer, int lineWidth) {
		org.eclipse.graphiti.services.IGaService gaService = org.eclipse.graphiti.services.Graphiti.getGaService();
		int dX = 7 + lineWidth*2;
		int dY = 1 + lineWidth*2;
		Polyline tmp = gaService.createPolyline(gaContainer, new int[] { -dX,-dY,  0,0,  -dX,dY });
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
	}

	/**
	 * Defines the appearance of the Diamond
	 * @param gaContainer : GraphicsAlgorithmContainer
	 */
	public static  void createDIAMOND(org.eclipse.graphiti.mm.GraphicsAlgorithmContainer gaContainer, int lineWidth) {
		org.eclipse.graphiti.services.IGaService gaService = org.eclipse.graphiti.services.Graphiti.getGaService();
		int dX = 8 + lineWidth;
		int dY = 5 + lineWidth;
		Polygon tmp = gaService.createPolygon(gaContainer, new int[] { -dX,-dY,  0,0,  -dX,dY,  -dX*2,0 });
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
		tmp.setFilled(true);
	}


}
