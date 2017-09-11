import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../../service/user_service.dart';


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

  bool searching = false;
  bool notFound = false;
  bool found = false;

  final UserService userService;

  FindUserComponent(UserService this.userService)
  {
    searchUser = new EventEmitter();
    close = new EventEmitter();
    print("find user");
  }

  @override
  void ngOnInit()
  {
    searching = false;
  }

  void submitSearchUser(String name,String email)
  {
    notFound=false;
    found = false;
    userService.findUser(name,email).then((n){
      user.knownUsers.add(n);
      notFound=false;
      found = true;
    }).catchError((e){
      notFound=true;
      found = false;
    });
  }

}

