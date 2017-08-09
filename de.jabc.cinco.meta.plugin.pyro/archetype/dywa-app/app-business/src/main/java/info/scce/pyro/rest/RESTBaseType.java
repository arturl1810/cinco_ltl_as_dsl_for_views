package info.scce.pyro.rest;

import com.fasterxml.jackson.annotation.JsonProperty;
import info.scce.pyro.util.Constants;

public interface RESTBaseType {

	@JsonProperty(Constants.DYWA_ID)
	long getDywaId();

	@JsonProperty(Constants.DYWA_ID)
	void setDywaId(final long id);

	@JsonProperty(Constants.DYWA_VERSION)
	long getDywaVersion();

	@JsonProperty(Constants.DYWA_VERSION)
	void setDywaVersion(final long version);

	@JsonProperty(Constants.DYWA_NAME)
	String getDywaName();

	@JsonProperty(Constants.DYWA_NAME)
	void setDywaName(final String name);

}
