package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightFlash extends HighlightAnimation {
	
	private boolean swelling = true;

	public HighlightFlash(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
		setSteps((int) (getSteps() * 0.5));
	}
	
	@Override
	int nextStep(int step, int steps) {
		if (swelling) {
			if (step >= steps) {
				swelling = false;
				return steps;
			}
			return step + 1;
		} else {
			if (step <= 0) {
				quit();
			}
			return step - 1;
		}
	}
}
