package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workbench.*;

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

public class DefaultHighlighter extends Highlighter {


	@Override
	protected Set<PictogramElement> getHighlightablesOnDrag(PictogramElement dragged) {
		return getShapes().stream()
				.filter(pe -> pe != dragged
					&& testBusinessObjectType(pe, ModelElementContainer.class)
					&& canContain(pe, dragged))
				.collect(Collectors.toSet());
	}

	@Override
	protected Set<PictogramElement> getHighlightablesOnCreate(ICreateFeature feature) {
		return getContainerShapes().stream()
				.filter(pe -> testBusinessObjectType(pe, ModelElementContainer.class))
				.filter(pe -> canCreate(feature, pe))
				.collect(Collectors.toSet());
	}

	@Override
	protected Set<PictogramElement> getHighlightablesOnConnect(ICreateConnectionFeature feature, ICreateConnectionContext context) {
		CreateConnectionContext ctx = new CreateConnectionContext();
		ctx.setSourceAnchor(context.getSourceAnchor());
		return getShapes().stream()
				.filter(shape -> testBusinessObjectType(shape, Node.class))
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
		return getShapes().stream()
				.filter(shape -> testBusinessObjectType(shape, Node.class))
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
			Node node = (Node) getBusinessObject(pe);
			ModelElementContainer cont = (ModelElementContainer) getBusinessObject(containerShape);
			return cont.equals(node.getContainer()) || cont.canContain(node.getClass());
		} catch(RuntimeException e) {
			return false;
		}
	}

	@Override
	protected Highlight getHighlight(PictogramElement pe) {
		return Highlight.INSTANCE.create()
				.setForegroundColor(20, 150, 20)
				.setBackgroundColor(240, 255, 240)
				.setPictogramElements(pe);
	}
	
}
