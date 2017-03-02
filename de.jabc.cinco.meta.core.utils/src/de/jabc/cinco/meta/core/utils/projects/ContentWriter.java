package de.jabc.cinco.meta.core.utils.projects;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaCore;

public class ContentWriter {

	private final static String PLUGIN_FRAME = "<?xml version=\"1.0\" encoding=\""+System.getProperty("file.encoding")+"\"?>\n"
			+ "<?eclipse version=\"3.0\"?>\n"
			+ "<plugin>\n"
			+ "</plugin>";
	
	public static void writeJavaFileInSrcGen(IProject p, CharSequence packageName, String fileName, CharSequence content) {
		writeJavaFile(p, "src-gen", packageName.toString(), fileName, content.toString());
	}
	
	public static void writeJavaFileInSrcGen(IProject p, String packageName, String fileName, CharSequence content) {
		writeJavaFile(p, "src-gen", packageName, fileName, content.toString());
	}
	
	public static void writeJavaFileInSrcGen(IProject p, String packageName, String fileName, String content) {
		writeJavaFile(p, "src-gen", packageName, fileName, content);
	}
	
	public static void writeJavaFile(IProject p, String folderName, String packageName,	String fileName, String content) {
		
		NullProgressMonitor monitor = new NullProgressMonitor();
		
		IFolder folder = p.getFolder(folderName);
		try {
			if (!folder.exists()) {
				folder.create(true, true, monitor);
			}
			IJavaProject javaProject = JavaCore.create(p);
			IPackageFragmentRoot packageFragmentRoot = javaProject.getPackageFragmentRoot(folder);
				
			IPackageFragment pack = packageFragmentRoot.createPackageFragment(packageName, true, monitor);
			pack.createCompilationUnit(fileName, content.toString(), false, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}

	public static void writeFile(IProject p, String folderName, CharSequence packageName,	String fileName, CharSequence content) {
		
		NullProgressMonitor monitor = new NullProgressMonitor();
		
		IFolder folder = p.getFolder(folderName);
		IFolder packageFolder = null;
		try {
			if (!folder.exists()) {
				folder.create(true, true, monitor);
			}
			packageFolder = folder.getFolder(new Path(packageName.toString().replaceAll("\\.", "/")));
			if (!packageFolder.exists())
				packageFolder.create(true, true, monitor);
			IFile f = packageFolder.getFile(fileName);
			File file = f.getLocation().toFile();
			FileWriter fw = new FileWriter(file);
			fw.write(content.toString());
			fw.close();
		} catch (CoreException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public static void writePluginXML(IProject project, CharSequence content) {
		writePluginXML(project, content.toString());
	}
	
	public static void writePluginXML(IProject project, String content) {
		IPath fileLocation = project.getLocation().append("plugin.xml");
		File f = fileLocation.toFile();
		if (f == null)
			f = new File(fileLocation.toOSString());
		try {
			if (!f.exists())
				f.createNewFile();
			writePluginFrame(f);
			String fileContents = content;
			FileWriter fw = new FileWriter(f);
			fw.write(fileContents);
			fw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void writePluginXML(IProject project, List<CharSequence> extensions) {
		IPath fileLocation = project.getLocation().append("plugin.xml");
		File f = fileLocation.toFile();
		if (f == null)
			f = new File(fileLocation.toOSString());
		try {
			if (!f.exists())
				f.createNewFile();
			writePluginFrame(f);
			String fileContents = getFileContents(f);
			Collections.reverse(extensions);
			for (CharSequence cs : extensions)
				fileContents = writeToFileContent(cs,fileContents);
			FileWriter fw = new FileWriter(f);
			fw.write(fileContents);
			fw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	

	private static String writeToFileContent(CharSequence ext, String content) {
		if (content.contains(ext))
			return content.replace(content, ext);
		else return insertToContent(ext,content); 
	}
	
	private static String insertToContent(CharSequence ext, String content) {
		int indexOf = content.indexOf("<plugin>");
		StringBuilder sb = new StringBuilder(content);
		sb.insert(indexOf+"<plugin>".length(), ext.toString());
		return sb.toString();
	}

	public static String getFileContents(File pluginXMLFile) throws IOException {
		BufferedReader reader = new BufferedReader(new FileReader(pluginXMLFile));
		String line;
		String content = new String();
		while ((line = reader.readLine()) != null) {
			content += line;
		}
		reader.close();
		return content;
	}
	
	private static void writePluginFrame(File f) throws IOException {
		BufferedWriter bw = new BufferedWriter(new FileWriter(f));
		bw.write(PLUGIN_FRAME);
		bw.close();
	}
	
}
