package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.gef.EditPart;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.requests.CreateConnectionRequest;
import org.eclipse.graphiti.features.ICreateConnectionFeature;
import org.eclipse.graphiti.features.IFeatureAndContext;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.tb.ContextButtonEntry;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.command.CreateConnectionCommand;
import org.eclipse.graphiti.ui.internal.editor.GFDragConnectionTool;

@SuppressWarnings("restriction")
public class CincoDragConnectionTool extends GFDragConnectionTool {

	private DiagramBehavior diagramBehavior;
	
	public CincoDragConnectionTool(DiagramBehavior diagramBehavior, ContextButtonEntry contextButtonEntry) {
		super(diagramBehavior, contextButtonEntry);
		this.diagramBehavior = diagramBehavior;
	}
	
	private long nextContinue = System.currentTimeMillis();

	@Override
	public void continueConnection(EditPart targetEditPart, EditPart targetTargetEditPart) {
		if (System.currentTimeMillis() < nextContinue) {
			//System.out.println("["+getClass().getSimpleName()+"] nope");
			handleDrag();
			return;
		}
		//System.out.println("["+getClass().getSimpleName()+"] continueConnection");
		setConnectionSource(targetEditPart);
		lockTargetEditPart(targetEditPart);

		CreateConnectionRequest createConnectionRequest = ((CreateConnectionRequest) getTargetRequest());
		createConnectionRequest.setSourceEditPart(targetEditPart);
		createConnectionRequest.setTargetEditPart(targetTargetEditPart);
		Command command = getCommand();
		if (command != null) {
			setCurrentCommand(command);
			if (stateTransition(STATE_INITIAL, STATE_CONNECTION_STARTED)) {
				for (IFeatureAndContext ifac : getCreateConnectionFeaturesAndContext()) {
					ICreateConnectionFeature ccf = (ICreateConnectionFeature) ifac.getFeature();
					//System.out.println("["+getClass().getSimpleName()+"]  > feature: " + ccf);
					long time = System.currentTimeMillis();
					//System.out.println("["+getClass().getSimpleName()+"]  > startConnecting.before");
					ccf.startConnecting();
					//System.out.println("["+getClass().getSimpleName()+"]  > startConnecting.after: " + (System.currentTimeMillis()-time));
					ccf.attachedToSource((ICreateConnectionContext) ifac.getContext());
				}
			}
		}

		setViewer(diagramBehavior.getDiagramContainer().getGraphicalViewer());
		handleDrag();
		unlockTargetEditPart();
		nextContinue = System.currentTimeMillis() + 50;
	}
	
	private Iterable<IFeatureAndContext> getCreateConnectionFeaturesAndContext() {
		//System.out.println("["+getClass().getSimpleName()+"] getCreateConnectionFeaturesAndContext: " + getTargetRequest());
		if (getTargetRequest() instanceof CreateConnectionRequest) {
			List<IFeatureAndContext> ret = new ArrayList<IFeatureAndContext>();
			CreateConnectionRequest r = (CreateConnectionRequest) getTargetRequest();
			//System.out.println("["+getClass().getSimpleName()+"]  > startCommand: " + r.getStartCommand());
			if (r.getStartCommand() instanceof CreateConnectionCommand) {
				CreateConnectionCommand cmd = (CreateConnectionCommand) r.getStartCommand();
				for (IFeatureAndContext ifac : cmd.getFeaturesAndContexts()) {
					if (ifac.getFeature() instanceof ICreateConnectionFeature) {
						ret.add(ifac);
					}
				}
			}
			return ret;
		}
		return Collections.emptyList();
	}
}
