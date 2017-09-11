package de.jabc.cinco.meta.plugin.pyro.frontend.pages.projects.settings

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class SettingsComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameSettingsComponent()'''settings_component.dart'''
	
	def contentSettingsComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	
	@Component(
	    selector: 'settings',
	    templateUrl: 'settings_component.html'
	)
	class SettingsComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	  @Input()
	  PyroProject project;
	
	  @Input()
	  GraphModel graphModel;
	
	  SettingsComponent()
	  {
	    close = new EventEmitter();
	    print("settings component");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void saveSettings(dynamic e)
	  {
	
	    e.preventDefault();
	  }
	
	}
	
	'''
	
}