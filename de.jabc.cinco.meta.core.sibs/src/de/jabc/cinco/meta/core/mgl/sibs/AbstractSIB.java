package de.jabc.cinco.meta.core.mgl.sibs;

import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.sib.DocType;
import de.metaframe.jabc.framework.sib.SIB;
import de.metaframe.jabc.framework.sib.SIBUtilities;
import de.metaframe.jabc.framework.sib.util.Documentation;
import de.metaframe.jabc.framework.sib.util.IconCache;
import de.metaframe.jabc.framework.sib.util.ServiceAdapterCache;
import de.metaframe.jabc.sib.Executable;
import de.metaframe.jabc.sib.Generatable;
import de.metaframe.jabc.sib.LocalCheck;
import de.metaframe.jabc.sib.PlatformGeneratable;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;
import de.metaframe.jabc.sib.LocalCheck.StandardCheck;
import de.metaframe.jabc.framework.sib.SIBMetaInfo;


public abstract class AbstractSIB implements SIBMetaInfo,Executable, Generatable,
		PlatformGeneratable,LocalCheck{
	
	private static class ServiceAdapters{
		public static final ServiceAdapterCache SERVICE_ADAPTER_CACHE = new ServiceAdapterCache(AbstractSIB.class); 
	}

	/**
	 * This class holds the icon cache instance. Keeping this instance in a
	 * separate class allows for thread-safe lazy initialization of the cache.
	 * Remember, we do not need icons when running in headless mode.
	 */
	protected static class Icons {

		/**
		 * The icon cache used to load icons for this SIB library.
		 */
		public static final IconCache INSTANCE = new IconCache(AbstractSIB.class);

	}

	/**
	 * This class holds the documentation instance. Keeping this instance in a
	 * separate class allows for thread-safe lazy initialization of the
	 * documentation. Remember, we do not need resource bundles when running in
	 * headless mode.
	 */
	protected static class Strings {

		/**
		 * The bundle used to load documentation strings for this SIB library.
		 */
		public static final Documentation INSTANCE = new Documentation(AbstractSIB.class);

	}

	

	@Override
	public ServiceAdapterDescriptor getServiceAdapterDescriptor(String platform) {
		return ServiceAdapters.SERVICE_ADAPTER_CACHE.getServiceAdapterDescriptor(this, platform);
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
		SIBUtilities.execute(StandardCheck.MISSING_TARGETS.getKey(),arg0);
		SIBUtilities.execute(StandardCheck.UNASSIGNED_BRANCHES.getKey(), arg0);
		SIBUtilities.execute(StandardCheck.MISSING_BRANCH_LABELS.getKey(), arg0);
		SIBUtilities.execute(StandardCheck.MISSING_SOURCES.getKey(),arg0);
		
		
	}

	@Override
	public Object type() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getIcon() {
		if(!"icon".equals("")){
			return Icons.INSTANCE.get("icon");
		}else{
			return null;
		}
	}
	/**
	 * @see de.metaframe.jabc.framework.sib.SIBMetaInfo#getDocumentation(DocType,
	 *      String)
	 */
	public String getDocumentation(DocType type, String param) {
		return "";
	}

}
