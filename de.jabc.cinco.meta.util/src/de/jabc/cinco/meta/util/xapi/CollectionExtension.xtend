package de.jabc.cinco.meta.util.xapi

import java.util.HashSet
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.jooq.lambda.Seq
import org.jooq.lambda.tuple.Tuple2

import static extension org.jooq.lambda.Seq.*
import java.util.Enumeration
import org.apache.commons.collections.EnumerationUtils
import java.util.List

/**
 * Some collection extensions for cinco meta, cinco, and cinco products.
 * 
 * @author Johannes Neubauer
 */
class CollectionExtension {
	
	/**
	 * Filters all distinct objects in a sequence by a given key, i.e., all duplicates
	 * are removed from the resulting sequence.
	 * 
	 * This is an intermediate, stateful operation
	 * 
	 * @param seq the sequence to filter.
	 * @param keyExtractor a lambda that extracts a key from each element 
	 * 		in the sequence used for distinct object checking
	 * @return a sequence that contains only distinct values.
	 */
	def <T, U> distinctByKey(Seq<T> seq, (T) => U keyExtractor) {
		val seen = new HashSet<U>
		seq.filter[seen += keyExtractor.apply(it)]
	}
	
	/**
	 * Convenience extension function for calling {@link Seq#distinctByKey}.
	 */
	def <T, U> distinctByKey(Iterable<T> iterable, (T) => U keyExtractor) {
		iterable.seq.distinctByKey(keyExtractor)
	}
	
	/**
	 * Filters all duplicates in a sequence by a given key, i.e., all duplicates
	 * are still in the resulting sequence.
	 * 
	 * This is an intermediate, stateful operation
	 * 
	 * @param seq the sequence to filter.
	 * @param keyExtractor a lambda that extracts a key from each element 
	 * 		in the sequence used for duplicate checking
	 * @return a sequence that contains only duplicates.
	 */
	def <T, U> duplicatesByKey(Seq<T> seq, (T) => U keyExtractor) {
		val seen = new HashSet<U>
		seq.filter[!(seen += keyExtractor.apply(it))]
	}
	
	/**
	 * Convenience extension function for calling {@link Seq#duplicatesByKey}.
	 */
	def <T, U> duplicatesByKey(Iterable<T> iterable, (T) => U keyExtractor) {
		iterable.seq.duplicatesByKey(keyExtractor)
	}
	
	/**
	 * Convenience extension function for calling {@link Seq#partition} directly on an iterable,
	 * instead of calling {@link Seq#seq} first.
	 * 
	 * @see Seq#partition
	 */
	def <T> partition(Iterable<T> iterable, (T) => boolean predicate) {
		Seq.partition(iterable.seq, predicate)
	}
	
	/**
	 * Convenience extension function for calling {@link Seq#duplicate} directly on an iterable,
	 * instead of calling {@link Seq#seq} first.
	 * 
	 * @see Seq#duplicate
	 */
	def <T> duplicate(Iterable<T> iterable) {
		Seq.duplicate(iterable.seq)
	}
	
	/**
	 * Convenience extension function for executing a lambda on the first (i.e., the 
	 * matching results for a partition) result of a tuple of sequences (e.g. after 
	 * a {@link Seq#partition}).
	 * 
	 * @param partition the tuple of sequences
	 * @param block the handling lambda for the sequence of matching elements.
	 * @return the second sequence (i.e., the sequence of not matching results) 
	 * 		for chaining. 
	 */
	def <T> matching(Tuple2<Seq<T>, Seq<T>> partition, (Seq<T>) => void block) {
		block.apply(partition.v1)
		partition.v2
	}
	
	/**
	 * Convenience extension function taking a sequence and executing a given lambda 
	 * on it. It illustrates, that the given sequence contains the not matching results
	 * of, e.g., a partition. You may chain multiple {@link Seq#partition} and 
	 * {@link CollectionExtension#matching} calls and finally call
	 * {@link CollectionExtension#nonMatching} to handle the sequence with remaining elements.
	 * 
	 * @param seq the sequence with remaining elements.
	 * @param block the lambda to be executed on the remaining elements.
	 */
	def <T> nonMatching(Seq<T> seq, (Seq<T>) => void block) {
		block.apply(seq)
	}
	
	/**
	 * Convenience extension function for executing a lambda on the first
	 * result of a tuple of sequences, i.e., the "original" sequence 
	 * after a {@link Seq#duplicate}.
	 * 
	 * @param dupes the tuple of sequences
	 * @param block the handling lambda for the sequence of next elements.
	 * @return the second sequence for chaining. 
	 */
	def <T> orig(Tuple2<Seq<T>, Seq<T>> dupes, (Seq<T>) => void block) {
		block.apply(dupes.v1)
		dupes.v2
	}
	
	/**
	 * Convenience extension function taking a sequence and executing a given lambda 
	 * on it. It illustrates, that the given sequence contains the second sequence
	 * (i.e. the copy) of, e.g., a duplication. You may chain multiple {@link Seq#duplicate} and 
	 * {@link CollectionExtension#orig} calls and finally call
	 * {@link CollectionExtension#copy} to handle the sequence with remaining elements.
	 * 
	 * @param seq the sequence with remaining elements.
	 * @param block the lambda to be executed on the remaining elements.
	 */
	def <T> copy(Seq<T> seq, (Seq<T>) => void block) {
		block.apply(seq)
	}
	
	/**
	 * Filters keys by class from a sequence of tuples (i.e., a map sequence). That means, keys that match 
	 * the class are returned, but keys that do not match are not. Hence, the returned sequence of tuples 
	 * are typed with the given class. 
	 * 
	 * @param mapSeq a sequence of tuples.
	 * @param c the class to filter for.
	 * @return a mapping sequence with key/value pairs filtered by the class of the key.
	 */
	def <K,V, N extends K> Seq<Tuple2<N, V>> filterKeys(Seq<Tuple2<K, V>> mapSeq, Class<N> c) {
		// filter the elements that match the type from the tuples
		val it = mapSeq.filter[c.isInstance(v1)].unzip
		// cast the keys to the matched type (the filtering is done before on the tuples!)
		v1.ofType(c).zip(v2)
	}
	
	/**
	 * Filters keys by lambda from a sequence of tuples (i.e., a map sequence). That means, keys that match 
	 * the given filter criterion (represented by the lambda) are returned.
	 * 
	 * @param mapSeq a sequence of tuples.
	 * @param keyExtractor the filter criterion.
	 * @return a  mapping sequence with key/value pairs filtered by the filter criterion {@code keyExtractor}.
	 */
	def <K, V> filterKeys(Seq<Tuple2<K, V>> mapSeq, (K) => boolean keyExtractor) {
		mapSeq.filter[keyExtractor.apply(v1)]
	}
	
	/**
	 * Convenience extension method for iterables to use {@link #associateWithKey}.
	 */
	def <T, U> associateWithKey(Iterable<U> iterable, (U) => T keyExtractor) {
		iterable.seq.associateWithKey(keyExtractor)
	}
	
	/**
	 * Associates each element to a key extracted from the value creating a mapping sequence.
	 * 
	 * @param seq a sequence with the values.
	 * @param keyExtractor a lambda that extracts a key for each element.
	 * @return a mapping sequence associating extracted keys to values.
	 */
	def <T, U> associateWithKey(Seq<U> seq, (U) => T keyExtractor) {
		seq.map[new Tuple2(keyExtractor.apply(it), it)]
	}
	
	def <T> match(Iterable<T> iterable, (T) => boolean predicate) {
		iterable.partition(predicate)
	}

	def <T> match(Seq<T> seq, (T) => boolean predicate) {
		seq.partition(predicate)
	}
	
	/**
	 * Removes elements that have a given association to an element. This method can be used e.g. 
	 * to lazily delete all but leaf nodes from a tree like this:
	 * 
	 * <pre>
	 * treeNodes.seq.deleteByAssociation[parent].toList
	 * </pre>
	 * 
	 * @param seq the sequence to filter.
	 * @param associator a lambda expression for establishing an association 
	 * 	between a node and the node to be deleted.
	 */
	public def <T> removeByAssociation(Seq<T> seq, (T) => T associator) {		
		seq.removeByAssociatedElements[
			Seq.of(associator.apply(it))
		]
	}
	
	/**
	 * Removes elements that have the given associated elements. This method can be used e.g. 
	 * to lazily delete all but leaf nodes from a tree like this:
	 * 
	 * <pre>
	 * treeNodes.seq.deleteByAssociation[Seq.of(parent)].toList
	 * </pre>
	 * 
	 * @param seq the sequence to filter.
	 * @param associator a lambda expression for establishing an association 
	 * 	between a node and the node to be deleted.
	 */
	public def <T> removeByAssociatedElements(Seq<T> seq, (T) => Seq<T> associator) {		
		val dupe = seq.duplicate
		val deleteItems = dupe.v1.flatMap[associator.apply(it)].distinct
		dupe.v2.removeAll(deleteItems)
	}
	
	/**
	 * Returns the elements of {@code unfiltered} that do not satisfy a predicate. The resulting
	 * iterable's iterator does not support {@code remove()}. The returned iterable is a view on
	 * the original elements. Changes in the unfiltered original are reflected in the view.
	 * 
	 * @param unfiltered
	 *            the unfiltered iterable. May not be <code>null</code>.
	 * @param predicate
	 *            the predicate. May not be <code>null</code>.
	 * @return an iterable that contains only the elements that do not fulfill the predicate.
	 *   Never <code>null</code>.
	 */
	@Pure
	def <T> Iterable<T> drop(Iterable<T> unfiltered, Function1<? super T, Boolean> predicate) {
		unfiltered.filter[!predicate.apply(it)]
	}
	
	/**
	 * Returns all instances that are not of class {@code type} in {@code unfiltered}. The returned
	 * iterable has elements whose class is neither {@code type} or a subclass of {@code type}. The
	 * returned iterable's iterator does not support {@code remove()}. The returned iterable is a
	 * view on the original elements. Changes in the unfiltered original are reflected in the view.
	 * 
	 * @param unfiltered
	 *            the unfiltered iterable. May not be <code>null</code>.
	 * @param type
	 *            the type of elements to be dropped
	 * @return an iterable containing all elements of the original iterable that are not of the type
	 *   to be excluded. Never <code>null</code>.
	 */
	@Pure
	def <T> Iterable<T> drop(Iterable<T> unfiltered, Class<?> type) {
		unfiltered.filter[!type.isInstance(it)]
	}
	
	/**
	 * Transforms an {@code Enumeration} into a list.
	 */
	def <T> toList(Enumeration<T> enumeration) {
		EnumerationUtils.toList(enumeration) as List<T>
	}
}
