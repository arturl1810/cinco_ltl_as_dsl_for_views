import 'dart:async';
import 'package:angular2/angular2.dart';
import '../model/core.dart';
import '../model/somegraph.dart';

@Injectable()
class UserService {
  PyroUser user;

  Future<PyroUser> login(String username, String password) async {
    //mockup
    var pu = new PyroUser();
    pu.dywaId = 1;
    pu.dywaName = 'Mock user';
    pu.dywaVersion = 1;
    pu.email = username;
    pu.username = username;

    var body = new PyroUser();
    body.dywaId = 2;
    body.dywaName = 'Friend user';
    body.dywaVersion = 1;
    body.email = 'friend@aol.com';
    body.username = 'best-friend';

    pu.knownUsers.add(body);

    var p = new PyroProject();
    p.dywaId = 3;
    p.dywaVersion = 1;
    p.dywaName = 'my project';
    p.name = 'my project';
    p.description = 'my project description';
    p.owner = pu;

    var g = new SomeGraph();
    g.dywaId = 4;
    g.dywaVersion = 1;
    g.dywaName = "Somegraph";
    g.filename = "graph";

    p.graphModels.add(g);

    var n1 = new SomeNode();
    n1.dywaId = 5;
    n1.x=100;
    n1.y=100;
    n1.dywaName="some node";
    n1.label = "fooo";
    n1.container = g;
    n1.dywaVersion = 1;
    
    var t1 = new MyType();
    t1.dywaId = 6;
    t1.dywaVersion = 1;
    t1.dywaName = "my type";
    t1.text = "ex test";
    n1.myType = t1;

    g.modelElements.add(n1);

    pu.ownedProjects.add(p);

    var ps = new PyroProject();
    ps.dywaId = 4;
    ps.dywaVersion = 1;
    ps.dywaName = 'my shared project';
    ps.name = 'my shared project';
    ps.description = 'my shared project description';
    ps.owner = body;
    ps.shared.add(pu);

    pu.sharedProjects.add(ps);

    user = pu;
    print("[Send] login");
    return new Future.value(user);
  }

  void logout() {

  }


  Future<PyroUser> findUser(String username,String email) async {
    var pu = new PyroUser();
    pu.dywaId = 2;
    pu.dywaName = 'Found Mock user';
    pu.dywaVersion = 1;
    pu.email = email;
    pu.username = username;
    print("[Send] search for user ${username}");
    return new Future.value(pu);
  }

  Future<PyroUser> updateUser(PyroUser user) {
  	print("[Send] update user ${user.username}");
    return new Future.value(user);
  }
}