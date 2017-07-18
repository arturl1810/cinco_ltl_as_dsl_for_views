import 'package:angular2/core.dart';

@Component(
  selector: 'login',
  styleUrls: const ['login_component.css'],
  templateUrl: 'login_component.html'
)
class LoginComponent {
  @Output()
  EventEmitter loggedin;

  LoginComponent()
  {
    loggedin = new EventEmitter();
  }

  void login(String username,String pw,dynamic e)
  {
    print(username);
    print(pw);
    Map map = new Map();
    map['username'] = username;
    map['password'] = pw;
    e.preventDefault();
    loggedin.emit(map);
  }
}

