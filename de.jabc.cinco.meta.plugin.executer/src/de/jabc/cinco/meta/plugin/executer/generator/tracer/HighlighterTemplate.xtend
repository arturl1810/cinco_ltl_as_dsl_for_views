package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class HighlighterTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Highlighter.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.utils;
	
	import java.util.LinkedList;
	import java.util.List;
	import java.util.Random;
	import java.util.Set;
	
	import org.eclipse.graphiti.util.ColorConstant;
	import org.eclipse.graphiti.util.IColorConstant;
	
	import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.Highlight;
	import graphmodel.Edge;
	import graphmodel.ModelElement;
	import graphmodel.Node;
	import «graphmodel.tracerPackage».match.model.Match;
	
	/**
	 * The high lighter is used to highlight elements
	 * in a predefined back and foreground color
	 * @author zweihoff
	 *
	 */
	public final class Highlighter {
		private Highlight highlight;
		
		private List<ModelElement> elements;
		
		private java.awt.Color borderColor;
		private java.awt.Color backColor;
		
		public Highlighter()
		{
			this.elements = new LinkedList<ModelElement>();
			
			this.borderColor = randomBorderColor();
			this.backColor = backgoundColor(borderColor);
			
			highlight = new Highlight()
					.setForegroundColor(new ColorConstant(
							borderColor.getRed(),
							borderColor.getGreen(),
							borderColor.getBlue())
							)
					.setBackgroundColor(new ColorConstant(
							backColor.getRed(),
							backColor.getGreen(),
							backColor.getBlue())
							);
		}
		
		public Highlighter(IColorConstant foreground,IColorConstant background)
		{
			highlight = new Highlight()
					.setForegroundColor(foreground)
					.setBackgroundColor(background);
		}
		
		public final void highlight(Set<ModelElement> elements)
		{
			highlight.off();
			highlight.clear();
			this.elements.clear();
			this.elements.addAll(elements);
			elements.stream().filter(n->n instanceof Edge).forEach(n->highlight.add(n));
			elements.stream().filter(n->n instanceof Node).forEach(n->highlight.add(n));
	
			highlight.on(); // turn it on
	
		}
		
		public final synchronized void flashElement(Match element){
			Highlight localH = new Highlight()
					.setForegroundColor(IColorConstant.WHITE)
					.setBackgroundColor(IColorConstant.WHITE);
			element.getElements().forEach(n->localH.add(n));
			localH.flash();
			localH.clear();
		
		}
		
		public final void clear(){
			this.highlight.off();
			this.highlight.clear();
		}
		
		
		private final java.awt.Color randomBorderColor()
		{
			Random random = new Random();
			final float hue = random.nextFloat();
			// Saturation between 0.1 and 0.3
			final float saturation = (random.nextInt(2000) + 1000) / 10000f;
			final float luminance = 0.9f;
			return java.awt.Color.getHSBColor(hue, saturation, luminance);
		}
		
		private final java.awt.Color backgoundColor(java.awt.Color c)
		{
			java.awt.Color color = new java.awt.Color(
					(int) Math.round(Math.min(c.getRed()*1.15,255.0)),
					(int) Math.round(Math.min(c.getGreen()*1.15,255.0)),
					(int) Math.round(Math.min(c.getBlue()*1.15,255.0)),
					c.getAlpha()
					);
			return color;
		}
	
		public final java.awt.Color getBorderColor() {
			return borderColor;
		}
	
		public final void setBorderColor(java.awt.Color borderColor) {
			this.borderColor = borderColor;
		}
	
		public final java.awt.Color getBackColor() {
			return backColor;
		}
	
		public final void setBackColor(java.awt.Color backColor) {
			this.backColor = backColor;
		}
		
		
		
	}
	
	'''
	
}