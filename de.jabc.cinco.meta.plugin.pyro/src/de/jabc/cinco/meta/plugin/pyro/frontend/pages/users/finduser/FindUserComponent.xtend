package de.jabc.cinco.meta.plugin.pyro.frontend.pages.users.finduser

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class FindUserComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameFindUserComponent()'''find_user_component.dart'''
	
	def contentFindUserComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	
	@Component(
	    selector: 'find-user',
	    templateUrl: 'find_user_component.html'
	)
	class FindUserComponent implements OnInit {
	
	
	  @Output()
	  EventEmitter searchUser;
	
	  @Output()
	  EventEmitter close;
	
	  @Input()
	  PyroUser user;
	
	  FindUserComponent()
	  {
	    searchUser = new EventEmitter();
	    close = new EventEmitter();
	    print("find user");
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void submitSearchUser(String name,String email)
	  {
	    Map map = new Map();
	    map['username'] = name;
	    map['email'] = email;
	    this.searchUser.emit(map);
	  }
	
	}
	
	'''
	
}