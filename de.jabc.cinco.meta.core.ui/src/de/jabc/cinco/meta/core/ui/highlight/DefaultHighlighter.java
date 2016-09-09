package de.jabc.cinco.meta.core.ui.highlight;

import graphmodel.ModelElementContainer;
import graphmodel.Node;

import java.util.Collection;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.graphiti.features.ICreateConnectionFeature;
import org.eclipse.graphiti.features.ICreateFeature;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.context.IReconnectionContext;
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;

import de.jabc.cinco.meta.core.ui.highlight.HighlightUtils.TreatFail;

public class DefaultHighlighter extends Highlighter {


	@Override
	protected Set<PictogramElement> getHighlightablesOnDrag(PictogramElement dragged) {
		return HighlightUtils.getShapes().stream()
				.filter(pe -> pe != dragged
					&& HighlightUtils.testBusinessObjectType(pe, ModelElementContainer.class)
					&& canContain(pe, dragged))
				.collect(Collectors.toSet());
	}

	@Override
	protected Set<PictogramElement> getHighlightablesOnCreate(ICreateFeature feature) {
		return HighlightUtils.getContainerShapes().stream()
				.filter(pe -> HighlightUtils.testBusinessObjectType(pe, ModelElementContainer.class))
				.filter(pe -> canCreate(feature, pe))
				.collect(Collectors.toSet());
	}

	@Override
	protected Set<PictogramElement> getHighlightablesOnConnect(ICreateConnectionFeature feature, ICreateConnectionContext context) {
		CreateConnectionContext ctx = new CreateConnectionContext();
		ctx.setSourceAnchor(context.getSourceAnchor());
		return HighlightUtils.getShapes().stream()
				.filter(shape -> HighlightUtils.testBusinessObjectType(shape, Node.class))
				.filter(shape -> {
					if (!shape.getAnchors().isEmpty()) {
						ctx.setTargetAnchor(shape.getAnchors().get(0));
						return feature.canCreate(ctx);
					}
					return false;
				})
				.collect(Collectors.toSet());
	}
	
	@Override
	protected Collection<PictogramElement> getHighlightablesOnReconnect(IReconnectionFeature feature, IReconnectionContext context) {
		ReconnectionContext ctx = new ReconnectionContext(
				context.getConnection(),
				context.getOldAnchor(),
				context.getNewAnchor(),
				context.getTargetLocation());
		ctx.setReconnectType(context.getReconnectType());
		return HighlightUtils.getShapes().stream()
				.filter(shape -> HighlightUtils.testBusinessObjectType(shape, Node.class))
				.filter(shape -> {
					if (!shape.getAnchors().isEmpty()) {
						ctx.setNewAnchor(shape.getAnchors().get(0));
						return feature.canReconnect(ctx);
					}
					return false;
				})
				.collect(Collectors.toSet());
	}
	
	private boolean canCreate(ICreateFeature creater, ContainerShape shape) {
		CreateContext context = new CreateContext();
		context.setTargetContainer(shape);
		return creater.canCreate(context);
	}
	
	private boolean canContain(Shape containerShape, PictogramElement pe) {
		try {
			Node node = HighlightUtils.treatBusinessObject(pe).as(Node.class).get();
			return HighlightUtils.treatBusinessObject(containerShape)
				.as(ModelElementContainer.class)
				.test(c -> c.equals(node.getContainer()) || c.canContain(node.getClass()));
		} catch(TreatFail e) {
			return false;
		}
	}

	@Override
	protected Highlight getHighlight(PictogramElement pe) {
		return Highlight.INSTANCE.create().setPictogramElements(pe);
	}
	
}
