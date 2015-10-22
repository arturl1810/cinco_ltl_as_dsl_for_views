package de.jabc.cinco.meta.core.ui.highlight;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.styles.Color;
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory;
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.util.ColorConstant;
import org.eclipse.graphiti.util.IColorConstant;

public class Highlight {
	
	public static InstanceRegistry<Highlight> INSTANCE = new InstanceRegistry<>(() -> new Highlight());
	
	private HighlightDecorator deco = new HighlightDecorator(
			new ColorConstant(20, 150, 20), new ColorConstant(240, 255, 240));
	
	private Set<PictogramElement> pes = new HashSet<PictogramElement>();
	private Set<PictogramElement> affected = new HashSet<PictogramElement>();
	private Color diagramHltColor;
	private Color diagramOrgColor;
	private boolean on = false;
	
	public Highlight() {}
	
	public Highlight(Highlight archetype) {
		this();
		deco = new HighlightDecorator(
				archetype.deco.getBackgroundColor(), archetype.deco.getForegroundColor());
		pes = archetype.pes;
	}
	
	public Highlight add(PictogramElement pe) {
		pes.add(pe);
		if (isOn()) on(false);
		return this;
	}
	
	public Highlight addAll(Collection<PictogramElement> pes) {
		this.pes.addAll(pes);
		if (isOn()) on(false);
		return this;
	}
	
	public boolean isOn() {
		return on;
	}
	
	public Highlight setForegroundColor(IColorConstant fgColor) {
		deco.setForegroundColor(fgColor);
		return this;
	}
	
	public Highlight setBackgroundColor(IColorConstant bgColor) {
		deco.setBackgroundColor(bgColor);
		return this;
	}
	
	public Highlight setPictogramElements(PictogramElement... pes) {
		this.pes = new HashSet<PictogramElement>(Arrays.asList(pes));
		return this;
	}
	
	public void on() {
		on(true);
	}
	
	public void on(boolean withdrawPrevious) {
		if (withdrawPrevious && isOn())
			off();
		for (final PictogramElement pe : pes) {
			if (pe instanceof Diagram) {
				diagramOn((Diagram)pe);
			} else {
				put(pe, deco);
			}
			affected.add(pe);
		}
		on = true;
	}
	
	public void off() {
		for (final PictogramElement pe : affected) {
			if (pe instanceof Diagram) {
				diagramOff((Diagram)pe);
			} else
				put(pe, null);
		}	
		affected.clear();
		on = false;
	}
	
	protected void diagramOn(final Diagram diagram) {
		final GraphicsAlgorithm ga = diagram.getGraphicsAlgorithm();
		assertDiagramHltColor(diagram);
		diagramOrgColor = ga.getBackground();
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramHltColor);
		} catch(IllegalStateException expected) {
			// expected and ok as we want a non-permanent diagram color
		}
	}
	
	protected void diagramOff(final Diagram diagram) {
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramOrgColor);
		} catch(IllegalStateException expected) {
			// expected and ok as we want to reset the diagram color
		}
	}
	
	protected void put(final PictogramElement pe, final IDecorator dec) {
		DecoratorRegistry.INSTANCE.get().put(pe, dec);
		HighlightUtils.triggerUpdate(pe);
	}
	
	private void assertDiagramHltColor(final Diagram diagram) {
		if (diagramHltColor == null) {
			IColorConstant clr = deco.getBackgroundColor();
			diagramHltColor = StylesFactory.eINSTANCE.createColor();
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Red(), clr.getRed());
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Green(), clr.getGreen());
			diagramHltColor.eSet(StylesPackage.eINSTANCE.getColor_Blue(), clr.getBlue());
		}
	}
	
		
}
