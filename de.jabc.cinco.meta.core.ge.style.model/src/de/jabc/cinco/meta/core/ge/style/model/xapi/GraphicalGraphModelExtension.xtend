package de.jabc.cinco.meta.core.ge.style.model.xapi

import de.jabc.cinco.meta.core.ge.style.model.features.CincoMoveShapeFeature
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphicalgraphmodel.CContainer
import graphicalgraphmodel.CEdge
import graphicalgraphmodel.CGraphModel
import graphicalgraphmodel.CModelElement
import graphicalgraphmodel.CModelElementContainer
import graphicalgraphmodel.CNode
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
	def <C extends CModelElement> find(CModelElementContainer container, Class<C> cls) {
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
	def <C extends CModelElement> Set<C> findDeeply(CModelElementContainer container, Class<C> cls, (CModelElement) => CModelElementContainer progression) {
		val filter = [EObject obj | if (obj.isInstanceOf(cls)) obj as C]
		val result = container.withChildren.map(filter).filterNull.toSet
		val next = [ newArrayList(
			progression.apply(it), 
			switch it { CModelElementContainer: it })
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
	def <C extends CModelElement> C findThe(CModelElementContainer container, Class<C> cls) {
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
	def <C extends CModelElement> C findThe(CModelElementContainer container, Class<C> cls, (C) => boolean predicate) {
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
	def <C extends CModelElement> Iterable<C> findParents(CModelElement it, Class<C> cls) {
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
	def <C extends CModelElement> C findFirstParent(CModelElement elm, Class<C> cls) {
		switch c:elm.container {
			case c.isInstanceOf(cls): c as C
			CModelElement: (c as CModelElement).findFirstParent(cls)
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
	def <C extends CModelElement> hasParent(CModelElement it, Class<C> cls) {
		findFirstParent(cls) != null
	}
	
	def <C extends CEdge> CNode findSourceOf(CNode node, Class<C> cls) {
		val result = node.getIncoming(cls)
		if (result.size > 1) System.err.println('''
			«result.size» incoming edges of type '«cls»' found.
			  Exactly one was expected when calling method 'findSourceOf' on node «node».
		''')
		return result.head?.sourceElement
	}
	
	def <C extends CEdge> CNode findTargetOf(CNode node, Class<C> cls) {
		val result = node.getOutgoing(cls)
		if (result.size > 1) System.err.println('''
			«result.size» outgoing edges of type '«cls»' found.
			  Exactly one was expected when calling method 'findTargetOf' on node «node».
		''')
		return result.head?.targetElement
	}
	
	def getContainer(CModelElementContainer it) {
		switch it {
			CModelElement: container
		}
	}
	
	def getPictogramElement(CModelElementContainer it) {
		switch it {
			CGraphModel: pictogramElement
			CContainer: pictogramElement
		}
	}
	
	def moveTo(CNode node, CModelElementContainer target, int x, int y) {
		val diagram = target.pictogramElement.diagram
		val fp = diagram.featureProvider
		val context = node.getMoveShapeContext(target)
		if (context != null) {
			val feature = fp.getMoveShapeFeature(context)
			val canMove = switch it:feature {
				CincoMoveShapeFeature: canMoveShape(context, true)
				default: canMoveShape(context)
			}
			if (canMove)
				diagram.transact[ feature.moveShape(context) ]
		}
	}
	
	def canMoveTo(CNode node, CModelElementContainer target) {
		val fp = target.pictogramElement.featureProvider
		val context = node.getMoveShapeContext(target)
		if (context != null) {
			val feature = fp.getMoveShapeFeature(context)
			switch it:feature {
				CincoMoveShapeFeature: canMoveShape(context, true)
				default: canMoveShape(context)
			}
		}
	}
	
	private def getMoveShapeContext(CNode node, CModelElementContainer target) {
		val pe = node.pictogramElement
		if (pe != null) {
			new MoveShapeContext(pe as Shape) => [
				setLocation(x,y)
				targetContainer = target.pictogramElement as ContainerShape
				sourceContainer = switch it:node.container {
					CGraphModel: pictogramElement
					CContainer: pictogramElement as ContainerShape
				}
			]
		}
	}
	
	def withChildren(CModelElementContainer element) {
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
