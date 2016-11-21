package de.jabc.cinco.meta.core.ui.highlight.animation;

import java.util.Stack;

import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IColorDecorator;
import org.eclipse.graphiti.tb.IDecorator;
import org.eclipse.graphiti.util.IColorConstant;

import de.jabc.cinco.meta.core.ui.highlight.ColorProvider;
import de.jabc.cinco.meta.core.ui.highlight.DecoratorRegistry;
import de.jabc.cinco.meta.core.ui.highlight.Highlight;
import de.jabc.cinco.meta.core.utils.job.ReiteratingThread;

public abstract class HighlightAnimation extends ReiteratingThread {

	final static int EffectIntervalInMs = 30;
	
	Highlight hl;
	double step = 0;
	double steps = 30;
	
	public HighlightAnimation(Highlight hl, double effectTimeInSeconds) {
		super(EffectIntervalInMs);
		steps = (int) (effectTimeInSeconds * 1000 / HighlightAnimation.EffectIntervalInMs);
		System.out.println("[ANIM] steps: " + steps);
		this.hl = hl;
	}
	
	@Override
	protected void prepare() {
		mixColors(step/steps);
		hl.on();
	}
	
	@Override
	protected void work() {
		mixColors(step/steps);
	}
	
	@Override
	public void afterwork() {
		hl.off();
	}
	
	void mixColors(double ratio) {
		for (PictogramElement pe : hl.getPictogramElements()) {
			mixColors(pe, hl, ratio);
		}
	}

	void mixColors(PictogramElement pe, Highlight hl, double ratio) {
		hl.setBackgroundColor(pe,
			ColorProvider.mix(
				getBackgroundColor(pe),
				hl.getBackgroundColor(),
				ratio));
		hl.setForegroundColor(pe,
			ColorProvider.mix(
				getForegroundColor(pe),
				hl.getForegroundColor(),
				ratio));
	}
	
	IColorConstant getBackgroundColor(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		System.out.println("Reg.size = " + reg.size());
		IDecorator deco = null;
		if (hl.isOn()) {
			if (reg.size() > 1) {
				deco = reg.get(reg.size() - 2);
			}
		} else if (!reg.isEmpty()) {
			deco = reg.lastElement();
		}
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getBackgroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getBackground());
	}
	
	IColorConstant getForegroundColor(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		IDecorator deco = null;
		if (hl.isOn()) {
			if (reg.size() > 1) {
				deco = reg.get(reg.size() - 2);
			}
		} else if (!reg.isEmpty()) {
			deco = reg.lastElement();
		}
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getForegroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getForeground());
	}
}
