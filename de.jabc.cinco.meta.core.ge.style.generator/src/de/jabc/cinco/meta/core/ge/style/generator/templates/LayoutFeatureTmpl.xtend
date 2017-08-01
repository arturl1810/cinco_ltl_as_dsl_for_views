package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.util.HashMap
import java.util.Map
import mgl.GraphModel
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.graphiti.mm.algorithms.AbstractText
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import style.AbstractShape
import style.Appearance
import style.ContainerShape
import style.LineStyle
import style.Styles
import org.eclipse.graphiti.mm.algorithms.Image
import style.EdgeStyle

class LayoutFeatureTmpl extends GeneratorUtils{
	
public static Map<Object,String> shapeMap = new HashMap<Object,String>;
var counter1 = 0;
var counter2 = 0
EList<Appearance> appList = new BasicEList<Appearance>();
	
	/**
	 * Generates the Class 'LayoutUtils' for the graphmodel gm
	 * @param gm : GraphModel
	 * @param st : Styles
	 */
	def generateLayoutFeature(GraphModel gm, Styles st)
'''package «gm.packageName»;

public class «gm.fuName»LayoutUtils {
	
	private static «IGaService.name» gaService = «Graphiti.name».getGaService();
	
	«var styles = st»
	«FOR app : styles.appearances»	
	
	/**
	 * Defines the Style of the Appearance «app.name»
	 * @param ga : GraphicsAlgorithm
	 * @param diagram : Diagram
	 */	
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
	
	«gm.initInlineAppearances(st)»
	«FOR app : appList»
	«getInlineMethod(app)»
	«ENDFOR»
	
	/**
	 * Defines the default appearance
	 * @param gaContainer : GraphicsAlgorithm
	 * @param diagram : Diagram
	 */
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
		
		public static void updateStyleFromAppearance(«GraphicsAlgorithm.name» ga, «Appearance.name» appearance, «Diagram.name» diagram) {
				if (appearance != null) {
					if (appearance.getImagePath() != null && ga instanceof «Image.name») {
						String imageId = «gm.packageName».«gm.fuName»GraphitiUtils.getInstance().getImageId(appearance.getImagePath());
						((«Image.name») ga).setId(imageId);
					}			
		
					if (appearance.getAngle() != -1 && ga instanceof «AbstractText.name») {
						((«AbstractText.name») ga).setRotation((double) appearance.getAngle());
					}
					
					if (appearance.getBackground() != null) {
						ga.setBackground(gaService.manageColor(diagram, appearance.getBackground().getR(),
							appearance.getBackground().getG(), 
							appearance.getBackground().getB()));
					}
					
					if (appearance.getForeground() != null) {
						ga.setForeground(gaService.manageColor(diagram, appearance.getForeground().getR(),
							appearance.getForeground().getG(), 
							appearance.getForeground().getB()));
					}
					
					if (appearance.getFont() != null && ga instanceof «AbstractText.name») {
						((«AbstractText.name») ga).setFont(gaService.manageFont(diagram, 
							appearance.getFont().getFontName(), 
							appearance.getFont().getSize(),
							appearance.getFont().isIsItalic(), 
							appearance.getFont().isIsBold()));
					}
					
					if (appearance.getTransparency() != -1) {
						ga.setTransparency(appearance.getTransparency());
					}
					
					if (!appearance.getLineStyle().equals(«LineStyle.name».UNSPECIFIED))
						ga.setLineStyle(«org.eclipse.graphiti.mm.algorithms.styles.LineStyle.name».getByName(appearance.getLineStyle().getName()));
					
					if (appearance.getLineWidth() != -1)
						ga.setLineWidth(appearance.getLineWidth());
					
					ga.setLineVisible(!appearance.getLineInVisible());
					
				}
			}
}

'''
	/**
	 * Generates methode(s) for all inlinestyles of the Appearance inline
	 * @param inline : Appearance
	 */
	def getInlineMethod(Appearance inline)
	{
		counter1 = counter1+1
		return '''
	/**
	 * Defines the InlineStyle
	 * @param ga : GraphicsAlgorithm
	 * @param diagram : Diagram
	 */«»
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
	
	/**
	 * Search for all inlineappearance of the Shape, creates a method-call
	 * @param shape : AbstractShape
	 */
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

	/**
	 * Generates a method-call of 'setBackground'
	 * @param app : Appearance
	 */
	def String createBackground(Appearance app){
		if (app.parent != null){
			if(app.parent.background != null)  
				return '''ga.setBackground(gaService.manageColor(diagram, «app.parent.background.r», «app.parent.background.g», «app.parent.background.b»));  '''
			else
				createBackground(app.parent)	
		}
		else return '''ga.setBackground(gaService.manageColor(diagram, 255, 255, 255)); ''' 
	}
	
	/**
	 * Generates a method-call of 'setForeground'
	 * @param app : Appearance
	 */
	def String createForeground(Appearance app){
		if (app.parent != null){
			if(app.parent.foreground != null)  
				return '''ga.setForeground(gaService.manageColor(diagram, «app.parent.foreground.r», «app.parent.foreground.g», «app.parent.foreground.b»));'''
			else
				createForeground(app.parent)	
		}
		else return '''ga.setForeground(gaService.manageColor(diagram, 0, 0, 0)); '''  
	}
	
	/**
	 * Generates a method-call of 'setLineStyle'
	 * @param app : Appearance
	 */
	def String createLineStyle(Appearance app){
		if (app.parent != null){
			if(!app.parent.lineStyle.equals(LineStyle.UNSPECIFIED))
				return '''ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.«app.parent.lineStyle»);''' 
			else
				createLineStyle(app.parent)	
		}
		else return '''ga.setLineStyle(org.eclipse.graphiti.mm.algorithms.styles.LineStyle.SOLID); '''  
	}
	
	/**
	 * Generates a method-call of 'setLineWidth'
	 * @param app : Appearance
	 */
	def String createLineWidth(Appearance app){
		if (app.parent != null){
			if(app.parent.lineWidth != -1)
				return '''ga.setLineWidth(«app.parent.lineWidth»);''' 
			else
				createLineWidth(app.parent)	
		}
		else return '''ga.setLineWidth(1); '''  
	}
	
	/**
	 * Generates a method-call of 'setTransparency'
	 * @param app : Appearance
	 */
	def String createTransparency(Appearance app){
		if (app.parent != null){
			if(app.parent.transparency != -1.0)
				return '''ga.setTransparency(«app.parent.transparency»);''' 
			else
				createTransparency(app.parent)	
		}
		else return '''ga.setTransparency(0.0); '''  
	}
	
	/**
	 * Generates a method-call of 'setLineVisible'
	 * @param app : Appearance
	 */
	def String createLineVisible(Appearance app){
		if (app.parent != null){
			if(app.parent.lineInVisible != false)
				return '''ga.setLineVisible(«app.parent.lineInVisible»);''' 
			else
				createLineVisible(app.parent)	
		}
		else return '''ga.setLineVisible(true); '''  
	}
	
	
	def initInlineAppearances(GraphModel gm, Styles styles) {
		styles.eResource.allContents.forEach[
			if (it instanceof AbstractShape) {
				if (inlineAppearance != null) {
					counter2 = counter2+1
					appList.add(inlineAppearance);
					shapeMap.put(it, "set" + counter2 + "InlineStyle")
				}
			}
			if (it instanceof EdgeStyle) {
				if (inlineAppearance != null) {
					counter2 = counter2+1
					appList.add(inlineAppearance)
					shapeMap.put(it, "set" + counter2 + "InlineStyle")
				}
			}
		]		
	}
	
	
}
