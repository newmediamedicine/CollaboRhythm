package com.dougmccune.controls
{

	import mx.charts.chartClasses.Series;
	import mx.collections.ArrayCollection;

	public class SeriesDataSet
	{
		public var series:Series;
		public var seriesDataCollection:ArrayCollection;
		public var dateField:String;

		public function SeriesDataSet(series:Series, seriesDataCollection:ArrayCollection, dateField:String)
		{
			this.series = series;
			this.seriesDataCollection = seriesDataCollection;
			this.dateField = dateField;
		}
	}
}
