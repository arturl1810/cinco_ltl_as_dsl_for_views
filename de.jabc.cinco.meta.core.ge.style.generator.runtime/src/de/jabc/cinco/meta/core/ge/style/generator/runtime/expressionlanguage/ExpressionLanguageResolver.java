package de.jabc.cinco.meta.core.ge.style.generator.runtime.expressionlanguage;

import java.util.Iterator;

import javax.el.BeanELResolver;
import javax.el.ELContext;
import javax.el.ELResolver;

public class ExpressionLanguageResolver extends ELResolver{

	private ELResolver delegate = new BeanELResolver();
	private Object o;
	
	public ExpressionLanguageResolver(Object o) {
		this.o = o;
	}
	
	@Override
	public Class<?> getCommonPropertyType(ELContext arg0, Object base) {
		if (base == null) {
			base = o;
		}
		return delegate.getCommonPropertyType(arg0, base);
	}

	@Override
	public Iterator<java.beans.FeatureDescriptor> getFeatureDescriptors(ELContext arg0, Object base) {
		if (base == null)
			base = o;
		
		return delegate.getFeatureDescriptors(arg0, base);
	}

	@Override
	public Class<?> getType(ELContext arg0, Object base, Object arg2) {
		if (base == null)
			base = o;
		return delegate.getType(arg0, base, arg2);
	}

	@Override
	public Object getValue(ELContext arg0, Object base, Object arg2) {
		if (base == null)
			base = o;
		return delegate.getValue(arg0, base, arg2);
	}

	@Override
	public boolean isReadOnly(ELContext arg0, Object base, Object arg2) {
		if (base == null) {
			base = o;
		}
		return delegate.isReadOnly(arg0, base, arg2);
	}

	@Override
	public void setValue(ELContext arg0, Object base, Object arg2, Object arg3) {
		if (base == null)
			base = o;
		delegate.setValue(arg0, base, arg2, arg3);
		
	}
}
