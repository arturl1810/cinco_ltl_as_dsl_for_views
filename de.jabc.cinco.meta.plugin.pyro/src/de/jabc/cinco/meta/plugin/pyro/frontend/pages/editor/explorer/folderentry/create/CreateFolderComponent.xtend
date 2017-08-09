package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.folderentry.create

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class CreateFolderComponent extends Generatable {
	
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameCreateFolderComponent()'''create_folder_component.dart'''
	
	def contentCreateFolderComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	@Component(
	    selector: 'create-folder',
	    templateUrl: 'create_folder_component.html',
	    directives: const []
	)
	class CreateFolderComponent implements OnInit {
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroFolder folder;
	
	
	  CreateFolderComponent()
	  {
	    close = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void createNewFolder(String name,dynamic e)
	  {
	    print(name);
	    print(folder.name);
	      PyroFolder pf = new PyroFolder();
	      pf.name = name;
	      folder.innerFolders.add(pf);
	      //todo persist
	      e.preventDefault();
	      close.emit(e);
	  }
	
	
	}
	
	'''
	
	def fileNameCreateFolderComponentTemplate()'''create_folder_component.html'''
	def contentCreateFolderComponentTemplate()
	'''
	<div class="modal fade in" tabindex="-1" role="dialog" aria-labelledby="createEntryLabel" style="display: block; padding-left: 0px;">
	    <div class="modal-dialog" role="document">
	        <div class="modal-content">
	            <div class="modal-header">
	                <button (click)="close.emit($event)" type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	                <h4 class="modal-title" id="createEntryLabel">Create a new Folder</h4>
	            </div>
	            <div class="modal-body">
	                <form>
	                    <div class="form-group">
	                        <label for="projectName">Foldername</label>
	                        <input #foldername type="text" class="form-control" id="projectName" placeholder="Name">
	                    </div>
	                </form>
	            </div>
	            <div class="modal-footer">
	                <button (click)="createNewFolder(foldername.value,$event)" type="button" class="btn btn-success">Create {{foldername.value}}</button>
	                <button type="button" class="btn btn-default" data-dismiss="modal" (click)="close.emit($event)">Close</button>
	            </div>
	        </div>
	    </div>
	</div>
	'''
}