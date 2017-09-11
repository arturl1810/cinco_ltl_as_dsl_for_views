package info.scce.pyro.util;

import de.ls5.dywa.adapter.generator.BranchAdapter;
import de.ls5.dywa.adapter.generator.ParameterAdapter;
import de.ls5.dywa.adapter.generator.ProcessAdapter;
import de.ls5.dywa.entities.property.PropertyType;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by neubauer on 18.11.15.
 */
public class ProcessAdapterBuilder {

	private ProcessAdapter descriptor;

	public ProcessAdapterBuilder(String id, String name, String pkg, String description) {

		descriptor = new ProcessAdapter() {

			private List<ParameterAdapter> parameters = new ArrayList<>();

			private List<BranchAdapter> branches = new ArrayList<>();

			@Override
			public String getId() {
				return id;
			}

			@Override
			public String getName() {
				return name;
			}

			@Override
			public String getPackage() {
				return pkg;
			}

			@Override
			public String getDescription() {
				return description;
			}

			@Override
			public List<ParameterAdapter> getInputs() {
				return parameters;
			}

			@Override
			public List<BranchAdapter> getBranches() {
				return branches;
			}
		};
	}

	public ParameterAdapter addParameterAdapter(String name,
												String description,
												PropertyType propertyType,
												String packageName,
												String typeName) {

		final ParameterAdapter parameterDescriptor =
				buildParameterAdapter(name, description, propertyType, packageName, typeName);
		descriptor.getInputs().add(parameterDescriptor);

		return parameterDescriptor;
	}

	public ParameterAdapter buildParameterAdapter(String name,
												  String description,
												  PropertyType propertyType,
												  String packageName,
												  String typeName) {

		return new ParameterAdapter() {

			@Override
			public String getName() {
				return name;
			}

			@Override
			public String getDescription() {
				return description;
			}

			@Override
			public PropertyType getPropertyType() {
				return propertyType;
			}

			@Override
			public String getPackageName() {
				return packageName;
			}

			@Override
			public String getTypeName() {
				return typeName;
			}
		};
	}

	public BranchAdapter addBranchAdapter(String name, String description) {

		final BranchAdapter branchDescriptor = new BranchAdapter() {

			private List<ParameterAdapter> parameterDescriptors = new ArrayList<>();

			@Override
			public String getName() {
				return name;
			}

			@Override
			public String getDescription() {
				return description;
			}

			@Override
			public List<ParameterAdapter> getOutputs() {
				return parameterDescriptors;
			}
		};

		descriptor.getBranches().add(branchDescriptor);
		return branchDescriptor;
	}

	public ProcessAdapter build() {
		return this.descriptor;
	}
}
