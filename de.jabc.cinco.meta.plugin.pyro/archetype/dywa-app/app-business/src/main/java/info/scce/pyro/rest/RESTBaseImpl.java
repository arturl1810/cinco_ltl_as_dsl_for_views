package info.scce.pyro.rest;

import com.fasterxml.jackson.annotation.JsonProperty;
import info.scce.pyro.util.Constants;
import org.apache.commons.lang3.builder.HashCodeBuilder;

public class RESTBaseImpl implements RESTBaseType {

	private long dywaId;
	private long dywaVersion;
	private String dywaName;
	private String dywaRuntimeType;

	@JsonProperty(Constants.DYWA_ID)
	public long getDywaId() {
		return this.dywaId;
	}

	@JsonProperty(Constants.DYWA_ID)
	public void setDywaId(final long id) {
		this.dywaId = id;
	}

	@JsonProperty(Constants.DYWA_VERSION)
	public long getDywaVersion() {
		return this.dywaVersion;
	}

	@JsonProperty(Constants.DYWA_VERSION)
	public void setDywaVersion(final long version) {
		this.dywaVersion = version;
	}

	@JsonProperty(Constants.DYWA_NAME)
	public String getDywaName() {
		return this.dywaName;
	}

	@JsonProperty(Constants.DYWA_NAME)
	public void setDywaName(final String name) {
		this.dywaName = name;
	}

	@Override
	public int hashCode() {
		return new HashCodeBuilder().append(this.getDywaId()).toHashCode();
	}

	@Override
	public boolean equals(final Object obj) {
		if (this == obj) {
			return true;
		}

		if (!(getClass().isInstance(obj))) {
			return false;
		}

		final RESTBaseType that = (RESTBaseType) obj;
		if (this.getDywaId() >= 0 && that.getDywaId() >= 0) {
			return this.getDywaId() == that.getDywaId();
		}

		return false;
	}

}
