package info.scce.pyro.rest;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.ser.impl.SimpleFilterProvider;

import javax.ws.rs.ext.ContextResolver;
import javax.ws.rs.ext.Provider;

/**
 * Created by frohme on 12.11.15.
 */
@Provider
public class JacksonProvider implements ContextResolver<ObjectMapper> {

	final ObjectMapper mapper;

	public JacksonProvider() {
		mapper = new ObjectMapper();
		mapper.findAndRegisterModules();

		mapper.enable(SerializationFeature.INDENT_OUTPUT);
		mapper.enable(MapperFeature.SORT_PROPERTIES_ALPHABETICALLY);

		mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
		mapper.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
		mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

		mapper.setFilterProvider(new SimpleFilterProvider().addFilter("DIME_Selective_Filter", new PyroSelectiveRestFilter()));
//		mapper.setFilterProvider(new SimpleFilterProvider().addFilter("DIME_Selective_Filter", new MyDummyFilter()));
	}

	@Override
	public ObjectMapper getContext(Class<?> type) {
		return mapper;
	}

}