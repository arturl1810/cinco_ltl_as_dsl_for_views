package de.jabc.cinco.meta.plugin.modelchecking.runtime.gear;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.AbstractBasicModelChecker;
import de.metaframe.gear.AssemblyLine;

public class GearModelChecker extends AbstractBasicModelChecker<GEARModel>{

	@Override
	public Set<BasicCheckableNode> getSatisfyingNodes(GEARModel model, String expression) throws Exception {
		AssemblyLine<BasicCheckableNode, BasicCheckableEdge> line
			= new AssemblyLine<BasicCheckableNode, BasicCheckableEdge>();
		line.addDefaultMacros();
		line.setCompilationEnabled(true);
		return line.modelCheck(model, expression);
	}

	@Override
	public String getName() {
		return "GEAR";
	}

	@Override
	public GEARModel createCheckableModel() {
		return new GEARModel();
	}
}
