package de.jabc.cinco.meta.plugin.pyro.frontend.pages.users.info

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class UserInfoComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameUserInfoComponent()'''user_info_component.dart'''
	
	def contentFileUserInfoComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	
	@Component(
	    selector: 'user-info',
	    templateUrl: 'user_info_component.html'
	)
	class UserInfoComponent implements OnInit {
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	  UserInfoComponent()
	  {
	    close = new EventEmitter();
	    print("user info");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	}
	
	'''
	
}