package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.gear.GEARModel;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.ModelComparator;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.AbstractBasicModelChecker;
import de.metaframe.gear.AssemblyLine;

public class TransitionsystemChecker  extends AbstractLinkedModelChecker{
	
	@Override
	public Set<LinkedBasicCheckableNode> getSatisfyingNodes(TransitionsystemModel model, String expression) throws Exception {
		AssemblyLine<LinkedBasicCheckableNode, LinkedBasicCheckableEdge> line
			= new AssemblyLine<LinkedBasicCheckableNode, LinkedBasicCheckableEdge>();
		line.addDefaultMacros();
		line.setCompilationEnabled(true);
		return line.modelCheck(model, expression);
	}

	@Override
	public String getName() {
		return "Transitionsystem_Generated";
	}

	@Override
	public TransitionsystemModel createCheckableModel() {
		return new TransitionsystemModel();
	}

	@Override
	public ModelComparator<TransitionsystemModel> getComparator() {
		return new TransitionsystemModelComparator();
	}

}
