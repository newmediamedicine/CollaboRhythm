package collaboRhythm.plugins.bloodPressure.view.simulation.buttons
{

	import collaboRhythm.plugins.bloodPressure.view.simulation.*;

	import flash.geom.Point;

	[Bindable]
	public class SimulationDetail
	{
		private var _indicatedPoint:Point;
		private var _detailButton:SimulationDetailButton;

		public function SimulationDetail(indicatedPoint:Point, detailButton:SimulationDetailButton)
		{
			_indicatedPoint = indicatedPoint;
			_detailButton = detailButton;
		}

		public function get indicatedPoint():Point
		{
			return _indicatedPoint;
		}

		public function set indicatedPoint(value:Point):void
		{
			_indicatedPoint = value;
		}

		public function get detailButton():SimulationDetailButton
		{
			return _detailButton;
		}

		public function set detailButton(value:SimulationDetailButton):void
		{
			_detailButton = value;
		}
	}
}
