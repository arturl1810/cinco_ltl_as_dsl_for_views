import 'package:angular2/core.dart';
import 'dart:html';

@Component(
  selector: 'login',
  styleUrls: const ['login_component.css'],
  templateUrl: 'login_component.html'
)
class LoginComponent {
  @Output()
  EventEmitter loggedin;

  bool correct = true;

  LoginComponent()
  {
    loggedin = new EventEmitter();
  }

  void login(String username,String pw,dynamic e)
  {
    correct = true;
    var data = { 'username' : username, 'password' : pw };
    HttpRequest.postFormData('login.jsp', data).then((HttpRequest request) {
      if (request.readyState == HttpRequest.DONE && (request.status == 200))
      {
        var requestHeaders = {'Content-Type':'application/json'};
        HttpRequest.request("rest/user/current/private",method: "GET",requestHeaders: requestHeaders).then((response){
          loggedin.emit(response.responseText);
        }).catchError((_)=>correct=false);
      }
    });
    e.preventDefault();

  }
}

