package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.Edge
import graphmodel.ModelElement
import org.eclipse.graphiti.features.IFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IContext
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.features.context.impl.MoveBendpointContext
import org.eclipse.graphiti.features.context.impl.RemoveBendpointContext
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection

class EdgeLayoutUtils {
	
	extension val WorkbenchExtension = new WorkbenchExtension
	
	static protected final int GRID_DISTANCE = 10;
	
	def getGraphicsAlgorithm(ModelElement it) {
		pictogramElement?.graphicsAlgorithm
	}
	
	def getX(ModelElement it) {
		graphicsAlgorithm?.x
	}
	
	def getY(ModelElement it) {
		graphicsAlgorithm?.y
	}
	
	def getHeight(ModelElement it) {
		graphicsAlgorithm?.height
	}
	
	def getWidth(ModelElement it) {
		graphicsAlgorithm?.width
	}
	
	def Location getAbsoluteLocation(ModelElement elm) {
		val loc = new Location(elm.x, elm.y)
		var container = elm.container
		while (container instanceof ModelElement) {
			loc.x += container.x
			loc.y += container.y
			container = container.container
		}
		return loc
	}
	
	def Iterable<Location> alignTop(Iterable<Location> locs, int margin) {
		val top = locs.map[y].sort.head
		locs.map[it => [y = top - margin]]
	}
	
	def Iterable<Location> alignBottom(Iterable<Location> locs, int margin) {
		val bottom = locs.map[y].sort.last
		locs.map[it => [y = bottom + margin]]
	}
	
	def Iterable<Location> alignLeft(Iterable<Location> locs, int margin) {
		val left = locs.map[x].sort.head
		locs.map[it => [x = left - margin]]
	}
	
	def Iterable<Location> alignRight(Iterable<Location> locs, int margin) {
		val right = locs.map[x].sort.last
		locs.map[it => [x = right + margin]]
	}
	
	def int snapToGrid(int value) {
		GRID_DISTANCE * Math.round(value as double/GRID_DISTANCE) as int
	}

	def int snapToGrid(int value, int offset) {
		val snap = value.snapToGrid
		if (offset * (snap - value) <= 0)
			snap + offset
		else snap
	}
	
	def Iterable<Location> snapToGrid(Iterable<Location> locs) {
		locs.map[it => [
			x = x.snapToGrid
			y = y.snapToGrid
		]]
	}
	
	def Iterable<Location> snapXToGrid(Iterable<Location> locs) {
		locs.map[it => [x = x.snapToGrid]]
	}
	
	def Iterable<Location> snapYToGrid(Iterable<Location> locs) {
		locs.map[it => [y = y.snapToGrid]]
	}
	
	def getBendpoints(Edge edge) {
		edge.connection?.bendpoints ?: #[]
	}
	
	def FreeFormConnection getConnection(Edge it) {
		switch pe:pictogramElement {
			FreeFormConnection: pe
		}
	}
	
	def replaceBendpoints(Edge it, Location... locs) {
		val fp = diagram.diagramTypeProvider.featureProvider
		transact("Bendpoint editing") [
			removeBendpoints(fp)
			locs.forEach[loc|addBendpoint(loc.x, loc.y, fp)]
		]
	}
	
	def addBendpoints(Edge it, Location... locs) {
		val fp = diagram.diagramTypeProvider.featureProvider
		transact("Add bendpoints")[
			locs.forEach[loc|addBendpoint(loc.x, loc.y, fp)]
		]
	}
	
	def addBendpoint(Edge it, int x, int y) {
		addBendpoint(x, y, diagram.diagramTypeProvider.featureProvider)
	}
	
	private def addBendpoint(Edge it, int x, int y, IFeatureProvider fp) {
		val ctx = new AddBendpointContext(connection, x, y, bendpoints.size)
		fp.getAddBendpointFeature(ctx).executeWithContext(ctx)
	}
	
	def removeBendpoints(Edge it) {
		removeBendpoints(diagram.diagramTypeProvider.featureProvider)
	}
	
	def removeBendpoints(Edge it, IFeatureProvider fp) {
		transact("Delete bendpoints")[
			for (i: 0 ..< bendpoints.size)
				removeBendpoint(0, fp)
		]
	}
	
	def removeBendpoint(Edge it, int index) {
		removeBendpoint(index, diagram.diagramTypeProvider.featureProvider)
	}
	
	private def removeBendpoint(Edge it, int index, IFeatureProvider fp) {
		val ctx = new RemoveBendpointContext(connection, null) => [
			bendpointIndex = index
		]
		fp.getRemoveBendpointFeature(ctx).executeWithContext(ctx)
	}
	
	def moveBendpoints(Edge it, (Location) => Location move) {
		val fp = diagram.diagramTypeProvider.featureProvider
		transact("Move bendpoints")[
			for (i: 0 ..< bendpoints.size)
				moveBendpoint(i, move, fp)
		]
	}
	
	def moveBendpoint(Edge it, int index, (Location) => Location move) {
		moveBendpoint(index, move, diagram.diagramTypeProvider.featureProvider)
	}
	
	def moveBendpoint(Edge edge, int index, (Location) => Location move, IFeatureProvider fp) {
		val loc = move.apply(Location.toLocation(edge.bendpoints.get(index)))
		val ctx = new MoveBendpointContext(null) => [
			connection = edge.connection
			bendpointIndex = index
			setLocation(loc.x, loc.y)
		]
		fp.getMoveBendpointFeature(ctx).executeWithContext(ctx)
	}
	
	private def executeWithContext(IFeature it, IContext ctx) {
		val db = featureProvider.diagramTypeProvider.diagramBehavior
		db.executeFeature(it, ctx)
	}
	
	def Location getTopLeft(ModelElement elm) {
		elm.absoluteLocation
	}
	
	def Location getTopCenter(ModelElement elm) {
		elm.absoluteLocation => [x += elm.width/2]
	}
	
	def Location getTopRight(ModelElement elm) {
		elm.absoluteLocation => [x += elm.width]
	}
	
	def Location getMiddleLeft(ModelElement elm) {
		elm.absoluteLocation => [y += elm.height/2]
	}
	
	def Location getMiddleCenter(ModelElement elm) {
		elm.absoluteLocation => [
			x += elm.width/2
			y += elm.height/2
		]
	}
	
	def Location getMiddleRight(ModelElement elm) {
		elm.absoluteLocation => [
			x += elm.width
			y += elm.height/2
		]
	}
	
	def Location getBottomLeft(ModelElement elm) {
		elm.absoluteLocation => [y += elm.height]
	}
	
	def Location getBottomCenter(ModelElement elm) {
		elm.absoluteLocation => [
			x += elm.width/2
			y += elm.height
		]
	}
	
	def Location getBottomRight(ModelElement elm) {
		elm.absoluteLocation => [
			x += elm.width
			y += elm.height
		]
	}
	
	static class Location {
		
		protected int x = 0;
		protected int y = 0;
		
		def static Location toLocation(Point point) {
			return new Location(point.getX(), point.getY());
		}
		
		def static Iterable<Location> toLocation(Iterable<Point> points) {
			if (points == null)
				newArrayList
			else points.map[toLocation]
		}
		
		new(int x, int y) {
			this.x = x;
			this.y = y;
		}
		
		def toLeft(int dx) {
			this => [ x -= dx ]
		}
		
		def toRight(int dx) {
			this => [ x += dx ]
		}
		
		def toTop(int dy) {
			this => [ y -= dy ]
		}
		
		def toBottom(int dy) {
			this => [ y += dy ]
		}
		
		override toString() {
			'''(«x»,«y»)'''
		}
		
	}
}