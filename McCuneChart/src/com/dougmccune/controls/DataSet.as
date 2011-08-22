package com.dougmccune.controls
{

	import mx.collections.ArrayCollection;

	public class DataSet
	{
		public var seriesDataCollection:ArrayCollection;
		public var dateField:String;

		public function DataSet(seriesDataCollection:ArrayCollection, dateField:String)
		{
			this.seriesDataCollection = seriesDataCollection;
			this.dateField = dateField;
		}
	}
}
