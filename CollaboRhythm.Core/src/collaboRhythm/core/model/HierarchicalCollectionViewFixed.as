package collaboRhythm.core.model
{
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalData;
	import mx.collections.SortField;

	public class HierarchicalCollectionViewFixed extends HierarchicalCollectionViewEx
	{
		public function HierarchicalCollectionViewFixed(hierarchicalData:IHierarchicalData = null,
														argOpenNodes:Object = null)
		{
			super(hierarchicalData, argOpenNodes);
		}

		override protected function sortCanBeApplied(coll:ICollectionView):Boolean
		{
			if (sort == null)
				return true;

			// get the current item
			var obj:Object = coll.createCursor().current;

			if (!obj || !sort.fields)
				return false;

			// check for the properties (sort fields) in the current object
			for (var i:int = 0; i < sort.fields.length; i++)
			{
				var sf:SortField = sort.fields[i];
				if (!sf.compareFunction && !obj.hasOwnProperty(sf.name))
					return false;
			}
			return true;
		}
	}
}
