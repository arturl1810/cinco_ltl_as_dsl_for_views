package de.jabc.cinco.meta.plugin.mcam.runtime.core

import de.jabc.cinco.meta.runtime.xapi.CodingExtension
import de.jabc.cinco.meta.runtime.xapi.CollectionExtension
import de.jabc.cinco.meta.runtime.xapi.FileExtension
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import de.jabc.cinco.meta.runtime.xapi.WorkspaceExtension
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import info.scce.mcam.framework.modules.CheckModule
import java.util.Map

import static extension org.jooq.lambda.Seq.toMap

abstract class CincoCheckModule<
			ID extends _CincoId,
			Model extends GraphModel,
			Adapter extends _CincoAdapter<ID,Model>
		> extends CheckModule<ID,Adapter> {
	
	protected extension CodingExtension = new CodingExtension
	protected extension CollectionExtension = new CollectionExtension
    protected extension WorkspaceExtension = new WorkspaceExtension
    protected extension WorkbenchExtension = new WorkbenchExtension
    protected extension GraphModelExtension = new GraphModelExtension
    protected extension ResourceExtension = new ResourceExtension
    protected extension FileExtension = new FileExtension
    
    protected Adapter adapter
    protected Map<IdentifiableElement,ID> cache
    
	override execute(Adapter adapter) {
		this.adapter = adapter
		this.cache = 
			adapter.entityIds
				.associateWithKey[element]
				.filterKeys(IdentifiableElement).toMap
		try {
			check(adapter.model)
		} catch(Exception e) {
			addError(adapter.model, '''Check execution failed («e.message»)''')
			e.printStackTrace
		}
	}
	
	override init() {/* default: do nothing */}
	
    abstract def void check(Model model)
    
	def <T extends IdentifiableElement> check(T elm, (T) => boolean test) {
		new Check(this, elm, test) 
	}
     
    def addError(IdentifiableElement element, String msg) {
		cache.get(element).addError(msg)
	}
	
	def addWarning(IdentifiableElement element, String msg) {
		cache.get(element).addWarning(msg)
	}
	
	def addInfo(IdentifiableElement element, String msg) {
		cache.get(element).addInfo(msg)
	}
    
    static class Check<T extends IdentifiableElement> {
		
		CincoCheckModule<?,?,?> check
		T elm
		(T) => boolean test
		
		new(CincoCheckModule<?,?,?> check, T elm, (T) => boolean test) {
			this.check = check
			this.elm = elm
			this.test = test
		}
		
		def elseError(String msg) {
			check.addError(elm, msg)
		}
		
		def elseWarning(String msg) {
			check.addError(elm, msg)
		}
		
		def elseInfo(String msg) {
			check.addError(elm, msg)
		}
	}
}