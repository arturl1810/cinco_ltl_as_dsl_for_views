# How to Build <span style="font-variant: small-caps">Cinco</span>
## Building all Ecore Models

1. de.jabc.cinco.meta.core.mgl.model
 model/GraphModel.genmodel -> Generate Model Code
 model/MGL.genmodel -> Generate Model Code

2. de.jabc.cinco.meta.core.ge.style.model
 model/Style.genmodel -> Generate Model Code 

## Building Xtext Editors

3. de.jabc.cinco.meta.core.mgl
 src/de.jabc.cinco.meta.core.mgl/GenerateMGL.mwe2 -> Run as -> MWE2 Workflow -> Proceed
confirm donwload of antlr with 'y'

4. de.jabc.cinco.meta.core.ge.style
 src/de.jabc.cinco.meta.core.ge.style/GenerateStyle.mwe2 -> Run as -> MWE2 Workflow -> Proceed
confirm donwload of antlr with 'y'


## Building <span style="font-variant: small-caps">Cinco</span>
mvn clean package



