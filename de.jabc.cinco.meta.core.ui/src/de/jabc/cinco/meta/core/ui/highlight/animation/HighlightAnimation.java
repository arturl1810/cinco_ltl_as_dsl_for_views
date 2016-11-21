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
	public void cleanup() {
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
		IDecorator deco = getDecorator(pe);
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getBackgroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getBackground());
	}
	
	IColorConstant getForegroundColor(PictogramElement pe) {
		IDecorator deco = getDecorator(pe);
		if (deco != null && deco instanceof IColorDecorator) {
			return ((IColorDecorator) deco).getForegroundColor();
		}
		return ColorProvider.toColorConstant(
				pe.getGraphicsAlgorithm().getForeground());
	}
	
	IDecorator getDecorator(PictogramElement pe) {
		Stack<IDecorator> reg = DecoratorRegistry.INSTANCE.get().get(pe);
		if (hl.isOn()) {
			if (reg.size() > 1) {
				return reg.get(reg.size() - 2);
			}
		} else if (!reg.isEmpty()) {
			return reg.lastElement();
		}
		return null;
	}
}
