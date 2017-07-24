import 'dart:convert';
import 'dispatcher.dart';

abstract class PyroElement {
  int dywaId;
  int dywaVersion;
  String dywaName;
  Map toJSOG(Map cache);

  void merge(PyroElement ie);

  PyroElement({Map jsog,Map cache});
}

abstract class IdentifiableElement implements PyroElement{
  int dywaId;
  int dywaVersion;
  String dywaName;
  
  String $type();
}

abstract class ModelElement implements IdentifiableElement{
  int dywaId;
  int dywaVersion;
  String dywaName;
  ModelElementContainer container;

  List<IdentifiableElement> allElements()
  {
    List<IdentifiableElement> list = new List();
    list.add(this);
    return list;
  }
  
  List<String> styleArgs();
}

abstract class ModelElementContainer implements IdentifiableElement{
  int dywaId;
  int dywaVersion;
  String dywaName;
  List<ModelElement> modelElements;

  List<IdentifiableElement> allElements()
  {
      List<IdentifiableElement> list = new List();
      list.add(this);
      list.addAll(modelElements.expand((n) => n.allElements()));
      return list;
  }

}

abstract class Node implements ModelElement {
  int dywaId;
  int dywaVersion;
  String dywaName;
  ModelElementContainer container;
  List<Edge> incoming;
  List<Edge> outgoing;
  int x;
  int y;
  int width;
  int height;
  int angle;
}

abstract class Container implements Node, ModelElementContainer {
  int dywaId;
  int dywaVersion;
  String dywaName;
  ModelElementContainer container;
  List<Edge> incoming;
  List<Edge> outgoing;
  List<ModelElement> modelElements;
  int x;
  int y;
  int width;
  int height;
  int angle;
}

abstract class Edge implements ModelElement {
  int dywaId;
  int dywaVersion;
  String dywaName;
  ModelElementContainer container;
  Node source;
  Node target;
  List<BendingPoint> bendingPoints;
}

abstract class GraphModel implements ModelElementContainer {
  int dywaId;
  int dywaVersion;
  String dywaName;
  String filename;
  int width;
  int height;
  double scale;
  String router;
  String connector;
  List<ModelElement> modelElements;
  GlobalGraphModelSettings globalGraphModelSettings;

  void mergeStructure(GraphModel gm)
  {
    dywaName = gm.dywaName;
    dywaVersion = gm.dywaVersion;
    filename = gm.filename;
    width = gm.width;
    height = gm.height;
    scale = gm.scale;
    router = gm.router;
    connector = gm.connector;
  }
}

class BendingPoint implements PyroElement{
  int dywaId;
  int dywaVersion;
  String dywaName;
  int x;
  int y;
  BendingPoint({Map cache,dynamic jsog})
  {
    if(jsog!=null)
    {
      dywaId = jsog["dywaId"];
      dywaVersion = jsog["dywaVersion"];
      dywaName = jsog["dywaName"];
      x = jsog["x"];
      y = jsog["y"];

    }
    else{
      dywaId=-1;
      dywaName="BendingPoint";
      dywaVersion=0;
      x=0;
      y=0;
    }
  }
  @override
  Map toJSOG(Map cache)
  {
    Map map = new Map();
    if(cache.containsKey(dywaId)){
      map['@ref']=dywaId;
      return map;
    }
    cache[dywaId]=map;
    map['@id']=dywaId;
    map['dywaId'] = dywaId;
    map['dywaVersion'] = dywaVersion;
    map['dywaName'] = dywaName;
    map['x'] = x;
    map['y'] = y;
    return map;
  }

  void merge(IdentifiableElement ie){}

  @override
  BendingPoint fromJSOG(jsog, {Map cache}) {
    return new BendingPoint(cache: cache,jsog: jsog);
  }
}

class LocalGraphModelSettings {
  int dywaId;
  int dywaVersion;
  String dywaName;
  String router;
  String connector;

  List<GraphModel> openedGraphModels;
  
  LocalGraphModelSettings({Map cache,dynamic jsog})
  {
  	if(jsog!=null){
  		dywaId = jsog["dywaId"];
  		  dywaVersion = jsog["dywaVersion"];
  		  dywaName = jsog["dywaName"];
      router = jsog["router"];
      connector = jsog["connector"];
  		for(var g in jsog["openedGraphModels"]){
  			if(g.containsLey("@ref")){
  				openedGraphModels.add(cache[g["@ref"]]);
  			} else {
  		openedGraphModels.add( GraphModelDispatcher.dispatch(cache,g));
  	}
  		}
  	}
  	else{
  		dywaId = -1;
  		   dywaVersion = 0;
  		   dywaName = "localGraphmodelSettings";
  		   router = null;
  		   connector = "normal";
  			openedGraphModels = new List<GraphModel>();
  	}
  }
  
  	static LocalGraphModelSettings fromJSOG(dynamic jsog){
  		return new LocalGraphModelSettings(cache:new Map(),jsog:jsog);
  	}
  	
  	Map toJSOG(Map cache){
  		Map jsog = new Map();
  		if(cache.containsKey(dywaId)){
  	jsog["@ref"]=dywaId;
  } else {
  	cache[dywaId]=jsog;
  	jsog["@id"]=dywaId;
  	jsog["dywaId"]=dywaId;
  	jsog["dywaVersion"]=dywaVersion;
  	jsog["dywaName"]=dywaName;
    jsog["connector"]=connector;
    jsog["router"]=router;
  	jsog["openedGraphModels"]=openedGraphModels.map((n)=>n.toJSOG(cache));
  }
  return jsog;
  	}
}

class GlobalGraphModelSettings {
  int dywaId;
    int dywaVersion;
    String dywaName;
  GlobalGraphModelSettings({Map cache,dynamic jsog})
  {
    if(jsog!=null){
    	dywaId = jsog["dywaId"];
    	  dywaVersion = jsog["dywaVersion"];
    	  dywaName = jsog["dywaName"];
    } else {
    	dywaId = -1;
    	 dywaVersion = 0;
    	 dywaName = 'globalGraphmodelSettnings';
    }
  }
  Map toJSOG(Map cache){
  	Map jsog = new Map();
  if(cache.containsKey(dywaId)){
  	jsog["@ref"]=dywaId;
  		} else {
  			cache[dywaId]=jsog;
  jsog["@id"]=dywaId;
  jsog["dywaId"]=dywaId;
  jsog["dywaVersion"]=dywaVersion;
  jsog["dywaName"]=dywaName;
  		}
  		return jsog;
	}
}

class PyroUser {
  int dywaId;
  int dywaVersion;
  String dywaName;
  String username;
  String email;
  List<PyroUser> knownUsers;
  List<PyroProject> ownedProjects;
  List<PyroProject> sharedProjects;

  PyroUser({Map cache,dynamic jsog})
  {
    if(jsog!=null)
    {
      dywaId = jsog["dywaId"];
      dywaVersion = jsog["dywaVersion"];
      dywaName = jsog["dywaName"];
      username = jsog["username"];
      email = jsog["email"];
  for(var value in jsog["knownUsers"]){
  	if(value.containsKey("@ref")){
  		knownUsers.add(cache[value["@ref"]]);
  	} else {
  		knownUsers.add(new PyroUser(cache:cache,jsog:value));
  	}
  }
  for(var value in jsog["ownedProjects"]){
  	if(value.containsKey("@ref")){
  		ownedProjects.add(cache[value["@ref"]]);
  	} else {
  		ownedProjects.add(new PyroProject(cache:cache,jsog:value));
  	}
  }
  for(var value in jsog["sharedProjects"]){
  	if(value.containsKey("@ref")){
  		sharedProjects.add(cache[value["@ref"]]);
  	} else {
  		sharedProjects.add(new PyroProject(cache:cache,jsog:value));
  	}
  }
    }
    else{
      dywaId=-1;
      dywaName="PyroUser";
      dywaVersion=0;
      knownUsers = new List<PyroUser>();
      ownedProjects = new List<PyroProject>();
      sharedProjects = new List<PyroProject>();
    }
  }

  static PyroUser fromJSON(String s)
  {
    return fromJSOG(new Map(),JSON.decode(s));
  }

  static PyroUser fromJSOG(Map cache,dynamic jsog)
  {
    return new PyroUser(cache: cache,jsog: jsog);
  }

  String toJSON()
  {
    return JSON.encode(toJSOG(new Map()));
  }

  Map toJSOG(Map cache)
  {
    Map jsog = new Map();
    if(cache.containsKey(dywaId)){
  jsog["@ref"]=dywaId;
    } else {
    	cache[dywaId]=jsog;
    	jsog["@id"]=dywaId;
    jsog["dywaId"]=dywaId;
  jsog["dywaVersion"]=dywaVersion;
  			jsog["dywaName"]=dywaName;
  			jsog["username"]=username;
  			jsog["email"]=email;
  			jsog["knownUsers"]=knownUsers.map((n)=>n.toJSOG(cache));
  			jsog["ownedProjects"]=ownedProjects.map((n)=>n.toJSOG(cache));
  			jsog["sharedProjects"]=sharedProjects.map((n)=>n.toJSOG(cache));
    }
    return jsog;
  }
}

class PyroProject extends PyroFolder{
  int dywaId;
  int dywaVersion;
  String dywaName;
  PyroUser owner;
  String name;
  String description;
  List<PyroUser> shared;
  List<PyroFolder> innerFolders;
  List<GraphModel> graphModels;

  PyroProject({Map cache,dynamic jsog})
  {
    if(jsog!=null)
    {
  	dywaId = jsog["dywaId"];
  	dywaVersion = jsog["dywaVersion"];
  	dywaName = jsog["dywaName"];
  	  description = jsog["description"];
  	  name = jsog["name"];
  	  if(jsog["owner"].conainsKey("@ref")){
  	   	owner = cache[jsog["owner"]["@ref"]];
  	   } else {
  	   	owner = new PyroUser(cache:cache,jsog:jsog["owner"]);
  	   }
  	   for(var value in jsog["shared"]){
  	  if(value.containsKey("@ref")){
  	  		shared.add(cache[value["@ref"]]);
  	  	} else {
  	  		shared.add(new PyroUser(cache:cache,jsog:value));
  	  	}
  	  }
  	  for(var value in jsog["innerFolders"]){
  	  		if(value.containsKey("@ref")){
  	  				innerFolders.add(cache[value["@ref"]]);
  	  			} else {
  	  				innerFolders.add(new PyroFolder(cache:cache,jsog:value));
  	  			}
  	  		}
  	  		for(var value in jsog["graphModels"]){
  	  if(value.containsKey("@ref")){
  	  		graphModels.add(cache[value["@ref"]]);
  	  	} else {
  	  		graphModels.add( GraphModelDispatcher.dispatch(cache,value));
  	  	}
  	  }
	}
	   else{
	   	
	   	 dywaId=-1;
	   	 dywaName="PyroUser";
	   	 dywaVersion=0;
	   	 shared = new List<PyroUser>();
	   	 innerFolders = new List<PyroFolder>();
	   	 graphModels = new List<GraphModel>();
	   }
	 }

  static PyroProject fromJSON(String s)
  {
    return PyroProject.fromJSOG(cache: new Map(),jsog: JSON.decode(s));
  }

  static PyroProject fromJSOG({Map cache,dynamic jsog})
  {
    return new PyroProject(cache: cache,jsog: jsog);
  }

	Map toJSOG(Map cache) {
		Map jsog = new Map();
		if(cache.containsKey(dywaId)){
			jsog["@ref"]=dywaId;
		} else {
			cache[dywaId]=jsog;
			jsog['@id']=dywaId;
			jsog['dywaId']=dywaId;
			jsog['dywaVersion']=dywaVersion;
			jsog['dywaName']=dywaName;
			jsog['name']=name;
			if(owner!=null) {
				jsog['owner']=owner.toJSOG(cache);
			}
			jsog['description']=description;
			jsog['shared']=shared.map((n)=>n.dywaId).toList();
			jsog['innerFolders']=innerFolders.map((n)=>n.toJSOG(cache)).toList();
			jsog['graphModels']=graphModels.map((n)=>n.toJSOG(cache)).toList();
		}
		return jsog;
	}

}

class PyroFolder {
  int dywaId;
  int dywaVersion;
  String dywaName;
  String name;
  List<PyroFolder> innerFolders;
  List<GraphModel> graphModels;

  PyroFolder({Map cache,dynamic jsog})
  {
    if(jsog!=null)
    {
      dywaId = jsog["dywaId"];
      dywaVersion = jsog["dywaVersion"];
      dywaName = jsog["dywaName"];
      name = jsog["name"];
      for(var value in jsog["innerFolders"]){
      	if(value.containsKey("@ref")){
      			innerFolders.add(cache[value["@ref"]]);
      		} else {
      			innerFolders.add(new PyroFolder(cache:cache,jsog:value));
      		}
      	}
      for(var value in jsog["graphModels"]){
    if(value.containsKey("@ref")){
    		graphModels.add(cache[value["@ref"]]);
    	} else {
    		graphModels.add(GraphModelDispatcher.dispatch(cache,value));
    	}
    }
    }
    else{
      dywaId=-1;
      dywaName="PyroUser";
      dywaVersion=0;
      name = "";
      innerFolders = new List<PyroFolder>();
      graphModels = new List<GraphModel>();
    }
  }
  
  Map toJSOG(Map cache) {
	Map jsog = new Map();
	if(cache.containsKey(dywaId)){
		jsog["@ref"]=dywaId;
	} else {
		cache[dywaId]=jsog;
		jsog["@id"]=dywaId;
		jsog['dywaId']=dywaId;
		jsog['dywaVersion']=dywaVersion;
		jsog['dywaName']=dywaName;
		jsog['name']=name;
		jsog['innerFolders']=innerFolders.map((n)=>n.toJSOG(cache)).toList();
		jsog['graphModels']=graphModels.map((n)=>n.toJSOG(cache)).toList();
	}
	return jsog;
}

  static PyroFolder fromJSON(String s)
  {
    return PyroFolder.fromJSOG(new Map(),JSON.decode(s));
  }

  static PyroFolder fromJSOG(Map cache,dynamic jsog)
  {
    return new PyroProject(cache: cache,jsog: jsog);
  }

  List<GraphModel> allGraphModels()
  {
    List<GraphModel> gs = new List();
    gs.addAll(graphModels);
    gs.addAll(innerFolders.expand((n) => allGraphModels()).toList());
    return gs;
  }

  void merge(PyroFolder pp)
  {
    dywaId = pp.dywaId;
    dywaName = pp.dywaName;
    dywaVersion = pp.dywaVersion;
    name = pp.name;

    //remove missing graphmodels
    graphModels.removeWhere((n) => pp.graphModels.where((g) => n.dywaId==g.dywaId).isEmpty);
    //remove missing folders
    innerFolders.removeWhere((n) => pp.innerFolders.where((g) => n.dywaId==g.dywaId).isEmpty);

    //update graphmodels
    graphModels.forEach((n){
      n.mergeStructure(pp.graphModels.where((g) => g.dywaId==n.dywaId).first);

    });
    //update folders
    innerFolders.forEach((n){
      n.merge(pp.innerFolders.where((g) => g.dywaId==n.dywaId).first);

    });

    //add new graphmodels
    graphModels.addAll(pp.graphModels.where((n) => graphModels.where((g) => n.dywaId==g.dywaId).isEmpty));
    //add new folder
    graphModels.addAll(pp.graphModels.where((n) => graphModels.where((g) => n.dywaId==g.dywaId).isEmpty));
  }

}
