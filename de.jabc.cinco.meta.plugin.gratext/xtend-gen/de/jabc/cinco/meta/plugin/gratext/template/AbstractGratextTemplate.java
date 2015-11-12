package de.jabc.cinco.meta.plugin.gratext.template;

import com.google.common.base.Objects;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.GratextProjectGenerator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.FileDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.GratextEcoreTemplate;
import java.util.ArrayList;
import mgl.GraphModel;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.GenRuntimeVersion;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class AbstractGratextTemplate {
  protected GratextProjectGenerator ctx;
  
  public ProjectDescriptor project() {
    return this.ctx.getProjectDescriptor();
  }
  
  public GraphModelDescriptor model() {
    return this.ctx.getModelDescriptor();
  }
  
  public GraphModel graphmodel() {
    GraphModelDescriptor _model = this.model();
    return _model.instance();
  }
  
  public IProject modelProject() {
    IResource _modelProjectResource = this.modelProjectResource();
    return _modelProjectResource.getProject();
  }
  
  public IResource modelProjectResource() {
    GraphModel _graphmodel = this.graphmodel();
    Resource _eResource = _graphmodel.eResource();
    URI _uRI = _eResource.getURI();
    return this.platformResource(_uRI);
  }
  
  public String modelProjectSymbolicName() {
    String _xifexpression = null;
    IResource _modelProjectResource = this.modelProjectResource();
    boolean _notEquals = (!Objects.equal(_modelProjectResource, null));
    if (_notEquals) {
      IResource _modelProjectResource_1 = this.modelProjectResource();
      IProject _project = _modelProjectResource_1.getProject();
      _xifexpression = this.symbolicName(_project);
    } else {
      GraphModel _graphmodel = this.graphmodel();
      _xifexpression = _graphmodel.getPackage();
    }
    return _xifexpression;
  }
  
  public FileDescriptor fileFromTemplate(final Class<?> templateClass) {
    return this.ctx.getFileDescriptor(templateClass);
  }
  
  public String create(final GratextProjectGenerator generator) {
    String _xblockexpression = null;
    {
      this.ctx = generator;
      CharSequence _template = this.template();
      _xblockexpression = _template.toString();
    }
    return _xblockexpression;
  }
  
  public IResource platformResource(final URI uri) {
    IWorkspace _workspace = ResourcesPlugin.getWorkspace();
    IWorkspaceRoot _root = _workspace.getRoot();
    String _platformString = uri.toPlatformString(true);
    Path _path = new Path(_platformString);
    return _root.findMember(_path);
  }
  
  public String symbolicName(final IProject project) {
    String _xifexpression = null;
    boolean _notEquals = (!Objects.equal(project, null));
    if (_notEquals) {
      _xifexpression = ProjectCreator.getProjectSymbolicName(project);
    }
    return _xifexpression;
  }
  
  public void debug(final String msg) {
    Class<? extends AbstractGratextTemplate> _class = this.getClass();
    String _simpleName = _class.getSimpleName();
    String _plus = ("[" + _simpleName);
    String _plus_1 = (_plus + "] ");
    String _plus_2 = (_plus_1 + msg);
    System.out.println(_plus_2);
  }
  
  public CharSequence template() {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  public GenModel createGenModel() {
    ProjectDescriptor _project = this.project();
    IProject _instance = _project.instance();
    FileDescriptor _fileFromTemplate = this.fileFromTemplate(GratextEcoreTemplate.class);
    IFile _resource = _fileFromTemplate.resource();
    IPath _fullPath = _resource.getFullPath();
    IFile _file = _instance.getFile(_fullPath);
    final IPath ecorePath = _file.getProjectRelativePath();
    ProjectDescriptor _project_1 = this.project();
    final String projectID = _project_1.getSymbolicName();
    ProjectDescriptor _project_2 = this.project();
    String _symbolicName = _project_2.getSymbolicName();
    final Path projectPath = new Path(_symbolicName);
    IPath _removeFileExtension = ecorePath.removeFileExtension();
    final IPath genModelPath = _removeFileExtension.addFileExtension("genmodel");
    String _string = genModelPath.toString();
    final URI genModelURI = URI.createURI(_string);
    Resource.Factory _factory = Resource.Factory.Registry.INSTANCE.getFactory(genModelURI);
    final Resource genModelResource = _factory.createResource(genModelURI);
    final GenModel genModel = GenModelFactory.eINSTANCE.createGenModel();
    EList<EObject> _contents = genModelResource.getContents();
    _contents.add(genModel);
    IPath _append = projectPath.append("src-gen");
    String _portableString = _append.toPortableString();
    String _plus = ("/" + _portableString);
    genModel.setModelDirectory(_plus);
    FileDescriptor _fileFromTemplate_1 = this.fileFromTemplate(GratextEcoreTemplate.class);
    IFile _resource_1 = _fileFromTemplate_1.resource();
    final IPath ecoreFullPath = _resource_1.getFullPath();
    this.debug(("Ecore path: " + ecoreFullPath));
    String _oSString = ecoreFullPath.toOSString();
    final EPackage ePackage = EcoreUtil2.getEPackage(_oSString);
    final ArrayList<EPackage> ePackageList = new ArrayList<EPackage>();
    ePackageList.add(ePackage);
    genModel.initialize(ePackageList);
    EList<GenPackage> _genPackages = genModel.getGenPackages();
    GenPackage _get = _genPackages.get(0);
    final GenPackage genPackage = ((GenPackage) _get);
    URI _trimFileExtension = genModelURI.trimFileExtension();
    String _lastSegment = _trimFileExtension.lastSegment();
    genModel.setModelName(_lastSegment);
    URI _trimFileExtension_1 = genModelURI.trimFileExtension();
    String _lastSegment_1 = _trimFileExtension_1.lastSegment();
    genPackage.setPrefix(_lastSegment_1);
    GraphModelDescriptor _model = this.model();
    String _basePackage = _model.getBasePackage();
    genPackage.setBasePackage(_basePackage);
    genModel.setRuntimeVersion(GenRuntimeVersion.EMF210);
    genModel.setComplianceLevel(GenJDKLevel.JDK80_LITERAL);
    genModel.setModelPluginID(projectID);
    genModel.setEditPluginID((projectID + ".edit"));
    genModel.setEditorPluginID((projectID + ".editor"));
    genModel.setTestsPluginID((projectID + ".tests"));
    genModel.setCanGenerate(true);
    return genModel;
  }
  
  public IPath workspaceRoot() {
    IWorkspace _workspace = ResourcesPlugin.getWorkspace();
    IWorkspaceRoot _root = _workspace.getRoot();
    return _root.getFullPath();
  }
  
  public IFile findFile(final IPath path) {
    IWorkspace _workspace = ResourcesPlugin.getWorkspace();
    IWorkspaceRoot _root = _workspace.getRoot();
    IFile[] _findFilesForLocation = _root.findFilesForLocation(path);
    return _findFilesForLocation[0];
  }
}
