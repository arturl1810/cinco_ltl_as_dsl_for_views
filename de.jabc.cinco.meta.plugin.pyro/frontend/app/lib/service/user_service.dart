import 'dart:async';
import 'package:angular2/angular2.dart';
import '../model/core.dart';
import 'dart:html';
import 'dart:convert';

@Injectable()
class UserService {
  PyroUser user;
  Map requestHeaders = {'Content-Type':'application/json'};

  Future<PyroUser> login(dynamic userJson) async {
    //mockup
    user = PyroUser.fromJSON(userJson);
    print("[PYRO] login as user ${user.username}");
    return new Future.value(user);
  }


  Future<PyroUser> findUser(String username,String email) async {
    
    var data = {
      'username':username,
      'email':email
    };

    return HttpRequest.request("rest/user/current/addknown/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
      if(response.responseText=='None found' || response.responseText=='Already known'){
        throw new Exception(response.responseText);
      } else {
        return PyroUser.fromJSON(response.responseText);
      }
    }).catchError((ProgressEvent pe){
      if(pe.currentTarget is HttpRequest) {
        var request = pe.currentTarget;
        if(request.status == 401) {
          window.location.href="logout";
        }
        if(request.status == 400){
          window.console.error("[PYRO] BAD REQUEST");
        }
        if(request.status == 500) {
          window.console.error("[PYRO] SERVER ERROR");
        }
      }
    });

  }

  Future<PyroUser> loadUser() {
    return HttpRequest.request("rest/user/current/private",method: "GET",requestHeaders: requestHeaders).then((response){
      return PyroUser.fromJSON(response.responseText);
    }).catchError((ProgressEvent pe){
      if(pe.currentTarget is HttpRequest) {
        var request = pe.currentTarget;
        if(request.status == 401) {
          window.location.href="logout";
        }
        if(request.status == 400){
          window.console.error("[PYRO] BAD REQUEST");
        }
        if(request.status == 500) {
          window.console.error("[PYRO] SERVER ERROR");
        }
      }
    });
  }
  
  


}