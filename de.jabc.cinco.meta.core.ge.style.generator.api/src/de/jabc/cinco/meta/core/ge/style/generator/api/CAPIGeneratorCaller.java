package de.jabc.cinco.meta.core.ge.style.generator.api;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;

public class CAPIGeneratorCaller {

	 public void doGenerate(final IProject p, final GraphModel gm, final IPath out) {
		 new de.jabc.cinco.meta.core.capi.generator.CAPIGenerator().doGenerate(p, gm, out);
	 }
}
