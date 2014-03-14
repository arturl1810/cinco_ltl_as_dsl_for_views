package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.sib.SIB;
import de.metaframe.jabc.framework.sib.SIBUtilities;
import de.metaframe.jabc.framework.sib.util.ServiceAdapterCache;
import de.metaframe.jabc.sib.Executable;
import de.metaframe.jabc.sib.Generatable;
import de.metaframe.jabc.sib.LocalCheck;
import de.metaframe.jabc.sib.PlatformGeneratable;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

public class AbstractSIB implements Executable, Generatable,
PlatformGeneratable, LocalCheck{

	private static class ServiceAdapters {
		public static final ServiceAdapterCache SERVICE_ADAPTER_CACHE = new ServiceAdapterCache(AbstractSIB.class);
	}
	
	@Override
	public ServiceAdapterDescriptor getServiceAdapterDescriptor(String arg0) {
		return ServiceAdapters.SERVICE_ADAPTER_CACHE.getServiceAdapterDescriptor(this, arg0);
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String trace(ExecutionEnvironment arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void checkSIB(SIB arg0) {
		SIBUtilities.execute(StandardCheck.MISSING_TARGETS.getKey(), arg0);
		SIBUtilities.execute(StandardCheck.UNASSIGNED_BRANCHES.getKey(), arg0);
		SIBUtilities.execute(StandardCheck.MISSING_SOURCES.getKey(), arg0);
		SIBUtilities.execute(StandardCheck.MISSING_BRANCH_LABELS.getKey(), arg0);
	}

	@Override
	public Object type() {
		// TODO Auto-generated method stub
		return null;
	}

}
