package de.jabc.cinco.meta.plugin.pyro.frontend

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class Index extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameIndex()'''index.html'''
	
	def contentIndex()
	'''
	<!DOCTYPE html>
	<html>
	  <head>
	    <title>Pyro</title>
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	    <link rel="icon"
	          type="image/png"
	          href="asset/img/pyro.png" />
	    <link rel="stylesheet" href="asset/css/bootstrap.min.css" />
	    <link rel="stylesheet" href="asset/css/joint.css" />
	    <link rel="stylesheet" href="asset/css/pyro_core.css" />
	    <script type="application/javascript" src="asset/js/jquery.min.js"></script>
	    <script type="application/javascript" src="asset/js/bootstrap.min.js"></script>
	    <script type="application/javascript" src="asset/js/lodash.js"></script>
	    <script type="application/javascript" src="asset/js/backbone.js"></script>
	    <script type="application/javascript" src="asset/js/joint.js"></script>
	    <script type="application/javascript" src="asset/js/pyro_core.js"></script>
	«FOR g:gc.graphMopdels»
		<script type="application/javascript" src="asset/js/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_shapes.js"></script>
		<script type="application/javascript" src="asset/js/«g.name.lowEscapeDart»/controller.js"></script>
	«ENDFOR»
	    <script defer src="asset/main.dart" type="application/dart"></script>
	    <script defer src="asset/packages/browser/dart.js"></script>
	
	    <style>
	      body {
	        margin: 0 auto;
	        background-color: #333;
	        font-family: Roboto, Helvetica, Arial, sans-serif;
	      }
	    </style>
	  </head>
	  <body>
	  	<div id="hover-menu" style="top:-50px; position: absolute;z-index: 99999;">
	  	     <button id="menu-remove" class="btn btn-default" type="button"><span class="glyphicon glyphicon-trash"></span></button>
	  	     <button id="menu-edge" class="btn btn-default" type="button"><span class="glyphicon glyphicon-arrow-up"></span></button>
	  	</div>
	    <pyro-app>
	    <div style="width:100%;height:100%;text-align:center;padding-top: 5%;">
	    	<img style="top: 10%;left:50%" src="asset/img/pyro.png">
	    	<h3 style="color: #ff8001;">Loading Pyro..</h3>
	    	<div class="progress" style="
	    	    width: 30%;
	    	    margin-top: 20px;
	    	    position: relative;
	    	    left: 35%;">
	    	    <div class="progress-bar progress-bar-striped active" style="width: 100%;background-color: #be0101;"></div>
    	    </div>
    	</div>
	    </pyro-app>
	  </body>
	</html>
	
	'''
}