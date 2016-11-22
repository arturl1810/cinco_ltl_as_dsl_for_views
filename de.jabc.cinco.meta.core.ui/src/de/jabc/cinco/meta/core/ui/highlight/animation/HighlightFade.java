package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightFade extends HighlightAnimation {
	
	public HighlightFade(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
		setStep(getSteps());
	}

	@Override
	protected void prepare() {
		Highlight hl = getHighlight();
		if (!hl.isOn()) hl.on();
	}
	
	@Override
	int nextStep(int step, int steps) {
		if (step <= 0) {
			quit();
		}
		return step - 1;
	}
}
