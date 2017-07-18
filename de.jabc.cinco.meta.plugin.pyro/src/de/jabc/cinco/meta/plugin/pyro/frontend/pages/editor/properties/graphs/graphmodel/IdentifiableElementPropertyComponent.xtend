package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.ModelElement
import de.jabc.cinco.meta.plugin.pyro.util.MGLExtension

class IdentifiableElementPropertyComponent extends Generatable {
	

	new(GeneratorCompound gc) {
		super(gc)
	}

	def fileNameIdentifiableElementPropertyComponent(
		String elementName) '''«elementName.escapeDart»_property_component.dart'''

	def contentIdentifiableElementPropertyComponent(GraphModel g, ModelElement me) '''
		import 'package:angular2/core.dart';
		
		import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
		
		@Component(
		    selector: '«me.name.lowEscapeDart»-property',
		    templateUrl: '«me.name.lowEscapeDart»_property_component.html',
		    directives: const []
		)
		class «me.name.fuEscapeDart»PropertyComponent implements OnInit {
		
		  @Input()
		  «me.name.fuEscapeDart» currentElement;
		
		  @Output()
		  EventEmitter hasChanged;
		
		
		  «me.name.fuEscapeDart»PropertyComponent()
		  {
		    hasChanged = new EventEmitter();
		  }
		
		  @override
		  void ngOnInit()
		  {
		
		  }
		  
		  void valueChanged(dynamic e) {
		  	hasChanged.emit(currentElement);
		  }
		  
		  // for each primitive list attribute
		  «FOR attr : me.attributes.filter[isPrimitive(g)].filter[isList]»
		  	void addList«attr.name.escapeDart»(dynamic e) {
		  	  e.preventDefault();
		  	  currentElement.«attr.name.escapeDart».add(«attr.init(g)»);
		  	  hasChanged.emit(currentElement);
		  	}
		  	void removeListmiaus(int index) {
		  	  currentElement.«attr.name.escapeDart».removeAt(index);
		  	  hasChanged.emit(currentElement);
		  	}
		  «ENDFOR»
		
		
		  int trackPrimitiveValue(int index, dynamic e)
		  {
		    return index;
		  }
		
		}
		
	'''

	def fileNameIdentifiableElementPropertyComponentTemplate(
		String elementName) '''«elementName.escapeDart»_property_component.html'''

	def contentIdentifiableElementPropertyComponentTemplate(GraphModel g, ModelElement me) '''
		<form class="form-horizontal" style="padding-right: 5px;">
		«IF me.attributes.filter[isPrimitive(g)].empty»
		No properties to display for «me.name.escapeDart».
		«ENDIF»
		«FOR attr : me.attributes.filter[isPrimitive(g)]»
			«IF !attr.isList»
				«IF attr.type.equals("EBoolean")»
					<div class="checkbox">
					    <label>
					     <input (blur)="valueChanged($event)" [(ngModel)]="currentElement.«attr.name.escapeDart»" type="checkbox"> «attr.name.escapeDart»
					    </label>
					</div>
				«ELSEIF attr.type.getEnum(g)!=null»
					<div class="form-group">
					       <label for="«attr.name.lowEscapeDart»">«attr.name.escapeDart»</label>
					       <select (blur)="valueChanged($event)" id="«attr.name.lowEscapeDart»" class="form-control" [(ngModel)]="currentElement.«attr.name.escapeDart»">
					       «FOR lit:attr.type.getEnum(g).literals»
					       	<option value="«attr.type.fuEscapeDart».«lit.escapeDart»">«lit.escapeDart»</option>
					       «ENDFOR»
					       </select>
					</div>
				«ELSE»
					<div class="form-group">
					    <label for="«attr.name.lowEscapeDart»">«attr.name.escapeDart»</label>
					    <input (blur)="valueChanged($event)" [(ngModel)]="currentElement.«attr.name.escapeDart»" type="«attr.htmlType»" class="form-control" id="«attr.name.lowEscapeDart»">
					</div>
				«ENDIF»
			«ELSE»
				«IF attr.type.getEnum(g)!= null»
					<div class="form-group">
					        <label>«attr.name.escapeDart»</label>
					        <a href (click)="addList«attr.name.escapeDart»($event)" style="color: white">
					            <span class="glyphicon glyphicon-plus"></span>
					         </a>
					         <div class="input-group" *ngFor="let i of currentElement.«attr.name.escapeDart»; let x = index;trackBy: trackPrimitiveValue" style="margin-bottom: 5px;">
					             <select class="form-control" (blur)="valueChanged($event)" [(ngModel)]="currentElement.«attr.name.escapeDart»[x]">
					                 «FOR lit:attr.type.getEnum(g).literals»
					                 	<option value="«attr.type.fuEscapeDart».«lit.escapeDart»">«lit.escapeDart»</option>
					                 «ENDFOR»
					             </select>
					             <span class="input-group-btn">
					                 <button (click)="removeList«attr.name.escapeDart»(x)" class="btn btn-default" type="button">
					                     <span class="glyphicon glyphicon-remove"></span>
					                 </button>
					             </span>
					         </div>
					</div>
				«ELSEIF attr.type.equals("EBoolean")»
					<div class="form-group">
					       <label>«attr.name.escapeDart»</label>
					       <a href (click)="addList«attr.name.escapeDart»($event)" style="color: white">
					           <span class="glyphicon glyphicon-plus"></span>
					       </a>
					       <div class="input-group" *ngFor="let i of currentElement.«attr.name.escapeDart»; let x = index;trackBy: trackPrimitiveValue" style="margin-bottom: 5px;">
					           <div class="checkbox">
					               <label>
					                   <input (blur)="valueChanged($event)" [(ngModel)]="currentElement.«attr.name.escapeDart»[x]" type="checkbox">
					                   <button (click)="removeList«attr.name.escapeDart»(x)" class="btn btn-default" type="button">
					                       <span class="glyphicon glyphicon-remove"></span>
					                   </button>
					               </label>
					           </div>
					       </div>
					</div>
				«ELSE»
					<div class="form-group">
					      	<label>«attr.name.escapeDart»</label>
					      	<a href (click)="addList«attr.name.escapeDart»($event)" style="color: white">
					      	    <span class="glyphicon glyphicon-plus"></span>
					      	</a>
					      	<div class="input-group" *ngFor="let i of currentElement.«attr.name.escapeDart»; let x = index; trackBy: trackPrimitiveValue" style="margin-bottom: 5px;">
					      	    <input (blur)="valueChanged($event)" [(ngModel)]="currentElement.«attr.name.escapeDart»[x]" type="«attr.htmlType»" class="form-control">
					      	    <span class="input-group-btn">
					      	        <button (click)="removeList«attr.name.escapeDart»(x)" class="btn btn-default" type="button">
					      	            <span class="glyphicon glyphicon-remove"></span>
					      	        </button>
					      	    </span>
					      	</div>
					</div>
				«ENDIF»
			«ENDIF»
		   «ENDFOR»
		</form>
	'''
}
