package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.lang.reflect.Method;


public class Descriptor<T> {

	
	public Descriptor(T obj) {
		this.obj = obj;
		try {
			Method getter = obj.getClass().getMethod("getName");
			getter.setAccessible(true);
			setName(getter.invoke(obj).toString());
			setAcronym(getName().toLowerCase());
		} catch(Exception e) {}
	}
	
	private T obj;
	public T instance() {
		return obj;
	}
	
	private String acronym;
	public String getAcronym() {
		return acronym;
	}
	public Descriptor<T> setAcronym(String acronym) {
		this.acronym = acronym;
		return this;
	}
	
	private String dir;
	public String getDir() {
		return dir;
	}
	public Descriptor<T> setDir(String dir) {
		this.dir = dir;
		return this;
	}
	
	private String basePkg;
	public String getBasePackage() {
		return basePkg;
	}
	public Descriptor<T> setBasePackage(String pkg) {
		this.basePkg = pkg;
		setBasePackageDir(pkg.replace(".","/"));
		return this;
	}
	
	private String basePkgDir;
	public String getBasePackageDir() {
		return basePkgDir;
	}
	private Descriptor<T> setBasePackageDir(String pkgDir) {
		this.basePkgDir = pkgDir;
		return this;
	}
	
	
	private String name;
	public String getName() {
		return name;
	}
	public Descriptor<T> setName(String name) {
		this.name = name;
		return this;
	}
	
}
