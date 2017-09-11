package de.jabc.cinco.meta.core.ge.style.model.xapi

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CGraphModel
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoInvalidTargetException
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoMoveShapeFeature
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.Container
import graphmodel.Edge
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Node
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.context.impl.MoveShapeContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Shape

/**
 * GraphicalGraphModel-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
 // TODO This class should be obsolete as soon as the Awesome-New-API(TM) is released
class GraphicalGraphModelExtension {
	
	protected extension WorkbenchExtension = new WorkbenchExtension
	protected extension GraphModelExtension = new GraphModelExtension
	protected extension ResourceExtension = new ResourceExtension	
	
	/**
	 * Find all elements of specific type inside the specified container.
	 * <br>Recurses into all sub-containers.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * <p>Convenient method for {@code findDeeply(container, cls, [])}</p>
	 * 
	 * @param container  The container holding the elements to be searched through.
	 * @param cls  The class of the elements to be found.
	 * @return  A set of elements of the specified type. Might be empty but is never null.
	 */
	def <C extends ModelElement> find(ModelElementContainer container, Class<C> cls) {
		findDeeply(container, cls, [])
	}
	
	/**
	 * Find all elements of specific type inside the specified container.
	 * <br>Recurses into all sub-containers.
	 * <br>Recurses into sub-models, as specified via the {@code progression} parameter.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * <br>The progression may be defined using a simple switch statement:
	 * <pre>
	 *   findDeeply(container, cls, [switch it {
	 *     GUISIB: gui
	 *     ProcessSIB: proMod
	 *   }])
	 * </pre>
	 * 
	 * <br>Containers that are handled by the progression function will additionally be
	 * searched through the conventional way, i.e. by looking at its children.
	 * 
	 * @param container  The container holding the elements to be searched through.
	 * @param cls  The class of the elements to be found.
	 * @param progression  A function that defines how to dig deeper.
	 * @return  A set of elements of the specified type. Might be empty but never null.
	 */
	def <C extends ModelElement> Set<C> findDeeply(ModelElementContainer container, Class<C> cls, (ModelElement) => ModelElementContainer progression) {
		val filter = [EObject obj | if (obj.isInstanceOf(cls)) obj as C]
		val result = container.withChildren.map(filter).filterNull.toSet
		val next = [ newArrayList(
			progression.apply(it), 
			switch it { ModelElementContainer: it })
		]
		result.withAll(
			container.modelElements
				.map(next).flatten.filterNull
				.map[findDeeply(cls, progression)].flatten.filterNull.toSet)
	}
	
	/**
	 * Finds the element of specific type inside the specified container.
	 * <br>Recurses into all sub-containers.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * <p>Convenient method for {@code find(container, cls).head}</p>
	 * 
	 * @param container  The container holding the elements to be searched through.
	 * @param cls  The class of the elements to be found.
	 * @return  The element of the specified type, or {@code null} if none is found. If more
	 *   than one element of the specified type is found, a warning is printed to the console
	 *   and the first instance is returned.
	 */
	def <C extends ModelElement> C findThe(ModelElementContainer container, Class<C> cls) {
		val result = find(container, cls)
		if (result.size > 1) System.err.println('''
			WARN: «result.size» elements of type '«cls»' found.
			      Exactly one was expected when calling method 'findThe' on container «container»..
		''')
		return result.head
	}
	
	/**
	 * Finds the element of specific type inside the specified container that fulfills the
	 * specified predicate.
	 * <br>Recurses into all sub-containers.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * <p>Convenient method for {@code find(container, cls).filter(predicate).head}</p>
	 * 
	 * @param container  The container holding the elements to be searched through.
	 * @param cls  The class of the elements to be found.
	 * @param predicate  The predicate to be fulfilled.
	 * @return  The element of the specified type, or {@code null} if none is found. If more
	 *   than one element of the specified type is found, a warning is printed to the console
	 *   and the first instance is returned.
	 */
	def <C extends ModelElement> C findThe(ModelElementContainer container, Class<C> cls, (C) => boolean predicate) {
		val result = find(container, cls).filter(predicate)
		if (result.size > 1) System.err.println('''
			«result.size» elements of type '«cls»' found that fulfill the specified predicate..
			  Exactly one was expected when calling method 'findThe' on container «container».
		''')
		return result.head
	}
	
	/**
	 * Find all parents of a model element of a specific type.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * @param element  The element for which to find the parent elements.
	 * @param cls  The class of the parent elements to be found. 
	 */
	def <C extends ModelElement> Iterable<C> findParents(ModelElement it, Class<C> cls) {
		if (container.isInstanceOf(cls))
			#[container as C] + (container as C).findParents(cls)
		else #[]
	}
	
	/**
	 * Find the first parent (bottom-up) of a model element of a specific type.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * @param element  The element for which to find the parent elements.
	 * @param cls  The class of the parent elements to be found. 
	 */
	def <C extends ModelElement> C findFirstParent(ModelElement elm, Class<C> cls) {
		switch c:elm.container {
			case c.isInstanceOf(cls): c as C
			ModelElement: (c as ModelElement).findFirstParent(cls)
		}
	}
	
	/**
	 * Determines whether a model element has a parent of a specific type.
	 * <br>The type of each element is matched to the specified type via a C-API-aware
	 * type-check that compares the name of the element's EClass as well as the name of
	 * all ESuperTypes with the name of the specified EClass.
	 * <br>See {@link #isInstanceOf(EObject,Class)}.
	 * 
	 * <p>Convenient method for {@code element.findFirstParent(cls) != null}</p>
	 * 
	 * @param element  The element for which to find the parent element.
	 * @param cls  The class of the parent element to be found. 
	 */
	def <C extends ModelElement> hasParent(ModelElement it, Class<C> cls) {
		findFirstParent(cls) != null
	}
	
	/**
	 * Finds the source elements of all incoming edges of specific type.
	 * <p>
	 * Convenient method for
	 * {@code getIncoming(cls).map[sourceElement].filterNull}
	 * 
	 * @param node - The node for which to examine incoming edges.
	 * @param cls - The class of the edges to be examined.
	 * @return The source elements of the incoming edges of the specified type.
	 */
	def <C extends Edge> findSourcesOf(Node node, Class<C> cls) {
		node.getIncoming(cls).map[sourceElement].filterNull
	}
	
	/**
	 * Finds the source element of an incoming edge of specific type
	 * that fulfills the specified predicate.
	 * <p>
	 * If more than one matching edge exists the source element of the
	 * first of these edges is returned.
	 * <p>
	 * A warning is printed to the console if
	 * <ul>
	 * <li>more than one matching edge exists or
	 * <li>the source element of the edge is {@code null}.
	 * </ul>
	 * <p>
	 * Convenient method for
	 * {@code getIncoming(cls).filter(predicate).head?.sourceElement}
	 * 
	 * @param node - The node for which to examine incoming edges.
	 * @param cls - The class of the edges to be examined.
	 * @param predicate - The predicate to be fulfilled.
	 * @return The source element of the incoming edge of the specified type,
	 *   or {@code null} if none such edge exists or the source element is
	 *   {@code null}. 
	 */
	def <C extends Edge> Node findSourceOf(Node node, Class<C> cls) {
		val result = node.getIncoming(cls)
		if (result.size > 1) System.err.println('''
			«result.size» incoming edges of type '«cls»' found.
			  Exactly one was expected when calling method 'findSourceOf' on node «node».
		''')
		return result.head?.sourceElement
	}
	
	/**
	 * Finds the target elements of all outgoing edges of specific type.
	 * <p>
	 * Convenient method for
	 * {@code getOutgoing(cls).map[targetElement].filterNull}
	 * 
	 * @param node - The node for which to examine outgoing edges.
	 * @param cls - The class of the edges to be examined.
	 * @return The target elements of the outgoing edges of the specified type.
	 */
	def <C extends Edge> findTargetsOf(Node node, Class<C> cls) {
		node.getOutgoing(cls).map[targetElement].filterNull
	}
	
	/**
	 * Retrieves the target element of an outgoing edge of specific type.
	 * <p>
	 * If more than one outgoing edge of the specified type exists the
	 * target element of the first of these edges is returned.
	 * <p>
	 * A warning is printed to the console if
	 * <ul>
	 * <li>more than one outgoing edge of the specified type exists or
	 * <li>the target element of the edge is {@code null}.
	 * </ul>
	 * <p>
	 * Convenient method for {@code getOutgoing(cls).head?.targetElement}
	 * 
	 * @param node - The node for which to examine outgoing edges.
	 * @param cls - The class of the edges to be examined.
	 * @return The target element of the outgoing edge of the specified type,
	 *   or {@code null} if none such edge exists or the target element is
	 *   {@code null}. 
	 */
	def <C extends Edge> Node findTargetOf(Node node, Class<C> cls) {
		val result = node.getOutgoing(cls)
		if (result.size > 1) System.err.println('''
			«result.size» outgoing edges of type '«cls»' found.
			  Exactly one was expected when calling method 'findTargetOf' on node «node».
		''')
		return result.head?.targetElement
	}
	
	/**
	 * Retrieves the container of the specified one.
	 * 
	 * @return  The container of the specified one, or {@code null} if not existent.
	 */
	def getContainer(ModelElementContainer it) {
		switch it {
			ModelElement: container
		}
	}
	
	
	/**
	 * Retrieves the PictogramElement of the specified container.
	 * 
	 * @return  The PictogramElement of the specified container.
	 */
	def getPictogramElement(ModelElementContainer it) {
		switch it {
			CModelElement: pictogramElement
		}
	}
	
	/**
	 * Moves a node to a target container.
	 * 
	 * @param node  The node to be moved.
	 * @param target  The container the node shall be moved to.
	 * @param x  The x-coordinate of the location of the node relative to the target container.
	 * @param y  The y-coordinate of the location of the node relative to the target container.
	 * @throws CincoInvalidTargetException  if moving the node to the target container fails.
	 *   This happens, if the target is invalid or the maximum cardinality has been reached.
	 *   However, whether a node can be moved to this container can be checked by calling
	 *   {@link #canMoveTo canMoveTo} first.
	 */
	def moveTo(Node node, ModelElementContainer target, int x, int y) {
		val diagram = target.pictogramElement.diagram
		val fp = diagram.featureProvider
		val context = node.getMoveShapeContext(target, x, y)
		if (context != null) {
			val feature = fp.getMoveShapeFeature(context)
			val canMove = switch it:feature {
				CincoMoveShapeFeature: canMoveShape(context, true)
				default: canMoveShape(context)
			}
			if (canMove)
				diagram.transact[ feature.moveShape(context) ]
			else {
				// FIXME: Enable distinct exceptions as soon as the error mechanism of the move feature is fixed
//				val error = switch feature { CincoMoveShapeFeature: feature.error }
//				val message = '''Failed to move «node.modelElement» into «target.modelElement». '''
//				switch error {
//					case MAX_CARDINALITY: throw new CincoContainerCardinalityException(message + "Cardinality has exceeded.")
//					case INVALID_TARGET: throw new CincoInvalidTargetException(message + "Container is an invalid target.")
//					default: throw new RuntimeException(message)
//				}
				throw new CincoInvalidTargetException('''Failed to move «node» into «target».''')
			}
		}
	}
	
	/**
	 * Tests whether a node can be moved to a target container.
	 * 
	 * @param node  The node to be moved.
	 * @param target  The container the node shall be moved to.
	 * @return  {@code true} if the node can be moved, {@code false} if the target is
	 *   invalid or the maximum cardinality has been reached.
	 */
	def canMoveTo(Node node, ModelElementContainer target) {
		val fp = target.pictogramElement.featureProvider
		val context = node.getMoveShapeContext(target,0,0)
		if (context != null) {
			val feature = fp.getMoveShapeFeature(context)
			switch it:feature {
				CincoMoveShapeFeature: canMoveShape(context, true)
				default: canMoveShape(context)
			}
		}
	}
	
	/**
	 * Creates a MoveShapeContext object. 
	 */
	private def getMoveShapeContext(Node node, ModelElementContainer target, int x, int y) {
		val pe = node.pictogramElement
		if (pe != null) {
			new MoveShapeContext(pe as Shape) => [
				setLocation(x,y)
				targetContainer = target.pictogramElement as ContainerShape
				sourceContainer = switch it:node.container {
					CGraphModel: pictogramElement
					Container: pictogramElement as ContainerShape
				}
			]
		}
	}
	
	/**
	 * Creates a list containing the specified container as well as its children.
	 */
	def withChildren(ModelElementContainer element) {
		#[element] + element.modelElements
	}
	
	/**
	 * Print a warning message to System.err
	 * 
	 * @param caller - The object that triggers console output.
	 * @param msg - The message to be printed
	 */
	def warn(Object caller, CharSequence msg) {
		System.err.println('''[«this.class.simpleName»] WARN «msg»''')
	}
}
