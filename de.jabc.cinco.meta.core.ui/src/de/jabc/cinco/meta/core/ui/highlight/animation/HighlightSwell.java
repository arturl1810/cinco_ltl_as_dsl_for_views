package de.jabc.cinco.meta.core.ui.highlight.animation;

import de.jabc.cinco.meta.core.ui.highlight.Highlight;

public class HighlightSwell extends HighlightAnimation {
	
	public HighlightSwell(Highlight hl, double effectTimeInSeconds) {
		super(hl, effectTimeInSeconds);
	}
	
	@Override
	int nextStep(int step, int steps) {
		if (step >= steps) {
			pause();
		}
		return step + 1;
	}
}
