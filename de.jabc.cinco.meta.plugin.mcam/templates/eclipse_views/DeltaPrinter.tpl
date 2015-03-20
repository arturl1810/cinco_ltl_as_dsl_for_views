package ${ViewPackage}.util;

import org.eclipse.core.resources.IMarkerDelta;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;

public class DeltaPrinter implements IResourceDeltaVisitor {
	public boolean visit(IResourceDelta delta) {
		IResource res = delta.getResource();
		switch (delta.getKind()) {
		case IResourceDelta.ADDED:
			System.out.print("Resource ");
			System.out.print(res.getFullPath());
			System.out.println(" was added.");
			break;
		case IResourceDelta.REMOVED:
			System.out.print("Resource ");
			System.out.print(res.getFullPath());
			System.out.println(" was removed.");
			break;
		case IResourceDelta.CHANGED:
			System.out.print("Resource ");
		      System.out.print(delta.getFullPath());
		      System.out.println(" has changed.");
		      int flags = delta.getFlags();
		      if ((flags & IResourceDelta.CONTENT) != 0) {
		            System.out.println("--> Content Change");
		      }
		      if ((flags & IResourceDelta.REPLACED) != 0) {
		            System.out.println("--> Content Replaced");
		      }
		      if ((flags & IResourceDelta.MARKERS) != 0) {
		            System.out.println("--> Marker Change");
		            IMarkerDelta[] markers = delta.getMarkerDeltas();
		            // if interested in markers, check these deltas
		      }
		      break;
		}
		return true; // visit the children
	}
}
