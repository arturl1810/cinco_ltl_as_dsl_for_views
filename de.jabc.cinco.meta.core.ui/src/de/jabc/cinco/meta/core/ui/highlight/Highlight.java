package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.styles.Color;
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory;
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.util.ColorConstant;
import org.eclipse.graphiti.util.IColorConstant;

import de.jabc.cinco.meta.core.ui.highlight.animation.HighlightAnimation;
import de.jabc.cinco.meta.core.ui.highlight.animation.HighlightBlink;
import de.jabc.cinco.meta.core.ui.highlight.animation.HighlightFade;
import de.jabc.cinco.meta.core.ui.highlight.animation.HighlightFlash;
import de.jabc.cinco.meta.core.ui.highlight.animation.HighlightSwell;
import de.jabc.cinco.meta.core.utils.WorkbenchUtil;
import de.jabc.cinco.meta.core.utils.registry.InstanceRegistry;
import graphmodel.ModelElement;

public class Highlight {

	public static InstanceRegistry<Highlight> INSTANCE = new InstanceRegistry<>(() -> new Highlight());

	private Set<PictogramElement> pes = new HashSet<>();
	private Set<PictogramElement> affected = new HashSet<>();
	private Map<PictogramElement, ConnectionDecoratorLayouter> layouters = new HashMap<>();
	private Map<PictogramElement, HighlightDecorator> decos = new HashMap<>();

	private HighlightDecorator deco;
	private Color diagramHltColor;
	private Color diagramOrgColor;
	private HighlightAnimation animation;

	private boolean on = false;

	public Highlight() {
		ColorConstant c = ColorProvider.INSTANCE.get().next();
		deco = new HighlightDecorator(ColorProvider.amend(c, 0.7), ColorProvider.amend(c, 1.3));
	}

	public Highlight(IColorConstant fgColor, IColorConstant bgColor) {
		deco = new HighlightDecorator(fgColor, bgColor);
	}

	public Highlight(Highlight archetype) {
		this(archetype.deco.getForegroundColor(), archetype.deco.getBackgroundColor());
		pes = archetype.pes;
	}

	public Highlight add(PictogramElement pe) {
		if (pes.add(pe) && isOn()) {
			on(pe, true);
		}
		return this;
	}

	public Highlight add(ModelElement me) {
		add(eapi(me).getPictogramElement());
		return this;
	}

	public Highlight remove(PictogramElement pe) {
		if (pes.remove(pe) && isOn()) {
			off(pe, true);
		}
		return this;
	}

	public Highlight remove(ModelElement me) {
		remove(eapi(me).getPictogramElement());
		return this;
	}

	public Highlight clear() {
		if (isOn()) {
			off();
		}
		pes.clear();
		return this;
	}

	public boolean isActive(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		return !reg.isEmpty() && (getDeco(pe) == reg.lastElement());
	}

	public boolean isOn() {
		return on;
	}

	public IColorConstant getForegroundColor() {
		return deco.getForegroundColor();
	}

	public IColorConstant getForegroundColor(PictogramElement pe) {
		return getDeco(pe).getForegroundColor();
	}

	public IColorConstant getBackgroundColor() {
		return deco.getBackgroundColor();
	}

	public IColorConstant getBackgroundColor(PictogramElement pe) {
		return getDeco(pe).getBackgroundColor();
	}

	public Highlight setForegroundColor(IColorConstant fgColor) {
		deco.setForegroundColor(fgColor);
		refreshAll();
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setForegroundColor(int red, int green, int blue) {
		deco.setForegroundColor(new ColorConstant(red, green, blue));
		refreshAll();
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setForegroundColor(String hexRGBString) {
		deco.setForegroundColor(new ColorConstant(hexRGBString));
		refreshAll();
		return this;
	}

	public Highlight setForegroundColor(PictogramElement pe, IColorConstant fgColor) {
		getPeSpecificDeco(pe).setForegroundColor(fgColor);
		refresh(pe);
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setForegroundColor(PictogramElement pe, int red, int green, int blue) {
		getPeSpecificDeco(pe).setForegroundColor(new ColorConstant(red, green, blue));
		refresh(pe);
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setForegroundColor(PictogramElement pe, String hexRGBString) {
		getPeSpecificDeco(pe).setForegroundColor(new ColorConstant(hexRGBString));
		refresh(pe);
		return this;
	}

	public Highlight setBackgroundColor(IColorConstant bgColor) {
		deco.setBackgroundColor(bgColor);
		refreshAll();
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setBackgroundColor(int red, int green, int blue) {
		deco.setBackgroundColor(new ColorConstant(red, green, blue));
		refreshAll();
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setBackgroundColor(String hexRGBString) {
		deco.setBackgroundColor(new ColorConstant(hexRGBString));
		refreshAll();
		return this;
	}

	public Highlight setBackgroundColor(PictogramElement pe, IColorConstant bgColor) {
		getPeSpecificDeco(pe).setBackgroundColor(bgColor);
		refresh(pe);
		return this;
	}

	/**
	 * red, green and blue values expressed as integers in the range 0 to 255
	 * (where 0 is black and 255 is full brightness).
	 */
	public Highlight setBackgroundColor(PictogramElement pe, int red, int green, int blue) {
		getPeSpecificDeco(pe).setBackgroundColor(new ColorConstant(red, green, blue));
		refresh(pe);
		return this;
	}

	/**
	 * RGB values in hexadecimal format. This means, that the String must have a
	 * length of 6 characters. Example: <code>"FF0000"</code> represents a red
	 * color.
	 * 
	 */
	public Highlight setBackgroundColor(PictogramElement pe, String hexRGBString) {
		getPeSpecificDeco(pe).setBackgroundColor(new ColorConstant(hexRGBString));
		refresh(pe);
		return this;
	}

	public ArrayList<PictogramElement> getPictogramElements() {
		return new ArrayList<>(pes);
	}

	public Highlight setPictogramElements(PictogramElement... pes) {
		this.pes = new HashSet<PictogramElement>(Arrays.asList(pes));
		refresh();
		return this;
	}

	public Highlight on() {
		on(true);
		return this;
	}

	public Highlight on(boolean triggerDiagramRefresh) {
		for (final PictogramElement pe : pes) {
			on(pe, false);
		}
		on = true;
		return this;
	}

	protected Highlight on(PictogramElement pe, boolean triggerRefresh) {
		if (pe instanceof Diagram) {
			diagramOn((Diagram) pe);
		} else {
			DecoratorRegistry.INSTANCE.get().get(pe).push(getDeco(pe));
		}
		affected.add(pe);
		registerConnectionDecoratorLayouter(pe);
		refresh(pe);
		return this;
	}

	public Highlight flash() {
		flash(1.0);
		return this;
	}

	public Highlight flash(double effectTimeInSeconds) {
		startAnimation(new HighlightFlash(this, effectTimeInSeconds));
		return this;
	}

	public Highlight blink() {
		blink(1.0);
		return this;
	}

	public Highlight blink(double effectTimeInSeconds) {
		startAnimation(new HighlightBlink(this, effectTimeInSeconds));
		return this;
	}

	public Highlight swell() {
		swell(0.5);
		return this;
	}

	public Highlight swell(double effectTimeInSeconds) {
		startAnimation(new HighlightSwell(this, effectTimeInSeconds));
		return this;
	}

	public Highlight fade() {
		fade(0.5);
		return this;
	}

	public Highlight fade(double effectTimeInSeconds) {
		startAnimation(new HighlightFade(this, effectTimeInSeconds));
		return this;
	}

	public Highlight setAnimation(HighlightAnimation animation) {
		if (this.animation != null) {
			this.animation.quit();
		}
		this.animation = animation;
		return this;
	}
	
	protected Highlight startAnimation(HighlightAnimation animation) {
		if (this.animation != null) {
			this.animation.onDone(() -> {
				this.animation = animation;
				animation.start();
			});
			this.animation.quit();
			this.animation = null;
		} else {
			this.animation = animation;
			animation.start();
		}
		return this;
	}

	public Highlight off() {
		off(true);
		return this;
	}

	public Highlight off(boolean triggerDiagramRefresh) {
		if (animation != null) {
			animation.quit();
		}
		removeDecos();
		return this;
	}

	protected Highlight off(PictogramElement pe, boolean triggerDiagramRefresh) {
		if (pe instanceof Diagram) {
			diagramOff((Diagram) pe);
		} else {
			DecoratorRegistry.INSTANCE.get().get(pe).remove(getDeco(pe));
		}
		affected.remove(pe);
		unregisterConnectionDecoratorLayouter(pe);
		refresh(pe);
		return this;
	}

	protected void removeDecos() {
		for (PictogramElement pe : new HashSet<>(affected)) {
			off(pe, false);
		}
		on = false;
	}

	public Highlight refresh() {
		if (isOn()) {
			removeDecos();
			on();
		}
		return this;
	}

	protected Highlight diagramOn(Diagram diagram) {
		final GraphicsAlgorithm ga = diagram.getGraphicsAlgorithm();
		assertDiagramHltColor(diagram);
		diagramOrgColor = ga.getBackground();
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramHltColor);
		} catch (IllegalStateException expected) {
			// expected and ok as we want a non-permanent diagram color
		}
		return this;
	}

	protected Highlight diagramOff(Diagram diagram) {
		try {
			diagram.getGraphicsAlgorithm().setBackground(diagramOrgColor);
		} catch (IllegalStateException expected) {
			// expected and ok as we want to reset the diagram color
		}
		return this;
	}

	private void registerConnectionDecoratorLayouter(PictogramElement pe) {
		if (pe instanceof Connection)
			layouters.put(pe, ConnectionDecoratorLayouter.applyTo(pe));
	}

	private void unregisterConnectionDecoratorLayouter(PictogramElement pe) {
		ConnectionDecoratorLayouter layouter = layouters.remove(pe);
		if (layouter != null)
			layouter.setUnregisterAfterNextLayout(true);
	}

	private HighlightDecorator getDeco(PictogramElement pe) {
		HighlightDecorator deco = decos.get(pe);
		return deco != null ? deco : this.deco;
	}

	private HighlightDecorator getPeSpecificDeco(PictogramElement pe) {
		HighlightDecorator deco = decos.get(pe);
		if (deco == null) {
			deco = new HighlightDecorator(this.deco);
			decos.put(pe, deco);
		}
		return deco;
	}

	private void refreshAll() {
		if (isOn()) {
			for (PictogramElement pe : affected) {
				WorkbenchUtil.refreshDecorators(pe);
			}
		}
	}
	
	private void refresh(PictogramElement pe) {
		if (isOn()) {
			WorkbenchUtil.refreshDecorators(pe);
		}
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
