package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.gear.GEARModel;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.AbstractBasicModelChecker;
import de.metaframe.gear.AssemblyLine;

public class TransitionsystemChecker  extends AbstractBasicModelChecker<GEARModel>{
	
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
		return "Transitionsystem_Generated";
	}

	@Override
	public GEARModel createCheckableModel() {
		return new GEARModel();
	}

}
