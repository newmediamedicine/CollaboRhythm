package collaboRhythm.core.view
{
	import mx.collections.HierarchicalCollectionViewCursor;
	import mx.collections.IHierarchicalCollectionViewCursor;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.BaseListData;

	public class AdvancedDataGridFixed extends AdvancedDataGrid
	{
		public function AdvancedDataGridFixed()
		{
			super();
		}

		override protected function makeListData(data:Object, uid:String, rowNum:int, columnNum:int,
												 column:AdvancedDataGridColumn):BaseListData
		{
			var label:String;
			var advancedDataGridListData:AdvancedDataGridListData;
			if (data is AdvancedDataGridColumnGroup)
			{
				return new AdvancedDataGridListData((column.headerText != null) ? column.headerText : "",
						data.dataField, -1, uid, this, rowNum);
			}
			else if (!(data is AdvancedDataGridColumn))
			{
/*
				if (groupItemRenderer && isBranch(data) && column.colNum == treeColumnIndex)
				{
					// Checking for a groupLabelFunction or a groupLabelField property to be present
					if (groupLabelFunction != null)
						label = groupLabelFunction(data, column);
					else if (groupLabelField != null && data.hasOwnProperty(groupLabelField))
						label = data[groupLabelField];

					if (label)
						advancedDataGridListData = new AdvancedDataGridListData(label, column.dataField,
								columnNum, uid, this, rowNum);
				}
*/
			}

			if (!advancedDataGridListData)
				advancedDataGridListData =
						super.makeListData(data, uid, rowNum, columnNum, column) as AdvancedDataGridListData;

			if (iterator && iterator is IHierarchicalCollectionViewCursor && columnNum == treeColumnIndex
					&& !(data is AdvancedDataGridColumn))
				initListData(data, advancedDataGridListData);
			else
			//item needs to be set, otherwise it will flicker the display when a node is expanded or collapsed
				advancedDataGridListData.item = data;

			return advancedDataGridListData;
		}
	}
}
