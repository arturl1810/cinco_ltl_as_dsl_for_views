package de.jabc.cinco.meta.runtime.active

import de.jabc.cinco.meta.util.xapi.CollectionExtension
import java.util.List
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicReference
import java.util.stream.Stream
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.jooq.lambda.Collectable

import static extension java.util.Optional.*
import static extension org.jooq.lambda.Seq.*

@Active(MemoizeProcessor)
annotation Memoizable {
	int expectedSize = 666;
}

class MemoizeProcessor implements TransformationParticipant<MutableMethodDeclaration> {
	override doTransform(List<? extends MutableMethodDeclaration> methods, TransformationContext context) {
		methods.forEach [ it, index |
			switch (parameters.size) {
				case 0: new ParameterlessMethodMemoizer(it, context, index).generate
				case 1: new SingleParameterMethodMemoizer(it, context, index).generate
				default: new MultipleParameterMethodMemoizer(it, context, index).generate
			}
		]
	}
}

class ParameterlessMethodMemoizer extends MethodMemoizer {

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}
	
	override cacheFieldType() {
    	AtomicReference.newTypeReference(
    		if (method.typeParameters.empty) wrappedReturnType else Object.newTypeReference
    	)
  	}

	override cacheFieldInit(CompilationContext context) '''new AtomicReference<>()'''
	
	override cacheCall(extension CompilationContext context) '''
		
		if («cacheFieldName».get() == null) {
			// we have a cache miss, so calculate the value, and ...
			// [do the heavy work outside the critical section.]
			final «wrappedReturnType.toJavaCode» cacheValue = «initMethodName»();
			// ... replace the existing value, iff it has not been set concurrently.
			«cacheFieldName».compareAndSet(null, cacheValue);
		}
		
		final «wrappedReturnType.toJavaCode» result = «IF !method.typeParameters.empty»(«wrappedReturnType.toJavaCode»)«ENDIF»«cacheFieldName».get();
		
		«val typeArgument = wrappedReturnType.actualTypeArguments.head»
		«IF Stream.newTypeReference.isAssignableFrom(wrappedReturnType)»
			// for lazy iterations use the duplicate feature of Jooq.
			final org.jooq.lambda.tuple.Tuple2<Seq<«typeArgument.toJavaCode»>, Seq<«typeArgument.toJavaCode»>> cacheValueDupe = 
				org.jooq.lambda.Seq.seq(result).duplicate();
			«cacheFieldName».set(cacheValueDupe.v1);
			return cacheValueDupe.v2;
		«ELSEIF 	(typeArgument != null && 
					(
						Iterable.newTypeReference(typeArgument).isSameType(wrappedReturnType) ||
						Collectable.newTypeReference(typeArgument).isSameType(wrappedReturnType)
					)
				)»
			if (!(result instanceof java.util.stream.Stream)) {
				// for non-lazy return types, return the cached value.
				return result;
			}
			else {
				// for lazy iterations use the duplicate feature of Jooq.
				final org.jooq.lambda.tuple.Tuple2<Seq<«typeArgument.toJavaCode»>, Seq<«typeArgument.toJavaCode»>> cacheValueDupe = 
					org.jooq.lambda.Seq.seq(result).duplicate();
				«cacheFieldName».set(cacheValueDupe.v1);
				return cacheValueDupe.v2;
			}
		«ELSE»
			// for non-lazy return types, return the cached value.
			return result;
		«ENDIF»
	'''
	
}

class MultipleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override parametersToCacheKey() '''
		java.util.Arrays.asList(«method.parameters.join("", ",", "")[ simpleName ]»);
	'''
}

class SingleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override parametersToCacheKey() {
		method.parameters.head.simpleName
	}
}

/**
 * Parent type of all method memoizers with parameters
 */
abstract class ParametrizedMethodMemoizer extends MethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}
	
	final override cacheFieldType() {
		Map.newTypeReference(
			Object.newTypeReference,
			if (method.typeParameters.empty) wrappedReturnType else Object.newTypeReference
		)
	}

	final override cacheFieldInit(extension CompilationContext context) '''
		new «ConcurrentHashMap.newTypeReference(
			Object.newTypeReference,
			if (method.typeParameters.empty) wrappedReturnType else Object.newTypeReference
		).toJavaCode»((int)(«expectedSize»*1.5))
	'''
	
	def getExpectedSize() {
		method.findAnnotation(Memoizable.findTypeGlobally).getIntValue("expectedSize")
	}

	final override cacheCall(extension CompilationContext context) '''
		final Object cacheKey = «parametersToCacheKey»;
		final «wrappedReturnType.toJavaCode» result;
		if (!«cacheFieldName».containsKey(cacheKey)) {
			// we have a cache miss. hence we call the initializer method...
			// [do the heavy work outside the critical section.]
			final «wrappedReturnType.toJavaCode» cacheValue = «initMethodName»(«initMethodParameters»);
			
			// ... and store the result for future calls, iff it has not been set, concurrently.
			result = «IF !method.typeParameters.empty»(«wrappedReturnType.toJavaCode»)«ENDIF»«cacheFieldName».computeIfAbsent(cacheKey, (k) -> cacheValue);
		}
		else {
			// we have a cache hit.
			result = «IF !method.typeParameters.empty»(«wrappedReturnType.toJavaCode»)«ENDIF»«cacheFieldName».get(cacheKey);
		}
		«val typeArgument = wrappedReturnType.actualTypeArguments.head»
		«IF Stream.newTypeReference.isAssignableFrom(wrappedReturnType)»
			// for lazy iterations use the duplicate feature of Jooq.
			final org.jooq.lambda.tuple.Tuple2<
				org.jooq.lambda.Seq<«typeArgument.toJavaCode»>, 
				org.jooq.lambda.Seq<«typeArgument.toJavaCode»>
			> cacheValueDupe = 
				org.jooq.lambda.Seq.seq(result).duplicate();
			«cacheFieldName».put(cacheKey, cacheValueDupe.v1);
			return cacheValueDupe.v2;
		«ELSEIF 	(typeArgument != null && 
					(
						Iterable.newTypeReference(typeArgument).isSameType(wrappedReturnType) ||
						Collectable.newTypeReference(typeArgument).isSameType(wrappedReturnType)
					)
				)»
			if (!(result instanceof java.util.stream.Stream)) {
				// for non-lazy return types, return the cached value.
				return result;
			}
			else {
				// for lazy iterations use the duplicate feature of Jooq.
				final org.jooq.lambda.tuple.Tuple2<
					org.jooq.lambda.Seq<«typeArgument.toJavaCode»>, 
					org.jooq.lambda.Seq<«typeArgument.toJavaCode»>
				> cacheValueDupe = 
					org.jooq.lambda.Seq.seq(result).duplicate();
				«cacheFieldName».put(cacheKey, cacheValueDupe.v1);
				return cacheValueDupe.v2;
			}
		«ELSE»
			// for non-lazy return types, return the cached value.
			return result;
		«ENDIF»
	'''

	/**
	 * Defines how a cache key object is created from method parameters.
	 */
	protected def CharSequence parametersToCacheKey()
	
	private def CharSequence initMethodParameters() {
		(method.parameters).join("", ",", "") [ simpleName ]
	}
}

/**
 * Parent type of all method memoizers.
 */
abstract class MethodMemoizer {

	protected val extension CollectionExtension = new CollectionExtension
	protected val extension TransformationContext context
	protected val MutableMethodDeclaration method
	val int index

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		this.method = method
		this.context = context
		this.index = index
	}
	
	protected def TypeReference cacheFieldType()

	protected def CharSequence cacheFieldInit(CompilationContext context)
	
	protected def CharSequence cacheCall(CompilationContext context)
	
	protected def boolean isSameType(TypeReference it, TypeReference other) {
		it.isAssignableFrom(other) && other.isAssignableFrom(it) && it.actualTypeArguments.seq.zip(other.actualTypeArguments).allMatch [
			v1.isSameType(v2)
		]
	}
	
	private def TypeReference convertTypeParameters(TypeReference ref, Map<TypeReference, TypeReference> seen) {
		seen.get(ref).ofNullable.orElseGet [
			ref.type.newTypeReference(
				ref.actualTypeArguments.map [ 
					convertTypeParameters(seen)
				]
			) => [
				seen.put(ref, it)
			]
		]
	}

	def final generate() {
		// add a cache field and an initializer method.
		method.declaringType => [
			
			// cache field for storing memoized function return values.
			addField(cacheFieldName) [
				static = method.static
				final = true
				type = cacheFieldType
				initializer = [cacheFieldInit]
			]
			
			// initializer method executes original method body for creating a cache value.
			// beware: this implementation does not handle type parameters on methods!
			addMethod(initMethodName) [ init |
				init.static = method.static
				init.visibility = Visibility.PRIVATE
				String.newTypeReference.actualTypeArguments
				// initially this map contains mappings from original method type parameters to new ones.
				// each call to `convertTypeParameters()` fills the map with further type mappings.
				val oldToNewTypeReferences = method.typeParameters.map [it]
					.associateWithKey[it.newSelfTypeReference]
					.mapValue[
						init.addTypeParameter(simpleName, it.upperBounds).newSelfTypeReference
					]
					.toMap
				method.parameters.forEach[
					init.addParameter(simpleName, type.convertTypeParameters(oldToNewTypeReferences))
				]
				init.returnType = wrappedReturnType.convertTypeParameters(oldToNewTypeReferences)
				init.exceptions = method.exceptions
				init.body = method.body
			]
		]
		
		// replace original method with one that tries to get the value
		// from cache first and if not existent executes the initializer method. 
		method => [
			body = [cacheCall]
			returnType = wrappedReturnType
		]
	}

	final protected def wrappedReturnType() {
		method.returnType.wrapperIfPrimitive
	}

	final protected def initMethodName() {
		method.simpleName + "_init"
	}

	final protected def String cacheFieldName() '''cache«index»_«method.simpleName»'''
}
