package de.jabc.cinco.meta.plugin.pyro.templates

class StaticContent {
	def parentPom()
	'''
	<?xml version="1.0" encoding="UTF-8"?>
<project
		xmlns="http://maven.apache.org/POM/4.0.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<groupId>de.mtf.dywa</groupId>
	<artifactId>testapp</artifactId>
	<version>0.1-SNAPSHOT</version>
	<packaging>pom</packaging>

	<name>Test App Parent</name>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<!-- By default, this value is empy -->
		<de.ls5.dywa.instanceId></de.ls5.dywa.instanceId>
		<de.ls5.dywa.version>0.6-SNAPSHOT</de.ls5.dywa.version>
		<de.ls5.dywa.generation.packageName>de.ls5.dywa.generated</de.ls5.dywa.generation.packageName>
		<de.ls5.dywa.generation.processFilter>de.ls5.dywa.generated.process</de.ls5.dywa.generation.processFilter>
		<de.jabc4.codegenerator.version>5.5</de.jabc4.codegenerator.version>
		<de.jabc4.basics.version>5.13</de.jabc4.basics.version>
		<de.mtf.dywa.finalName>testapp</de.mtf.dywa.finalName>
	</properties>

	<profiles>
		<profile>
			<id>default</id>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
			<modules>
				<module>testapp-preconfig</module>
				<module>testapp-persistence</module>
				<module>testapp-business</module>
				<module>testapp-plugin</module>
				<module>testapp-presentation</module>
			</modules>
		</profile>
		<profile>
			<id>prepareModeling</id>
			<modules>
				<module>testapp-persistence</module>
				<module>testapp-plugin</module>
				<module>testapp-project</module>
				<module>testapp-service</module>
			</modules>
		</profile>
		<profile>
			<id>all</id>
			<modules>
				<module>testapp-persistence</module>
				<module>testapp-business</module>
				<module>testapp-plugin</module>
				<module>testapp-presentation</module>
				<module>testapp-project</module>
				<module>testapp-service</module>
			</modules>
		</profile>
	</profiles>

	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>3.2</version>
				<configuration>
					<source>1.8</source>
					<target>1.8</target>
				</configuration>
			</plugin>
		</plugins>
	</build>

	<repositories>
		<repository>
			<id>maven-public</id>
			<name>LS5 Public Repository</name>
			<url>https://ls5svn.cs.tu-dortmund.de/maven-public</url>
		</repository>
		<repository>
			<id>maven-edu</id>
			<name>LS5 Education Repository</name>
			<url>https://ls5svn.cs.tu-dortmund.de/maven-edu</url>
		</repository>
	</repositories>

	<pluginRepositories>
		<pluginRepository>
			<id>maven-public</id>
			<name>LS5 Public Repository</name>
			<url>https://ls5svn.cs.tu-dortmund.de/maven-public</url>
		</pluginRepository>
		<pluginRepository>
			<id>maven-edu</id>
			<name>LS5 Education Repository</name>
			<url>https://ls5svn.cs.tu-dortmund.de/maven-edu</url>
		</pluginRepository>
	</pluginRepositories>

</project>
	
	'''
	
	def businessPom()
	'''
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<parent>
		<groupId>de.mtf.dywa</groupId>
		<artifactId>testapp</artifactId>
		<version>0.1-SNAPSHOT</version>
		<relativePath>../pom.xml</relativePath>
	</parent>

	<artifactId>testapp-business</artifactId>
	<packaging>jar</packaging>

	<name>testapp-business</name>
	<url>http://maven.apache.org</url>


	<build>
		<resources>
			<resource>
				<filtering>true</filtering>
				<directory>${basedir}/src/main/resources</directory>
				<includes>
					<include>config.properties</include>
				</includes>
			</resource>
			<resource>
				<filtering>false</filtering>
				<directory>${basedir}/src/main/resources</directory>
			</resource>
		</resources>
		<plugins>
			<plugin>
				<groupId>de.jabc</groupId>
				<artifactId>jabc4-codegenerator-plugin</artifactId>
				<version>${de.jabc4.codegenerator.version}</version>
				<executions>
					<execution>
						<goals>
							<goal>generate</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<sourceDirectory>${basedir}/src/main/resources</sourceDirectory>
						</configuration>
					</execution>
				</executions>
				<dependencies>
					<dependency>
						<groupId>de.jabc</groupId>
						<artifactId>jabc4-java-codegenerator-java</artifactId>
						<version>${de.jabc4.codegenerator.version}</version>
					</dependency>
					<dependency>
						<groupId>de.mtf.dywa</groupId>
						<artifactId>testapp-persistence</artifactId>
						<version>${project.version}</version>
						<exclusions>
							<exclusion>
								<groupId>org.jboss.spec</groupId>
								<artifactId>jboss-javaee-7.0</artifactId>
							</exclusion>
						</exclusions>
					</dependency>
					<dependency>
						<groupId>de.jabc</groupId>
						<artifactId>jabc4-basic-graphs</artifactId>
						<version>${de.jabc4.basics.version}</version>
					</dependency>
				</dependencies>
			</plugin>

			<plugin>
				<groupId>de.ls5.dywa</groupId>
				<artifactId>process-generator-plugin</artifactId>
				<version>${de.ls5.dywa.version}</version>
				<executions>
					<execution>
						<goals>
							<goal>generate</goal>
						</goals>
						<phase>generate-resources</phase>
						<configuration>
							<sourceDirectory>${basedir}/src/main/resources</sourceDirectory>
							<finalArtifactName>${de.mtf.dywa.finalName}${de.ls5.dywa.instanceId}</finalArtifactName>
						</configuration>
					</execution>
				</executions>
				<configuration>
					<packageName>${de.ls5.dywa.generation.packageName}</packageName>
					<apiPackages>
						<apiPackage>${de.ls5.dywa.generation.processFilter}</apiPackage>
					</apiPackages>
				</configuration>
				<dependencies>
					<dependency>
						<groupId>de.mtf.dywa</groupId>
						<artifactId>testapp-persistence</artifactId>
						<version>${project.version}</version>
					</dependency>
				</dependencies>
			</plugin>

			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>build-helper-maven-plugin</artifactId>
				<version>1.8</version>
				<executions>
					<execution>
						<id>add-source</id>
						<phase>generate-sources</phase>
						<goals>
							<goal>add-source</goal>
						</goals>
						<configuration>
							<sources>
								<source>${project.build.directory}/generated-sources</source>
							</sources>
						</configuration>
					</execution>
					<execution>
						<id>add-resource</id>
						<phase>generate-resources</phase>
						<goals>
							<goal>add-resource</goal>
						</goals>
						<configuration>
							<resources>
								<resource>
									<directory>${project.build.directory}/generated-resources</directory>
								</resource>
							</resources>
						</configuration>
					</execution>
				</executions>
			</plugin>

			<plugin>
				<groupId>com.googlecode.maven-java-formatter-plugin</groupId>
				<artifactId>maven-java-formatter-plugin</artifactId>
				<version>0.4-ls5</version>
				<executions>
					<execution>
						<goals>
							<goal>format</goal>
						</goals>
						<phase>process-resources</phase>
						<configuration>
							<sourceDirectory>${project.build.directory}/generated-sources</sourceDirectory>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<groupId>de.jabc</groupId>
				<artifactId>maven-jabc4-png-export</artifactId>
				<version>7</version>
				<executions>
					<execution>
						<goals>
							<goal>generate</goal>
						</goals>
						<configuration>
							<sourceDirectory>${basedir}/src/main/resources</sourceDirectory>
						</configuration>
					</execution>
				</executions>
				<dependencies>
					<dependency>
						<groupId>de.mtf.dywa</groupId>
						<artifactId>testapp-persistence</artifactId>
						<version>${project.version}</version>
						<exclusions>
							<exclusion>
								<groupId>org.jboss.spec</groupId>
								<artifactId>jboss-javaee-7.0</artifactId>
							</exclusion>
						</exclusions>
					</dependency>
					<dependency>
						<groupId>de.jabc</groupId>
						<artifactId>jabc4-basic-graphs</artifactId>
						<version>${de.jabc4.basics.version}</version>
					</dependency>
				</dependencies>
			</plugin>
		</plugins>
	</build>

	<dependencies>
		<dependency>
			<groupId>de.jabc</groupId>
			<artifactId>jabc4-codegenerator-api</artifactId>
			<version>${de.jabc4.codegenerator.version}</version>
		</dependency>
		<dependency>
			<groupId>org.jboss.spec</groupId>
			<artifactId>jboss-javaee-7.0</artifactId>
			<version>1.0.0.Final</version>
			<type>pom</type>
		</dependency>
		<dependency>
			<groupId>commons-io</groupId>
			<artifactId>commons-io</artifactId>
			<version>2.4</version>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>annotations</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>api</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>adapter</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.mtf.dywa</groupId>
			<artifactId>testapp-persistence</artifactId>
			<version>${project.version}</version>
		</dependency>
		<dependency>
			<groupId>de.jabc</groupId>
			<artifactId>jabc4-basic-graphs</artifactId>
			<version>${de.jabc4.basics.version}</version>
		</dependency>
		<dependency>
			<groupId>de.jabc</groupId>
			<artifactId>jabc4-basic-java</artifactId>
			<version>${de.jabc4.basics.version}</version>
		</dependency>
		<dependency>
			<groupId>com.googlecode.json-simple</groupId>
			<artifactId>json-simple</artifactId>
			<version>1.1.1</version>
		</dependency>
	</dependencies>

</project>
	
	'''
	
	def messageExecution()
	'''
	package de.ls5.cinco.command;

import de.ls5.cinco.message.MessageParser;
import org.json.simple.JSONObject;

/**
 * Created by zweihoff on 16.06.15.
 */
public class MessageExecution {
    public static void executeCreateMessage(String message) {
        JSONObject jsonObject = MessageParser.parse(message);

    }

    public static void executeEditMessage(String message) {

    }

    public static void executeRemoveMessage(String message) {

    }
}
	
	'''
	
	def cincoCustomAction()
	'''
	package de.ls5.cinco.custom.feature;

import de.ls5.cinco.transformation.api.CIdentifiableElement;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public abstract class CincoCustomAction<T extends CIdentifiableElement> {

    public abstract boolean canExecute(T cModelElement);
    public abstract void execute(T cModelElement);
    public abstract String getName();
}
	
	'''
	
	def cincoCustomHook()
	'''
	package de.ls5.cinco.custom.feature;

import de.ls5.cinco.transformation.api.CIdentifiableElement;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public abstract class CincoCustomHook<T extends CIdentifiableElement> {

    public abstract boolean canExecute(T cModelElement);
    public abstract void execute(T cModelElement);
}
	
	'''
	
	def cincoDBController()
	'''
	package de.ls5.cinco.deployment;

/**
 * Created by zweihoff on 23.03.15.
 */
public interface CincoDBController {

    /**
     * Creates all necessary DBTypes for the underlying Cinco GraphModel.ecore and MGL
     */
    public void createGraphModelDBTypes();

    public void removeGraphModelDBTypes();

}
	
	'''
	
	def messageParser()
	'''
	package de.ls5.cinco.message;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Created by zweihoff on 09.07.15.
 */
public class MessageParser {
    public static JSONObject parse(String jsonString)
    {
        JSONParser parser = new JSONParser();
        try {
            Object object = parser.parse(jsonString);
            return (JSONObject) object;
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }
}
	
	'''
	
	def pointParser()
	'''
	package de.ls5.cinco.parser;

import de.ls5.dywa.generated.entity.Point;
import org.json.simple.JSONObject;

/**
 * Created by zweihoff on 24.06.15.
 */
public class PointParser {

    public static JSONObject toJSON(Point point){
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("x",new Long(point.getx()));
        jsonObject.put("y",new Long(point.gety()));
        return jsonObject;
    }
}
	
	'''
	
	def cBendingPoint()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.Point;

/**
 * Created by zweihoff on 26.06.15.
 */
public interface CBendingpoint {

    Point getPoint();

    void setPoint(Point point);
}
	
	'''
	
	def cBendingPointImpl()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.Point;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public class CBendingpointImpl implements CBendingpoint{
    private Point point;

    public CBendingpointImpl(){}

    public CBendingpointImpl(Point point) {
        this.point = point;
    }

    public Point getPoint() {
        return point;
    }

    public void setPoint(Point point) {
        this.point = point;
    }
}
	
	'''
	
	def cContainer()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.ModelElementContainer;

import java.util.List;

/**
 * Created by zweihoff on 16.06.15.
 */
public interface CContainer extends CNode, CModelElementContainer {


    public List<CModelElement> getModelElements();


    public void addModelElement(CModelElement cModelElement);

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz);

    public void setModelElements(List<CModelElement> cModelElements);

    public List<CNode> getAllCNodes();

    public List<CEdge> getAllCEdges();

    public List<CContainer> getAllCContainers();
    public ModelElementContainer getModelElementContainer();
    
    public void setModelElementContainer(ModelElementContainer modelElementContainer);
}
	
	
	'''
	
	def cEdge()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.Edge;
import de.ls5.dywa.generated.entity.ModelElement;

import java.util.List;

public interface CEdge extends CModelElement {

    public CNode getSourceElement();

    public void reconnectSource(CNode cNode);

    public void reconnectTarget(CNode cNode);

    public void setSourceElement(CNode value);

    public CNode getTargetElement();

    public void setTargetElement(CNode value);

    public void addBendingPoint(long x,long y);

    public void addBendingPoint(CBendingpoint bendingpoint);

    public List<CBendingpoint> getBendingpoints();

    public void setBendingPoints(List<CBendingpoint> bendingPoints);
    
    public void setModelElement(ModelElement modelElement);
    
    public ModelElement getModelElement();

    public void setEdge(Edge edge);

    public Edge getEdge();
    
    public void update();
    
    public boolean delete();
    
    public <T extends CGraphModel> T getCRootElement();
} // CEdge
	
	'''
	
	def cGraphModel()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.GraphModel;
import de.ls5.dywa.generated.entity.ModelElementContainer;

import java.util.List;

/**
 * Generated by Pyro Meta Plugin
 */
public interface CGraphModel extends CModelElementContainer{

    public List<CModelElement> getModelElements();

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz);

    public void setModelElements(List<CModelElement> cModelElements);

    public void addModelElement(CModelElement cModelElement);

    public List<CNode> getAllCNodes();

    public List<CEdge> getAllCEdges();

    public List<CContainer> getAllCContainers();

    public GraphModel getGraphModel();

    public void setGraphModel(GraphModel graphModel);

    public ModelElementContainer getModelElementContainer();

    public void setModelElementContainer(ModelElementContainer modelElementContainer);
}
	
	'''
	
	def cIdentifiableElement()
	'''
	package de.ls5.cinco.transformation.api;

/**
 * Created by zweihoff on 16.06.15.
 */
public interface CIdentifiableElement {
}
	
	'''
	
	def cModelElement()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.ModelElement;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public interface CModelElement extends CIdentifiableElement{

    public void setModelElement(ModelElement modelElement);

    public ModelElement getModelElement();

    @Deprecated
    abstract void update();

    abstract boolean delete();

    public abstract <T extends CGraphModel> T getCRootElement();

    public abstract CModelElementContainer getContainer();

    public abstract void setContainer(CModelElementContainer container);



}
	
	'''
	
	def cModelElementContainer()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.ModelElementContainer;

import java.util.List;

/**
 * Created by zweihoff on 16.06.15.
 */
public interface CModelElementContainer extends CIdentifiableElement{


    public List<CModelElement> getModelElements();

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz);

    public void setModelElements(List<CModelElement> modelElements);

    public void addModelElement(CModelElement cModelElement);

    public List<CNode> getAllCNodes();

    public List<CEdge> getAllCEdges();

    public List<CContainer> getAllCContainers();

    public ModelElementContainer getModelElementContainer();

    public void setModelElementContainer(ModelElementContainer modelElementContainer);


}
	
	'''
	
	def cNode()
	'''
	package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.*;

import java.util.ArrayList;
import java.util.List;

public interface CNode extends CModelElement {

    public List<CEdge> getIncoming();

    public List<CEdge> getOutgoing();

    public List<CNode> getSuccessors();

    public <T extends CNode> List<T> getSuccessors(Class<T> clazz);

    public List<CNode> getPredecessors();

    public <T extends CNode> List<T> getPredecessors(Class<T> clazz);

    public <T extends CEdge> List<T> getIncoming(Class<T> clazz);

    public <T extends CEdge> List<T> getOutgoing(Class<T> clazz);

    public long getX();

    public long getY();

    public long getWidth();

    public long getHeight();

    public void setX(long x);

    public void setY(long y);

    public void setWidth(long width);

    public void setHeight(long height);

    public void moveTo(long x,long y);

    public void resize(long width,long height);

    public void setAngle(double angle);

    public double getAngle();

    public void rotate(double degrees);

    public void setNode(Node node);

    public Node getNode();

    public void setModelElement(ModelElement modelElement);

    public ModelElement getModelElement();

    public void update();

    public boolean delete();
    
    public <T extends CGraphModel> T getCRootElement();


} // CNode
	
	'''
	
	def persistencePom()
	'''
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<parent>
		<groupId>de.mtf.dywa</groupId>
		<artifactId>testapp</artifactId>
		<version>0.1-SNAPSHOT</version>
		<relativePath>../pom.xml</relativePath>
	</parent>

	<artifactId>testapp-persistence</artifactId>
	<packaging>jar</packaging>

	<name>testapp-persistence</name>
	<url>http://maven.apache.org</url>

	<build>
		<resources>
			<resource>
				<directory>src/main/resources</directory>
				<filtering>true</filtering>
			</resource>
		</resources>
		<plugins>
			 	<plugin>
				<groupId>de.mtf.dywa</groupId>
				<artifactId>cinco-preconfig</artifactId>
				<version>${project.version}</version>
				<executions>
					<execution>
						<goals>
							<goal>preconfig</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>properties-maven-plugin</artifactId>
				<version>1.0-alpha-2</version>
				<executions>
					<execution>
						<goals>
							<goal>set-system-properties</goal>
						</goals>
						<configuration>
							<properties>
								<property>
									<name>hibernate.connection.url</name>
									<value>jdbc:postgresql://localhost:5432/dywa${de.ls5.dywa.instanceId}</value>
								</property>
							</properties>
						</configuration>
					</execution>
				</executions>
			</plugin>

			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>build-helper-maven-plugin</artifactId>
				<version>1.8</version>
				<executions>
					<execution>
						<phase>generate-sources</phase>
						<goals>
							<goal>add-source</goal>
						</goals>
						<configuration>
							<sources>
								<source>${project.build.directory}/generated-sources</source>
							</sources>
						</configuration>
					</execution>
				</executions>
			</plugin>

			<plugin>
				<groupId>de.ls5.dywa</groupId>
				<artifactId>domain-generator-plugin</artifactId>
				<version>${de.ls5.dywa.version}</version>
				<executions>
					<execution>
						<goals>
							<goal>generate</goal>
						</goals>
						<phase>generate-resources</phase>
					</execution>
				</executions>
				<configuration>
					<packageName>${de.ls5.dywa.generation.packageName}</packageName>
					<finalArtifactName>${de.mtf.dywa.finalName}${de.ls5.dywa.instanceId}</finalArtifactName>
				</configuration>
				<dependencies>
					<dependency>
						<groupId>de.mtf.dywa</groupId>
						<artifactId>testapp-plugin</artifactId>
						<version>${project.version}</version>
					</dependency>
				</dependencies>
			</plugin>

			<plugin>
				<groupId>com.googlecode.maven-java-formatter-plugin</groupId>
				<artifactId>maven-java-formatter-plugin</artifactId>
				<version>0.4-ls5</version>
				<executions>
					<execution>
						<goals>
							<goal>format</goal>
						</goals>
						<phase>process-resources</phase>
						<configuration>
							<sourceDirectory>${project.build.directory}/generated-sources</sourceDirectory>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>

	<dependencies>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>adapter</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>annotations</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>api</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>entities</artifactId>
			<version>${de.ls5.dywa.version}</version>
		</dependency>
		<dependency>
			<groupId>org.jboss.spec</groupId>
			<artifactId>jboss-javaee-7.0</artifactId>
			<version>1.0.0.Final</version>
			<type>pom</type>
		</dependency>
	</dependencies>

</project>
	
	'''
	
	def preconfigPom()
	'''
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<parent>
		<groupId>de.mtf.dywa</groupId>
		<artifactId>testapp</artifactId>
		<version>0.1-SNAPSHOT</version>
		<relativePath>../pom.xml</relativePath>
	</parent>

	<artifactId>cinco-preconfig</artifactId>
	<packaging>maven-plugin</packaging>

	<name>DyWA ${project.artifactId}</name>

	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-plugin-plugin</artifactId>
				<version>3.3</version>
				<configuration>
					<!-- see http://jira.codehaus.org/browse/MNG-5346 -->
					<skipErrorNoDescriptorsFound>true</skipErrorNoDescriptorsFound>
				</configuration>
				<executions>
					<execution>
						<id>mojo-descriptor</id>
						<goals>
							<goal>descriptor</goal>
						</goals>
						<phase>process-classes</phase>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>

	<dependencies>
		<dependency>
			<groupId>org.apache.maven</groupId>
			<artifactId>maven-plugin-api</artifactId>
			<version>2.0</version>
		</dependency>

		<dependency>
			<groupId>org.apache.maven.plugin-tools</groupId>
			<artifactId>maven-plugin-annotations</artifactId>
			<version>3.3</version>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>entities</artifactId>
			<version>${de.ls5.dywa.version}</version>
		</dependency>

		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>api</artifactId>
			<version>${de.ls5.dywa.version}</version>
		</dependency>

		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>core</artifactId>
			<version>${de.ls5.dywa.version}</version>
		</dependency>

		<dependency>
			<groupId>postgresql</groupId>
			<artifactId>postgresql</artifactId>
			<version>9.1-901.jdbc4</version>
		</dependency>

		<dependency>
			<groupId>org.hibernate</groupId>
			<artifactId>hibernate-entitymanager</artifactId>
			<version>4.2.5.Final</version>
		</dependency>

		<dependency>
			<groupId>org.jboss.weld.se</groupId>
			<artifactId>weld-se-core</artifactId>
			<version>2.2.6.Final</version>
		</dependency>

		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>xadisk</artifactId>
			<version>${de.ls5.dywa.version}</version>
		</dependency>

		<dependency>
			<groupId>javax</groupId>
			<artifactId>javaee-api</artifactId>
			<version>7.0</version>
		</dependency>

		<dependency>
			<groupId>org.apache.deltaspike.cdictrl</groupId>
			<artifactId>deltaspike-cdictrl-api</artifactId>
			<version>1.4.1</version>
		</dependency>
		<dependency>
			<groupId>org.apache.deltaspike.cdictrl</groupId>
			<artifactId>deltaspike-cdictrl-weld</artifactId>
			<version>1.4.1</version>
		</dependency>

	</dependencies>

</project>
	
	'''
	
	def beanProducer()
	'''
	package de.ls5.cinco;

import org.xadisk.connector.outbound.XADiskConnectionFactory;

import javax.annotation.Priority;
import javax.enterprise.context.RequestScoped;
import javax.enterprise.inject.Alternative;
import javax.enterprise.inject.Disposes;
import javax.enterprise.inject.Produces;
import javax.persistence.EntityManager;
import javax.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by pyro cinco meta plugin
 */
@Alternative
@Priority(1)
public class BeanProducer {

	@Produces
	@de.ls5.dywa.core.qualifier.Persistence
	@RequestScoped
	public EntityManager produceEntityManager() {
		final Map<String, String> config = new HashMap<>();

		config.put("hibernate.connection.url", "jdbc:postgresql://localhost:5432/dywa");

		EntityManager em = Persistence.createEntityManagerFactory("pu", config).createEntityManager();
		em.getTransaction().begin();
		return em;
	}

	public void destroyEntityManager(@Disposes @de.ls5.dywa.core.qualifier.Persistence EntityManager em) {
		em.getTransaction().commit();
		em.flush();
		em.close();
	}

	@Produces
	public XADiskConnectionFactory produceConnectionFactory() {
		return null;
	}
}
	
	'''
	
	def generatorMojo()
	'''
	package de.ls5.cinco;

import de.ls5.cinco.deployment.CincoDBController;
import org.apache.deltaspike.cdise.api.CdiContainer;
import org.apache.deltaspike.cdise.api.CdiContainerLoader;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import javax.enterprise.context.spi.CreationalContext;
import javax.enterprise.inject.spi.Bean;
import javax.enterprise.inject.spi.BeanManager;

/**
 * A Maven plugin mojo to generate the domain of the dywa framework.
 */
@Mojo(name = "preconfig", defaultPhase = LifecyclePhase.INITIALIZE)
public class GeneratorMojo extends AbstractMojo {

	@Parameter(defaultValue = "pu", required = true)
	private String persistenceUnit;

	/**
	 * @see org.apache.maven.plugin.AbstractMojo#execute()
	 */
	public void execute() throws MojoExecutionException {

		Log log = getLog();

		CdiContainer cdiContainer = CdiContainerLoader.getCdiContainer();
		cdiContainer.boot();
		cdiContainer.getContextControl().startContexts();

		final BeanManager bmgr = cdiContainer.getBeanManager();
		final Bean<CincoDBController> bean = (Bean<CincoDBController>) bmgr.resolve(bmgr.getBeans(CincoDBController.class));
		final CreationalContext<CincoDBController> cctx = bmgr.createCreationalContext(bean);
		final CincoDBController controller = (CincoDBController) bmgr.getReference(bean, bean.getBeanClass(), cctx);

		controller.removeGraphModelDBTypes();
		controller.createGraphModelDBTypes();

		cdiContainer.getContextControl().stopContexts();
		cdiContainer.shutdown();

		log.info("Successfully imported dump");
	}

}
	
	'''
	
	def preconfigCincoDBController()
	'''
	package de.ls5.cinco.deployment;

/**
 * Created by zweihoff on 23.03.15.
 */
public interface CincoDBController {

    /**
     * Creates all necessary DBTypes for the underlying Cinco GraphModel.ecore and MGL
     */
    public void createGraphModelDBTypes();

    public void removeGraphModelDBTypes();

}
	
	'''
	
	def preconfigBeans()
	'''
	<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="
      http://java.sun.com/xml/ns/javaee 
      http://java.sun.com/xml/ns/javaee/beans_1_0.xsd">

      <alternatives>
            <class>de.ls5.cinco.BeanProducer</class>
      </alternatives>

</beans>
	
	'''
	
	def preconfigPersistence()
	'''
	<?xml version="1.0" encoding="UTF-8"?>
<persistence version="2.0"
			 xmlns="http://java.sun.com/xml/ns/persistence" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			 xsi:schemaLocation="
      http://java.sun.com/xml/ns/persistence
      http://java.sun.com/xml/ns/persistence/persistence_2_0.xsd">

	<persistence-unit name="pu">

		<class>de.ls5.dywa.entities.DBIdentified</class>
		<class>de.ls5.dywa.entities.DBNamed</class>
		<class>de.ls5.dywa.entities.object.DBType</class>
		<class>de.ls5.dywa.entities.object.DBProperties</class>
		<class>de.ls5.dywa.entities.object.DBObject</class>
		<class>de.ls5.dywa.entities.object.DBFile</class>
		<class>de.ls5.dywa.entities.object.DBField</class>
		<class>de.ls5.dywa.entities.property.integrallist.DBStringListProperty</class>
		<class>de.ls5.dywa.entities.property.referencelist.DBObjectListProperty</class>
		<class>de.ls5.dywa.entities.property.DBListProperty</class>
		<class>de.ls5.dywa.entities.property.reference.DBObjectProperty</class>
		<class>de.ls5.dywa.entities.property.DBProperty</class>
		<class>de.ls5.dywa.entities.property.integral.DBLongProperty</class>
		<class>de.ls5.dywa.entities.property.integral.DBStringProperty</class>
		<class>de.ls5.dywa.entities.property.integral.DBDoubleProperty</class>
		<class>de.ls5.dywa.entities.property.integral.DBBooleanProperty</class>
		<class>de.ls5.dywa.entities.property.integral.DBFileProperty</class>
		<class>de.ls5.dywa.entities.property.DBSingularProperty</class>
		<class>de.ls5.dywa.entities.property.PropertyType</class>
		<class>de.ls5.dywa.entities.property.integral.DBTimestampProperty</class>

		<properties>
			<!-- If commented out, the following value must be set as a system property by the domain specific application -->
			<!--<property name="hibernate.connection.url" value="jdbc:postgresql:dywa" />-->
			<property name="hibernate.connection.username" value="sa"/>
			<property name="hibernate.connection.password" value="sa"/>
			<property name="hibernate.connection.driver_class" value="org.postgresql.Driver"/>

			<property name="hibernate.hbm2ddl.auto" value="update"/>

			<property name="hibernate.jdbc.fetch_size" value="64"/>
			<property name="hibernate.jdbc.batch_size" value="64"/>
			<property name="hibernate.default_batch_fetch_size" value="64"/>

			<property name="hibernate.dialect"
					  value="de.ls5.commons.hibernate.dialects.UnlimitedPostgreSQLDialect"/>
			<property name="hibernate.generate_statistics" value="false"/>
		</properties>
	</persistence-unit>
</persistence>
	'''
	
	def preconfigLog4J()
	'''
	log4j.rootLogger=WARN, CONSOLE

log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d %-5p [%t] %-17c{2} (%13F:%L) %3x - %m%n
	'''
	
	def presentationPom()
	'''
	<?xml version="1.0" encoding="UTF-8"?>
<project
		xmlns="http://maven.apache.org/POM/4.0.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<parent>
		<groupId>de.mtf.dywa</groupId>
		<artifactId>testapp</artifactId>
		<version>0.1-SNAPSHOT</version>
		<relativePath>../pom.xml</relativePath>
	</parent>

	<artifactId>testapp-presentation</artifactId>
	<packaging>war</packaging>
	<name>testapp-presentation Tapestry 5 Application</name>

	<properties>
		<tapestry-release-version>5.3.8</tapestry-release-version>
	</properties>

	<dependencies>
		<dependency>
			<groupId>org.apache.tapestry</groupId>
			<artifactId>tapestry-core</artifactId>
			<version>${tapestry-release-version}</version>
		</dependency>

		<dependency>
			<groupId>de.mtf.dywa</groupId>
			<artifactId>testapp-business</artifactId>
			<version>${project.version}</version>
		</dependency>

		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-core</artifactId>
			<version>1.2.3</version>
		</dependency>
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-web</artifactId>
			<version>1.2.3</version>
		</dependency>

		<dependency>
			<groupId>org.tynamo</groupId>
			<artifactId>tapestry-security</artifactId>
			<version>0.6.2</version>
		</dependency>

		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>api</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>

		<!-- explicitly declare dependency provided so it's not packaged -->
		<dependency>
			<groupId>de.ls5.dywa</groupId>
			<artifactId>entities</artifactId>
			<version>${de.ls5.dywa.version}</version>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>org.jboss.spec</groupId>
			<artifactId>jboss-javaee-7.0</artifactId>
			<type>pom</type>
			<version>1.0.0.Final</version>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>org.jboss</groupId>
			<artifactId>jboss-vfs</artifactId>
			<version>3.0.1.GA</version>
			<scope>provided</scope>
		</dependency>
	</dependencies>

	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-war-plugin</artifactId>
				<version>2.4</version>
				<configuration>
					<webResources>
						<resource>
							<directory>src/main/webapp/WEB-INF</directory>
							<targetPath>WEB-INF</targetPath>
							<filtering>true</filtering>
						</resource>
					</webResources>
				</configuration>
			</plugin>
		</plugins>
		<finalName>${de.mtf.dywa.finalName}${de.ls5.dywa.instanceId}</finalName>
	</build>
</project>

	
	'''
}