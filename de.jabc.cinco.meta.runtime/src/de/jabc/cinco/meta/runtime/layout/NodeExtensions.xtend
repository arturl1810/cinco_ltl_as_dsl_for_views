package de.jabc.cinco.meta.runtime.layout

import graphmodel.Container
import graphmodel.GraphModel
import graphmodel.ModelElementContainer
import graphmodel.Node
import java.util.LinkedList

class NodeExtensions {

	static enum NodeResizing {
		NoResizing,
		WidenNodesToGreatestNodeSize,
		ShrinkNodesToSmallestNodeSize
	}

	static enum LineOfAlignment {
		Horizontal,
		MainDiagonal,
		Vertical,
		SecondaryDiagonal
	}

	/**
	 * Collects All Nodes in the graphmodel and returns them as a List.
	 * @param model Model in which the Nodes shall be collected.
	 */
	def Iterable<Node> collectAllNodesInModel(GraphModel model) {
		val LinkedList<Node> result = new LinkedList<Node>
		model.allNodes.forEach[n|collectAllNodesInModel(n, result)]
		return result
	}

	/**
	 * Recursive call for the method above.
	 */
	def private void collectAllNodesInModel(Node node, LinkedList<Node> result) {
		result.add(node)
		if (node instanceof Container) {
			node.allNodes.forEach[n|collectAllNodesInModel(n, result)]
		}
	}

	/**
	 * Collects All Nodes in the graphmodel node is contained in and returns them as a List.
	 * @param node A Node in the model in which the nodes shall be collected.
	 */
	def Iterable<Node> collectAllNodesInModel(Node node) {
		return node.rootElement.collectAllNodesInModel
	}

	/**
	 * Resizes the container, so that it is exactly big enough to show all it's children plus a padding.
	 * The method sees a container as a rectangle, so there may be unexpected behavior with containers that have other shapes. 
	 * @param container
	 * @param padding 
	 */
	def autoResize(Container container, int padding) {
		moveAllContainedNodesToNonNegativeKoordiantes(container)
		val Iterable<Node> innerNodes = container.allNodes
		if (innerNodes.isEmpty()) {
			container.resize(2 * padding, 2 * padding)
			return
		}
		val minimalX = innerNodes.minimalX
		if (minimalX != padding) {
			for (node : innerNodes) {
				node.move(node.x + padding - minimalX, node.y)
			}
		}
		val minimalY = innerNodes.minimalY
		if (minimalY != padding) {
			for (node : innerNodes) {
				node.move(node.x, node.y + padding - minimalY)
			}
		}
		container.resize(padding + innerNodes.maximalBottomX, padding + innerNodes.maximalRightY)
	}

	/**
	 * Resizes the container, so that it is exactly big enough to show all it's children plus a padding of 30.
	 * The method sees a container as a rectangle, so there may be unexpected behavior with containers that have other shapes.
	 * @param container
	 */
	def autoResize(Container container) {
		container.autoResize(30)
	}

	/**
	 * Support Method for autoResize
	 */
	def private moveAllContainedNodesToNonNegativeKoordiantes(Container container) {
		val Iterable<Node> innerNodes = container.allNodes
		val minimalX = innerNodes.minimalX
		val minimalY = innerNodes.minimalY
		if (minimalX < 0) {
			innerNodes.forEach[n|n.move(n.x - minimalX, n.y)]
		}
		if (minimalY < 0) {
			innerNodes.forEach[n|n.move(n.x, n.y - minimalY)]
		}
	}

	/**
	 * Moves movedNode to the container at the position (xPos ,yPos) measured from the top left corner of the container.
	 * @param movedNode Node to be moved to the container - must not be null.
	 * @param container Container into that movedNode will be moved - must not be null.
	 * @param xPos x-Position of movedNode in the new container.
	 * @param yPos y-Position of movedNode in the new container.
	 * @throws NodeCannotBeMovedToContainerException - If the movedNode cannot be moved to container.
	 */
	def moveNodeToContainer(Node movedNode, ModelElementContainer container, int xPos,
		int yPos) throws NodeCannotBeMovedToContainerException {
		if (movedNode.canMoveTo(container)) {
			movedNode.moveTo(container, xPos, yPos);
		} else {
			throw new NodeCannotBeMovedToContainerException("Child cannot be moved To Parent", movedNode, container)
		}
	}

	/**
	 * Moves movedNode into the container of anchor and places it next to anchor in the given distance measured from the top left corner of both nodes.
	 * @param Node movedNode Node to be aligned to the anchor - must not be null.
	 * @param anchor Node to that movedNode will be aligned - must not be null.
	 * @param distanceX distance between the Top left corner of movedNode and anchor on the x-Axis.
	 * @param distanceY distance between the Top left corner of movedNode and anchor on the y-Axis.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodeOverlapping(Node movedNode, Node anchor, int distanceX,
		int distanceY) throws NodeCannotBeMovedToContainerException {
		val xPos = anchor.x + distanceX
		val yPos = anchor.y + distanceY
		val newParent = anchor.container
		movedNode.moveNodeToContainer(newParent, xPos, yPos);
	}

	/**
	 * Moves movedNode into the container of anchor and places it next to anchor in the given distance.
	 * @param Node movedNode Node to be aligned to the anchor - must not be null.
	 * @param anchor Node to that movedNode will be aligned - must not be null.
	 * @param distanceX distance between the left side of movedNode and the right side of anchor on the x-Axis.
	 * @param distance> distance between the top side of movedNode and the bottom side of anchor on the y-Axis.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNode(Node movedNode, Node anchor, int distanceX,
		int distanceY) throws NodeCannotBeMovedToContainerException {
		movedNode.alignNodeOverlapping(anchor, distanceX + movedNode.width, distanceY + movedNode.height);
	}

	/**
	 * Alignes the Nodes from nodes as circle with radius radius and 
	 * the Centerpoint (centerX, centerY) in the Container cont.
	 * 
	 * @param nodes Iterable of Nodes that will be aligned as a circle - must not be null.
	 * @param cont Container to contain the circle of nodes - must not be null.
	 * @param centerX Horizontal coordinate of the centerpoint of the circle in cont.
	 * @param centerY Vertical coordinate of the centerpoint of the circle in cont.
	 * @param radius Radius of the circle.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsCircle(Iterable<Node> nodes, ModelElementContainer cont, int centerX, int centerY,
		int radius) throws NodeCannotBeMovedToContainerException {
		val N = nodes.length
		for (var int n = 0; n < N; n++) {
			val node = nodes.get(n)
			val x = radius * Math.cos((1.0 * n) / N * 2 * Math.PI) + centerX - node.width / 2
			val y = radius * Math.sin((1.0 * n) / N * 2 * Math.PI) + centerY - node.height / 2
			node.moveNodeToContainer(cont, x.intValue, y.intValue)
		}
	}

	/**
	 * Alignes the Nodes from nodes as row with anchor as node, which all other nodes are aligned to, 
	 * distances distance between the top left corner of the corresponding node and its neighbor and 
	 * degree expressing the direction of the row from anchor.
	 * 
	 * @param anchor Node, that is used as anchor for the row - must not be null.
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distances Distance between the top left corner of the corresponding node and its neighbor or in case of the first the anchor - not supposed to be shorter than nodes.
	 * @param degree Direction of the row from anchor measured from the horizontal axis of the screen.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsOverlappingRow(Node anchor, Iterable<Node> nodes, int[] distances,
		int degree) throws NodeCannotBeMovedToContainerException {
		if (nodes.size <= 0) {
			return
		}
		var Node anch = anchor
		var int deg = degree % 360
		var int x = 0
		var int y = 0
		for (var i = 0; i < nodes.size; i++) {
			x = (Math.cos(Math.toRadians(deg)) * distances.get(i)) as int
			y = (Math.sin(Math.toRadians(deg)) * distances.get(i)) as int

			nodes.get(i).alignNodeOverlapping(anch, x, y)
			anch = nodes.get(i)
		}
	}

	/**
	 * Alignes the Nodes from nodes as row with anchor as node, which all other nodes are aligned to, 
	 * distance between the top left corner of the corresponding node and its neighbor and 
	 * align expressing the direction of the row from anchor
	 * 
	 * @param anchor Node, that is used as anchor for the row - must not be null.
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distance Distance between the top left corner of the corresponding node and its neighbor or in case of the first the anchor.
	 * @param align Direction of the row from anchor.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsOverlappingRow(Node anchor, Iterable<Node> nodes, int distance,
		int degree) throws NodeCannotBeMovedToContainerException {
		val distances = newIntArrayOfSize(nodes.size)
		for (var i = 0; i < distances.size; i++) {
			distances.set(i, distance)
		}
		alignNodesAsOverlappingRow(anchor, nodes, distances, degree)
	}

	/**
	 * Alignes the Nodes from nodes as row with the first node in nodes as anchor, the node, which all other nodes are aligned to, 
	 * distance between the top left corner of the corresponding node and its neighbor and 
	 * align expressing the direction of the row from anchor
	 * 
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distance Distance between the top left corner of the corresponding node and its neighbor or in case of the first the anchor.
	 * @param align Direction of the row from anchor.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsOverlappingRow(Iterable<Node> nodes, int distance,
		LineOfAlignment align) throws NodeCannotBeMovedToContainerException {
		val anchor = nodes.head
		switch (align) {
			case Horizontal: {
				alignNodesAsOverlappingRow(anchor, nodes, distance, 0)
			}
			case MainDiagonal: {
				alignNodesAsOverlappingRow(anchor, nodes, distance, 45)
			}
			case Vertical: {
				alignNodesAsOverlappingRow(anchor, nodes, distance, 90)
			}
			case SecondaryDiagonal: {
				alignNodesAsOverlappingRow(anchor, nodes, distance, 135)
			}
		}
	}

	/**
	 * Alignes the Nodes from nodes as row with anchor as node, which all other nodes are aligned to, 
	 * distances distance between the corresponding node and its neighbor and 
	 * degree expressing the direction of the row from anchor.
	 * 
	 * @param anchor Node, that is used as anchor for the row - must not be null.
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distances Distance between the corresponding node and its neighbor or in case of the first the anchor - not supposed to be shorter than nodes.
	 * @param degree Direction of the row from anchor measured from the horizontal axis of the screen.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsRow(Node anchor, Iterable<Node> nodes, int[] distances,
		int degree) throws NodeCannotBeMovedToContainerException {
		var int[] dist = newIntArrayOfSize(nodes.size + 1)
		var int z = 0
		z = calculateDiameterforAlignNodesAsRow(anchor, degree)
		dist.set(0, z + distances.get(0))
		for (var i = 0; i < nodes.size; i++) {
			z = calculateDiameterforAlignNodesAsRow(nodes.get(i), degree)
			dist.set(i + 1, z + distances.get(i + 1))
		}
		alignNodesAsOverlappingRow(anchor, nodes, dist, degree)
	}
	/**
	 * Alignes the Nodes from nodes as row with anchor as node, which all other nodes are aligned to, 
	 * distance between the corresponding node and its neighbor and 
	 * align expressing the direction of the row from anchor.
	 * 
	 * @param anchor Node, that is used as anchor for the row - must not be null.
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distance Distance between the top left corner of the corresponding node and its neighbor or in case of the first the anchor - not supposed to be shorter than nodes.
	 * @param degree Direction of the row from anchor measured from the horizontal axis of the screen.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */

	def alignNodesAsRow(Node anchor, Iterable<Node> nodes, int distance,
		int degree) throws NodeCannotBeMovedToContainerException {
		val distances = newIntArrayOfSize(nodes.size + 1)
		for (var i = 0; i < distances.size; i++) {
			distances.set(i, distance)
		}
		alignNodesAsRow(anchor, nodes, distances, degree)
	}

	/**
	 * Alignes the Nodes from nodes as row with the first node in nodes as anchor, the node, which all other nodes are aligned to, 
	 * distance between the corresponding node and its neighbor and 
	 * align expressing the direction of the row from anchor.
	 * 
	 * @param nodes Iterable of Nodes that will be aligned to a row - must not be null.
	 * @param distance Distance between the top left corner of the corresponding node and its neighbor or in case of the first the anchor - not supposed to be shorter than nodes.
	 * @param align Direction of the row from anchor.
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsRow(Iterable<Node> nodes, int distance,
		LineOfAlignment align) throws NodeCannotBeMovedToContainerException {
		val anchor = nodes.head
		switch (align) {
			case Horizontal: {
				alignNodesAsRow(anchor, nodes, distance, 0)
			}
			case MainDiagonal: {
				alignNodesAsRow(anchor, nodes, distance, 45)
			}
			case Vertical: {
				alignNodesAsRow(anchor, nodes, distance, 90)
			}
			case SecondaryDiagonal: {
				alignNodesAsRow(anchor, nodes, distance, 135)
			}
		}
	}

	/**
	 * Alignes the Nodes from nodes as grid ordered in lines with
	 * the main line facing in the direction degreeX,
	 * the secondary line facing in the direction degreeY,
	 * distanceX between the top left corner of two nodes vertically,
	 * distanceY between the top left corner of two nodes horizontally,
	 * a linebreak after breakNumber Nodes and 
	 * anchor as node, which all other nodes are aligned to.
	 * If breakNumber is smaller than one, there will not be a break and distanceY is ignored
	 * If a node in the first column of the grid is repositioned in the process due to the fact that it is more than
	 * one time represented in nodes there may be unexpected behavior. 
	 * 
	 * @param anchor Node, that is used as anchor for the grid. - must not be null
	 * @param nodes Iterable of Nodes that will be aligned to a grid. - must not be null
	 * @param distanceX Horizontal distance between the top left corner of two adjacend nodes.
	 * @param degreeX Direction of the first line from anchor measured from the horizontal axis of the screen.
	 * @param breakNumber Number of nodes that form a line. After that there is a line break.
	 * @param distanceY Vertical distance between the top left corner of two adjacend nodes.
	 * @param degreeY Direction of the first column from anchor measured from the horizontal axis of the screen.
	 * @param rez Defines how all nodes from nodes and anchor should be resized in the process
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsOverlappingGrid(Node anch, Iterable<Node> nodes, int distanceX, int degreeX, int breakNumber,
		int distanceY, int degreeY, NodeResizing rez) throws NodeCannotBeMovedToContainerException {
		var break = breakNumber
		var Node anchor = anch
		switch (rez) {
			case WidenNodesToGreatestNodeSize: {
				(#{anchor} + nodes).WidenNodesToGreatestNodeSize
			}
			case ShrinkNodesToSmallestNodeSize: {
				(#{anchor} + nodes).ShrinkNodesToSmallestNodeSize
			}
			default: {
			}
		}
		if (nodes.size < 1) {
			return
		}
		if (breakNumber <= 0) {
			break = Integer::MAX_VALUE
		}
		val firstColumn = new LinkedList<Node>()
		for (var i = -1; i < nodes.size; i += breakNumber) {
			if (i > -1) {
				firstColumn.add(nodes.toList.get(i))
			}
		}
		alignNodesAsOverlappingRow(anch, firstColumn, distanceY, degreeY)
		for (var i = -1; i < nodes.size; i += break) {
			if (i > -1) {
				// nodes.toList.get(i).alignNode(anchor, 0, distanceY)
				anchor = nodes.toList.get(i)
			}
			alignNodesAsOverlappingRow(anchor, nodes.toList.subList(i + 1, Math.min(i + breakNumber, nodes.size)),
				distanceX, degreeX)
		}
	}

	/**
	 * Alignes the Nodes from nodes as grid ordered in lines with
	 * the main line facing in the direction indicated by align,
	 * the secondary line facing orthogonally to that direction,
	 * distance between the top left corner of two nodes,
	 * a linebreak after square root of the size of nodes rounded up and 
	 * the first node in nodes as anchor, the node, which all other nodes are aligned to.
	 * 
	 * @param nodes Iterable of Nodes that will be aligned to a grid. - must not be null
	 * @param distance Distance between the top left corner of two adjacend nodes.
	 * @param align Alignment of the grid, Horizontal and MainDiagonal result in a lined grid while Vertical and SecondaryDiagonal form a columned grid. 
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsOverlappingGrid(Iterable<Node> nodes, int distance,
		LineOfAlignment align) throws NodeCannotBeMovedToContainerException {
		var degreeX = 0
		var degreeY = 0
		var breakNumber = Math.sqrt(nodes.size) as int
		if (breakNumber * breakNumber != nodes.size) {
			breakNumber++
		}
		switch (align) {
			case Horizontal: {
				degreeX = 0
				degreeY = 90
			}
			case MainDiagonal: {
				degreeX = 45
				degreeY = 135
			}
			case Vertical: {
				degreeX = 90
				degreeY = 0
			}
			case SecondaryDiagonal: {
				degreeX = 135
				degreeY = 45
			}
		}
		alignNodesAsOverlappingGrid(nodes.head, nodes.tail, distance, degreeX, breakNumber, distance, degreeY,
			NodeResizing.NoResizing)
	}

	/**
	 * Alignes the Nodes from nodes as grid ordered in lines with
	 * the main line facing in the direction degreeX,
	 * the other line facing in the direction degreeY, 
	 * distanceX between two nodes vertically, 
	 * distanceY between two nodes horizontally,
	 * a linebreak after breakNumber Nodes and 
	 * anchor as node, which all other nodes are aligned to.
	 * If breakNumber is smaller than one, there will not be a break and distanceY is ignored
	 * If a node in the first column of the grid is repositioned in the process due to the fact that it is more than
	 * one time represented in nodes there may be unexpected behavior. 
	 * 
	 * @param anchor Node, that is used as anchor for the grid. - must not be null
	 * @param nodes Iterable of Nodes that will be aligned to a grid. - must not be null
	 * @param distanceX Horizontal distance between the top left corner of two adjacend nodes.
	 * @param degreeX Direction of the first line from anchor measured from the horizontal axis of the screen.
	 * @param breakNumber Number of nodes that form a line. After that there is a line break.
	 * @param distanceY Vertical distance between the top left corner of two adjacend nodes.
	 * @param degreeY Direction of the first column from anchor measured from the horizontal axis of the screen.
	 * @param rez Defines how all nodes from nodes and anchor should be resized in the process
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsGrid(Node anch, Iterable<Node> nodes, int distanceX, int degreeX, int breakNumber, int distanceY,
		int degreeY, NodeResizing rez) throws NodeCannotBeMovedToContainerException {
		var break = breakNumber
		var Node anchor = anch
		switch (rez) {
			case WidenNodesToGreatestNodeSize: {
				(#{anchor} + nodes).WidenNodesToGreatestNodeSize
			}
			case ShrinkNodesToSmallestNodeSize: {
				(#{anchor} + nodes).ShrinkNodesToSmallestNodeSize
			}
			default: {
			}
		}
		if (nodes.size < 1) {
			return
		}
		if (break <= 0) {
			break = nodes.size + 1
		}
		val firstColumn = new LinkedList<Node>()
		for (var i = -1; i < nodes.size; i += breakNumber) {
			if (i > -1) {
				firstColumn.add(nodes.toList.get(i))
			}
		}
		alignNodesAsRow(anch, firstColumn, distanceY, degreeY)
		for (var i = -1; i < nodes.size; i += breakNumber) {
			if (i > -1) {
				anchor = nodes.toList.get(i)
			}
			alignNodesAsRow(anchor, nodes.toList.subList(i + 1, Math.min(i + breakNumber, nodes.size)), distanceX,
				degreeX)
		}
	}

	/**
	 * Alignes the Nodes from nodes as grid ordered in lines with
	 * the main line facing in the direction indicated by align,
	 * the secondary line facing orthogonally to that direction,
	 * distance between two nodes,
	 * a linebreak after square root of the size of nodes rounded up and 
	 * the first node in nodes as anchor, the node, which all other nodes are aligned to.
	 * 
	 * @param nodes Iterable of Nodes that will be aligned to a grid. - must not be null
	 * @param distance Distance between the top left corner of two adjacend nodes.
	 * @param align Alignment of the grid, Horizontal and MainDiagonal result in a lined grid while Vertical and SecondaryDiagonal form a columned grid. 
	 * @throws NodeCannotBeMovedToContainerException if a node cannot be moved to the designated container.
	 */
	def alignNodesAsGrid(Iterable<Node> nodes, int distance,
		LineOfAlignment align) throws NodeCannotBeMovedToContainerException {
		var degreeX = 0
		var degreeY = 0
		var breakNumber = Math.sqrt(nodes.size) as int
		if (breakNumber * breakNumber != nodes.size) {
			breakNumber++
		}
		switch (align) {
			case Horizontal: {
				degreeX = 0
				degreeY = 90
			}
			case MainDiagonal: {
				degreeX = 45
				degreeY = 135
			}
			case Vertical: {
				degreeX = 90
				degreeY = 0
			}
			case SecondaryDiagonal: {
				degreeX = 135
				degreeY = 45
			}
		}
		alignNodesAsGrid(nodes.head, nodes.tail, distance, degreeX, breakNumber, distance, degreeY,
			NodeResizing.NoResizing)
	}

	/**
	 * Calculates the minimal X coordinate of all nodes in nodes.
	 */
	def private minimalX(Iterable<Node> nodes) {
		var x = Integer.MAX_VALUE
		for (node : nodes) {
			if (node.x < x) {
				x = node.x
			}
		}
		return x
	}

	/**
	 * Calculates the minimal Y coordinate of all nodes in nodes.
	 */
	def private minimalY(Iterable<Node> nodes) {
		var y = Integer.MAX_VALUE
		for (node : nodes) {
			if (node.y < y) {
				y = node.y
			}
		}
		return y
	}

	/**
	 * Calculates the maximal X coordinate at the bottom of all nodes in nodes.
	 */
	def private maximalBottomX(Iterable<Node> nodes) {
		var x = 0
		for (node : nodes) {
			if (node.width + node.x > x) {
				x = node.width + node.x
			}
		}
		return x
	}

	/**
	 * Calculates the maximal Y coordinate at the right side of all nodes in nodes.
	 */
	def private maximalRightY(Iterable<Node> nodes) {
		var y = 0
		for (node : nodes) {
			if (node.height + node.y > y) {
				y = node.height + node.y
			}
		}
		return y
	}

	/**
	 * Calculates the maximal width of all nodes in nodes.
	 */
	def private maximalNodeSizeHorizontal(Iterable<Node> nodes) {
		var x = 0
		for (node : nodes) {
			if (node.width > x) {
				x = node.width
			}
		}
		return x
	}

	/**
	 * Calculates the maximal height of all nodes in nodes.
	 */
	def private maximalNodeSizeVertical(Iterable<Node> nodes) {
		var y = 0
		for (node : nodes) {
			if (node.height > y) {
				y = node.height
			}
		}
		return y
	}

	/**
	 * Calculates the minimal width of all nodes in nodes.
	 */
	def private minimalNodeSizeHorizontal(Iterable<Node> nodes) {
		var x = Integer.MAX_VALUE
		for (node : nodes) {
			if (node.width < x) {
				x = node.width
			}
		}
		return x
	}

	/**
	 * Calculates the minimal height of all nodes in nodes.
	 */
	def private minimalNodeSizeVertical(Iterable<Node> nodes) {
		var y = Integer.MAX_VALUE
		for (node : nodes) {
			if (node.height < y) {
				y = node.height
			}
		}
		return y
	}

	/**
	 * Widens all nodes in nodes to the maximal width and height that a node in nodes has.
	 */
	def private WidenNodesToGreatestNodeSize(Iterable<Node> nodes) {
		val newX = nodes.maximalNodeSizeHorizontal()
		val newY = nodes.maximalNodeSizeVertical()
		nodes.forEach[node|node.resize(newX, newY)]
	}

	/**
	 * Shrinks all nodes in nodes to the minimal width and height that a node in nodes has.
	 */
	def private ShrinkNodesToSmallestNodeSize(Iterable<Node> nodes) {
		val newX = nodes.minimalNodeSizeHorizontal()
		val newY = nodes.minimalNodeSizeVertical()
		nodes.forEach[node|node.resize(newX, newY)]
	}

	/**
	 * Helpermethod for AlignNodesAsRow
	 * Calculates the diameter of the node with respect to the slope.
	 */
	def private int calculateDiameterforAlignNodesAsRow(Node node, int degree) {
		val double MX = node.x + 0.5 * node.width
		val double MY = node.y + 0.5 * node.height
		val double M = Math.tan(Math.toRadians(degree))
		val double B = MY - MX * M
		var boolean first = true
		var double X1 = 0
		var double X2 = 0
		var double Y1 = 0
		var double Y2 = 0
		// Y = MX + B && X = (Y - B)/M
		// Top
		if (node.x <= (node.y - B) / M && (node.y - B) / M < node.x + node.width) {
			if (first) {
				X1 = (node.y - B) / M
				Y1 = node.y
				first = false
			} else {
				X2 = (node.y - B) / M
				Y2 = node.y
			}
		}
		// Right
		if (node.y <= (M * (node.x + node.width)) + B && (M * (node.x + node.width)) + B < node.y + node.height) {
			if (first) {
				X1 = node.x + node.width
				Y1 = (M * (node.x + node.width)) + B
				first = false
			} else {
				X2 = node.x + node.width
				Y2 = (M * (node.x + node.width)) + B
			}
		}
		// Bottom
		if (node.x < (node.y + node.height - B) / M && (node.y + node.height - B) / M <= node.x + node.width) {
			if (first) {
				X1 = (node.y + node.height - B) / M
				Y1 = node.y + node.height
				first = false
			} else {
				X2 = (node.y + node.height - B) / M
				Y2 = node.y + node.height
			}
		}
		// Left
		if (node.y < (M * node.x) + B && (M * node.x) + B <= node.y + node.height) {
			if (first) {
				X1 = node.x
				Y1 = (M * node.x) + B
				first = false
			} else {
				X2 = node.x
				Y2 = (M * node.x) + B
			}
		}
		return Math.sqrt(Math.pow(Y2 - Y1, 2) + Math.pow(X2 - X1, 2)) as int
	}

}
