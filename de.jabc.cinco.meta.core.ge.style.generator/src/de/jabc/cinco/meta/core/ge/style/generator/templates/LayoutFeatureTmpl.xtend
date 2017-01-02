package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.utils.CincoUtils
import java.util.HashMap
import java.util.Map
import mgl.GraphModel
import mgl.Node
import org.eclipse.graphiti.datatypes.IDimension
import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.AbstractText
import org.eclipse.graphiti.mm.algorithms.Ellipse
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.algorithms.MultiText
import org.eclipse.graphiti.mm.algorithms.Polygon
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.algorithms.styles.Font
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.ui.services.GraphitiUi
import style.LineStyle
import org.eclipse.graphiti.mm.pictograms.Shape
import style.Appearance
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import style.AbstractShape
import style.ContainerShape
import style.Styles

class LayoutFeatureTmpl extends GeneratorUtils{
	
public static Map<AbstractShape,String> shapeMap = new HashMap<AbstractShape,String>;
var counter1 = 0;
var counter2 = 0
EList<Appearance> appList = new BasicEList <Appearance>();
	
	/**
	 * Generates the <GraphModel>LayoutUtils class. This class will contain the
	 * setAppearance methods for {@link Appearance}s defined in the {@link GraphModel}'s
	 * {@link style.Style} 
	 * 
	 * @param gm The processed {@link GraphModel} 
	 * @param st The {@link graphmodel.GraphModel}'s style
	 */
	def generateLayoutFeature(GraphModel gm, Styles st)
'''package «gm.packageName»;

public class «gm.fuName»LayoutUtils {
	
	public static final «String.name» KEY_HORIZONTAL = "horizontal";
	public static final «String.name» KEY_VERTICAL = "vertical";
	
	public static final «String.name» KEY_HORIZONTAL_UNDEFINED = "undef";
	public static final «String.name» KEY_HORIZONTAL_LEFT = "h_layout_left";
	public static final «String.name» KEY_HORIZONTAL_CENTER = "h_layout_center";
	public static final «String.name» KEY_HORIZONTAL_RIGHT = "h_layout_right";

	public static final «String.name» KEY_VERTICAL_UNDEFINED = "undef";
	public static final «String.name» KEY_VERTICAL_TOP = "v_layout_top";
	public static final «String.name» KEY_VERTICAL_MIDDLE = "v_layout_middle";
	public static final «String.name» KEY_VERTICAL_BOTTOM = "v_layout_bottom";

	public static final «String.name» KEY_MARGIN_HORIZONTAL = "margin_horizontal";
	public static final «String.name» KEY_MARGIN_VERTICAL = "margin_vertical";

	public static final «String.name» KEY_INITIAL_POINTS = "initial_points";
	public static final «String.name» KEY_INITIAL_PARENT_SIZE = "initial_parent_size";

	public static final «String.name» KEY_GA_NAME = "ga_name";   

	private static «IGaService.name» gaService = «Graphiti.name».getGaService();


	public static void layout(final «GraphicsAlgorithm.name» parent, final «GraphicsAlgorithm.name» ga) {
        «IPeService.name» peService = «Graphiti.name».getPeService();
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		«String.name» horizontal = peService.getPropertyValue(ga, KEY_HORIZONTAL);
		«String.name» vertical = peService.getPropertyValue(ga, KEY_VERTICAL);
		«int.name» xMargin = 0;
		«int.name» yMargin = 0;
		if (peService.getPropertyValue(ga, KEY_MARGIN_HORIZONTAL) != null)
			xMargin = «Integer.name».parseInt(peService.getPropertyValue(ga, KEY_MARGIN_HORIZONTAL));
		if (peService.getPropertyValue(ga, KEY_MARGIN_VERTICAL) != null)
			yMargin = «Integer.name».parseInt(peService.getPropertyValue(ga, KEY_MARGIN_VERTICAL));
	
		if (parent == null || ga == null)
			return;
		
		«int.name» parentWidth = parent.getWidth(), parentHeight = parent.getHeight();
		«int.name» gaWidth = ga.getWidth(), gaHeight = ga.getHeight();
		if (ga instanceof «Text.name») {
			«IDimension.name» dim = getTextDimension((«Text.name») ga);
			gaService.setWidth(ga, dim.getWidth());
			gaService.setHeight(ga, dim.getHeight());
			gaWidth = dim.getWidth();
			gaHeight = dim.getHeight();
		}

		if (ga instanceof «MultiText.name») {
			«MultiText.name» mt = («MultiText.name») ga;
			«String.name» content = mt.getValue().trim();
			«String.name»[] lines = content.split("\n");
			«int.name» linesCount = lines.length + 1;
			«int.name» maxLineWidth = -1;
			«int.name» lineHeight = -1;
		
			«IDimension.name» dim = null;
			for («String.name» s : lines) {
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

		«int.name» x = 0, y = 0;

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

	public static «IDimension.name» getTextDimension(«AbstractText.name» t) {
		«String.name» value = t.getValue();
		«Font.name» font = (t.getFont() != null) ? t.getFont() : t.getStyle().getFont();
		«IDimension.name» dim = «GraphitiUi.name».getUiLayoutService().calculateTextSize(value, font);
		return dim;
	}

	private static «IDimension.name» getTextDimension(String value, «Font.name» font) {
		«IDimension.name» dim = «GraphitiUi.name».getUiLayoutService().calculateTextSize(value, font);
		return dim;
	}
	«var styles = st»
	«FOR app : styles.appearances»	
		
	public static void set«app.name»Style(«GraphicsAlgorithm.name» ga, «Diagram.name» diagram){
		if (ga instanceof «AbstractText.name») {
			((«AbstractText.name») ga).setRotation(0.0);
			((«AbstractText.name») ga).setFont(gaService.manageFont(diagram, "Arial", 8, false, false));
		};		
		«IF app.background != null»
				ga.setBackground(gaService.manageColor(diagram, «app.background.r», «app.background.g», «app.background.b»));
		«ENDIF»
		«IF app.background == null »
				«createBackground(app)»
		«ENDIF»		
		«IF app.foreground != null»
				ga.setForeground(gaService.manageColor(diagram, «app.foreground.r», «app.foreground.g», «app.foreground.b»));
		«ENDIF»
		«IF app.foreground == null»
				«createForeground(app)»
		«ENDIF»
		«IF !app.lineStyle.equals(LineStyle.UNSPECIFIED)»
				ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.«app.lineStyle»);
		«ENDIF»
		«IF app.lineStyle.equals(LineStyle.UNSPECIFIED) »
				«createLineStyle(app)»
		«ENDIF»
		«IF app.lineWidth != -1»
				ga.setLineWidth(«app.lineWidth»);
		«ENDIF»
		«IF app.lineWidth == -1»
				«createLineWidth(app)»
		«ENDIF»
		«IF app.transparency != -1.0»
				 ga.setTransparency(«app.transparency»);
		«ENDIF»
		«IF app.transparency == -1.0»
				«createTransparency(app)»
		«ENDIF»
		«IF app.lineInVisible != false»
			ga.setLineVisible(«app.lineInVisible»);
		«ENDIF»
		«IF app.lineInVisible == false»
			«createLineVisible(app)»
		«ENDIF»
	}
	«ENDFOR»
	
	
	«FOR node : gm.nodes»
	«searchInAppearance(node,st)»
	«FOR app : appList»
	«getInlineMethode(app)»
	«ENDFOR»
	«ENDFOR»
	
	public static void createCIRCLE(«GraphicsAlgorithmContainer.name» gaContainer) {
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		«Ellipse.name» tmp = gaService.createEllipse(gaContainer);
		gaService.setSize(tmp, 12, 12);
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
		tmp.setFilled(true);
	}

	public static  void createTRIANGLE(«GraphicsAlgorithmContainer.name» gaContainer) {
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		«Polygon.name» tmp = gaService.createPolygon(gaContainer, new int[] {-11,-8, 0,0, -11,8, -11,-8});
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
		tmp.setFilled(true);
	}

	public static  void createARROW(«GraphicsAlgorithmContainer.name» gaContainer) {
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		«Polyline.name» tmp = gaService.createPolyline(gaContainer, new int[] {-10,-4, 0,0, -10,4});
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
	}

	public static  void createDIAMOND(«GraphicsAlgorithmContainer.name» gaContainer) {
		«IGaService.name» gaService = «Graphiti.name».getGaService();
		«Polygon.name» tmp = gaService.createPolygon(gaContainer, new int[] {-9,-6, 0,0, -9,6, -18,0, -9,-6});
		gaService.setLocation(tmp, tmp.getX() + 2, tmp.getY());
		tmp.setFilled(true);
	}

	public static void set_«gm.fuName»DefaultAppearanceStyle(«GraphicsAlgorithm.name» ga, «Diagram.name» diagram){
		if( ga instanceof «AbstractText.name»){
			((«AbstractText.name») ga).setRotation(0.0);
			((«AbstractText.name») ga).setFont(gaService.manageFont(diagram, "Arial", 8, false, false));
			
			};			
		ga.setBackground(gaService.manageColor(diagram, 255, 255, 255));
		ga.setForeground(gaService.manageColor(diagram, 0, 0, 0));
		ga.setTransparency(0.0);
		ga.setLineStyle(«org.eclipse.graphiti.mm.algorithms.styles.LineStyle.name».SOLID);
		ga.setLineWidth(1);
		ga.setLineVisible(!false);
		
		}
}

'''
	
	def getInlineMethode(Appearance inline)
	{
		counter1 = counter1+1
		return '''
	public static void set«counter1»InlineStyle(«GraphicsAlgorithm.name» ga, «Diagram.name» diagram){
		if (ga instanceof «AbstractText.name») {
			((«AbstractText.name») ga).setRotation(0.0);
			((«AbstractText.name») ga).setFont(gaService.manageFont(diagram, "Arial", 8, false, false));
		};		
		«IF inline.background != null»
				ga.setBackground(gaService.manageColor(diagram, «inline.background.r», «inline.background.g», «inline.background.b»));
		«ENDIF»
		«IF inline.background == null »
				«createBackground(inline)»
		«ENDIF»		
		«IF inline.foreground != null»
				ga.setForeground(gaService.manageColor(diagram, «inline.foreground.r», «inline.foreground.g», «inline.foreground.b»));
		«ENDIF»
		«IF inline.foreground == null»
				«createForeground(inline)»
		«ENDIF»
		«IF !inline.lineStyle.equals(LineStyle.UNSPECIFIED)»
				ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.«inline.lineStyle»);
		«ENDIF»
		«IF inline.lineStyle.equals(LineStyle.UNSPECIFIED) »
				«createLineStyle(inline)»
		«ENDIF»
		«IF inline.lineWidth != -1»
				ga.setLineWidth(«inline.lineWidth»);
		«ENDIF»
		«IF inline.lineWidth == -1»
				«createLineWidth(inline)»
		«ENDIF»
		«IF inline.transparency != -1.0»
				 ga.setTransparency(«inline.transparency»);
		«ENDIF»
		«IF inline.transparency == -1.0»
				«createTransparency(inline)»
		«ENDIF»
		«IF inline.lineInVisible != false»
			ga.setLineVisible(«inline.lineInVisible»);
		«ENDIF»
		«IF inline.lineInVisible == false»
			«createLineVisible(inline)»
		«ENDIF»
		 }
		 
		'''
	}
	
	def searchInAppearance(Node n, Styles styles){
		var nodeStyle = CincoUtils.getStyleForNode(n,styles)
		val mainShape = nodeStyle.mainShape
		appList.clear
		inlineAppearance(mainShape)	
	}
	
	def void inlineAppearance(AbstractShape shape){
		if(shape.inlineAppearance != null) {
			counter2 = counter2+1
			appList.add(shape.inlineAppearance);
			shapeMap.put(shape, "set" + counter2 + "InlineStyle")
		}	
		if(shape instanceof ContainerShape){
			var children = shape.children
			for(child: children)
				inlineAppearance(child)
		}
	}

	def String createBackground(Appearance app){
		if (app.parent != null){
			if(app.parent.background != null)  
				return '''ga.setBackground(gaService.manageColor(diagram, «app.parent.background.r», «app.parent.background.g», «app.parent.background.b»));  '''
			else
				createBackground(app.parent)	
		}
		else return '''ga.setBackground(gaService.manageColor(diagram, 255, 255, 255)); ''' 
	}
	
	def String createForeground(Appearance app){
		if (app.parent != null){
			if(app.parent.foreground != null)  
				return '''ga.setForeground(gaService.manageColor(diagram, «app.parent.foreground.r», «app.parent.foreground.g», «app.parent.foreground.b»));'''
			else
				createForeground(app.parent)	
		}
		else return '''ga.setForeground(gaService.manageColor(diagram, 0, 0, 0)); '''  
	}
	
	def String createLineStyle(Appearance app){
		if (app.parent != null){
			if(!app.parent.lineStyle.equals(LineStyle.UNSPECIFIED))
				return '''ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.«app.parent.lineStyle»);''' 
			else
				createLineStyle(app.parent)	
		}
		else return '''ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.SOLID); '''  
	}
	
	def String createLineWidth(Appearance app){
		if (app.parent != null){
			if(app.parent.lineWidth != -1)
				return '''ga.setLineWidth(«app.parent.lineWidth»);''' 
			else
				createLineWidth(app.parent)	
		}
		else return '''ga.setLineWidth(1); '''  
	}
	
	def String createTransparency(Appearance app){
		if (app.parent != null){
			if(app.parent.transparency != -1.0)
				return '''ga.setTransparency(«app.parent.transparency»);''' 
			else
				createTransparency(app.parent)	
		}
		else return '''ga.setTransparency(0.0); '''  
	}
	
	def String createLineVisible(Appearance app){
		if (app.parent != null){
			if(app.parent.lineInVisible != false)
				return '''ga.setLineVisible(«app.parent.lineInVisible»);''' 
			else
				createLineVisible(app.parent)	
		}
		else return '''ga.setLineVisible(true); '''  
	}
	
}
