package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import org.eclipse.graphiti.internal.IDiagramVersion
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage
import org.eclipse.graphiti.mm.pictograms.impl.DiagramImpl
import org.eclipse.graphiti.util.IColorConstant

import static org.eclipse.graphiti.internal.util.LookManager.getLook
import static org.eclipse.graphiti.services.Graphiti.getGaService

abstract class LazyDiagram extends DiagramImpl {
	
	static extension val WorkbenchExtension = new WorkbenchExtension
	
	// for debugging only
	boolean debug = true
	def debug(String msg) {
//		if (debug && !initialized && !initializing) {
//			println('''[«this.class.simpleName»-«hashCode»] «msg»''')
//			debug = false
//		}
	}
	
	private String dtpId
	private Runnable initialization
	private boolean initialized
	private boolean initializing
	private boolean avoidInitialization
	
	new(String name, String dtpId) {
		super()
		setDiagramTypeId(name)
		setDiagramTypeProviderId(dtpId)
		setGridUnit(look.getMinorGridLineDistance)
		setSnapToGrid(true)
		setVisible(true)
		setName(name)
		eSet(PictogramsPackage.eINSTANCE.getDiagram_Version, IDiagramVersion.CURRENT)
		val rect = gaService.createRectangle(this)
		rect.setForeground(look.getMinorGridLineColor.addColor)
		rect.setBackground(look.getGridBackgroundColor.addColor)
		gaService.setSize(rect, 1000, 1000)
	}
	
	def initialize() {
		if (initialization != null) {
			initialization.run
		}
	}
	
	def assertInitialized() {
		if (!initialized && !avoidInitialization && !initializing ) {
			initializing = true
			transact[ initialize ]
			println('''[«this.class.simpleName»-«hashCode»] initialized''')
			initializing = false
			initialized = true
		}
	}
	
	def setInitialization(Runnable rbl) {
		initialization = rbl
	}
	
	override getAnchors() {
		debug("getAnchors")
		assertInitialized
		super.getAnchors
	}
	
	override getChildren() {
		debug("getChildren")
		assertInitialized
		super.getChildren
	}
	
	override getColors() {
		debug("getColors")
		assertInitialized
		super.getColors
	}
	
	override getConnections() {
		debug("getConnections")
		assertInitialized
		super.getConnections
	}
	
	override getContainer() {
//		debug("getContainer")
//		assertInitialized
		super.getContainer
	}
	
	override getDiagramTypeId() {
		debug("getDiagramTypeId")
		assertInitialized
		super.getDiagramTypeId
	}
	
	def String getDiagramTypeProviderId() {
//		debug("getDiagramTypeProviderId")
//		assertInitialized
		this.dtpId
	}
	
	override getFonts() {
		debug("getFonts")
		assertInitialized
		super.getFonts
	}
	
	override getGraphicsAlgorithm() {
		debug("getGraphicsAlgorithm")
		assertInitialized
		super.getGraphicsAlgorithm
	}
	
	override getGridUnit() {
//		debug("getGridUnit")
//		assertInitialized
		super.getGridUnit
	}
	
	override getLink() {
//		debug("getLink")
//		assertInitialized
		super.getLink
	}
	
	override getName() {
		debug("getName")
		assertInitialized
		super.getName
	}
	
	override getPictogramLinks() {
		debug("getPictogramLinks")
		assertInitialized
		super.getPictogramLinks
	}
	
	override getStyles() {
		debug("getStyles")
		assertInitialized
		super.getStyles
	}
	
	override getVersion() {
//		debug("getVersion")
//		assertInitialized
		super.getVersion
	}
	
	override getVerticalGridUnit() {
//		debug("getVerticalGridUnit")
//		assertInitialized
		super.getVerticalGridUnit
	}
	
	override isSnapToGrid() {
//		debug("isSnapToGrid")
//		assertInitialized
		super.isSnapToGrid
	}
	
	override setDiagramTypeId(String value) {
		//debug("setDiagramTypeId")
//		assertInitialized
		super.setDiagramTypeId(value)
	}
	
	def setDiagramTypeProviderId(String dtpId) {
		this.dtpId = dtpId
	}
	
	override setGridUnit(int value) {
		//debug("setGridUnit")
//		assertInitialized
		super.setGridUnit(value)
	}
	
	override setName(String value) {
		//debug("setName")
//		assertInitialized
		super.setName(value)
	}
	
	override setSnapToGrid(boolean value) {
		//debug("setSnapToGrid")
//		assertInitialized
		super.setSnapToGrid(value)
	}
	
	override setVerticalGridUnit(int value) {
		//debug("setVerticalGridUnit")
//		assertInitialized
		super.setVerticalGridUnit(value)
	}
	
//	def getFeatureProvider() {
//		fp ?: (fp = diagramTypeProvider.featureProvider)
//	}
	
//	def getDiagramTypeProvider() {
//		dtp ?: (dtp = extensionManager.createDiagramTypeProvider(this, getDiagramTypeProviderId))
//	}
	
//	def update() {
//		debug("update")
//		val ctx = new UpdateContext(this)
//		val feature = featureProvider.getUpdateFeature(ctx)
//		if (feature.canUpdate(ctx)) 
//			feature.update(ctx)
//	}

	def setAvoidInitialization(boolean flag) {
		avoidInitialization = flag
	}
	
	private def addColor(IColorConstant colconst) {
		val pkg = StylesPackage.eINSTANCE
		val col = StylesFactory.eINSTANCE.createColor
		col.eSet(pkg.color_Red, colconst.red)
		col.eSet(pkg.color_Green, colconst.green)
		col.eSet(pkg.color_Blue, colconst.blue)
		super.getColors.add(col)
		return col
	}
}
