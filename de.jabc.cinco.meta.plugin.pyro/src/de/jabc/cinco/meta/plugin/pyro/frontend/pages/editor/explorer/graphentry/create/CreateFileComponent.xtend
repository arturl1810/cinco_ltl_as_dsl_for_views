package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.graphentry.create

import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import de.jabc.cinco.meta.plugin.pyro.util.Generatable

class CreateFileComponent extends Generatable{
	
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameCreateFileComponent()'''create_file_component.dart'''
	
	def contentCreateFileComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/service/graph_service.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
	«ENDFOR»
	
	@Component(
	    selector: 'create-file',
	    templateUrl: 'create_file_component.html',
	    directives: const []
	)
	class CreateFileComponent implements OnInit {
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroFolder folder;
	
	  final GraphService graphService;
	
	  CreateFileComponent(GraphService this.graphService)
	  {
	    close = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void createNewFile(String name,String type,dynamic e)
	  {
	      e.preventDefault();
	      if(name!=null && type != null)
	      {
	        switch(type)
	        {
	        	«FOR g:gc.graphMopdels»
	          case '«g.name.escapeDart»':{
	            var g = new «g.name.fuEscapeDart»();
	            g.filename = name;
	            graphService.create«g.name.escapeDart»(g,folder).then((g)=>close.emit(e));
	            break;
	          }
	          «ENDFOR»
	        }
	
	      }
	
	  }
	
	
	}

	'''
	
	def fileNameCreateFileComponentTemplate()'''create_file_component.html'''
	
	def contentCreateFileComponentTemplate()
	'''
	<div class="modal fade in" tabindex="-1" role="dialog" aria-labelledby="createEntryLabel" style="display: block; padding-left: 0px;">
	    <div class="modal-dialog" role="document">
	        <div class="modal-content">
	            <div class="modal-header">
	                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	                <h4 class="modal-title" id="createEntryLabel">Create a new File</h4>
	            </div>
	            <div class="modal-body">
	                <form>
	                    <div class="form-group">
	                        <label for="projectName">Filename</label>
	                        <input #filename type="text" class="form-control" id="projectName" placeholder="Name" required>
	                    </div>
	                    <div class="form-group">
	                        <select #fileType class="form-control" required>
	                        «FOR g:gc.graphMopdels»
	                            <option value="«g.name.fuEscapeDart»">«g.name.fuEscapeDart»</option>
                            «ENDFOR»
	                        </select>
	                    </div>
	                </form>
	            </div>
	            <div class="modal-footer">
	                <button (click)="createNewFile(filename.value,fileType.value,$event)" type="button" class="btn btn-success">Create {{filename.value}}</button>
	                <button type="button" class="btn btn-default" data-dismiss="modal" (click)="close.emit($event)">Close</button>
	            </div>
	        </div>
	    </div>
	</div>
	'''
}