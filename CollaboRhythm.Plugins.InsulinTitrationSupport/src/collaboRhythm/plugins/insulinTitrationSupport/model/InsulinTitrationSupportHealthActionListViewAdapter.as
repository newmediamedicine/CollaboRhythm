package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.core.IVisualElement;

	import spark.components.Image;
	import spark.skins.spark.ImageSkin;

	public class InsulinTitrationSupportHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _healthAction:InsulinTitrationSupportHealthAction;
		private var _model:InsulinTitrationSupportHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;

		public function InsulinTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthAction = new InsulinTitrationSupportHealthAction();
			_model = new InsulinTitrationSupportHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider);

		}

		public function get healthAction():HealthActionBase
		{
			return _healthAction;
		}

		[Embed("/assets/images/titrateLevemir.png")]
		private var _titrateLevemirImageClass:Class;

		public function createImage():Image
		{
			var image:Image = new Image();
			image.setStyle("skinClass", ImageSkin);
			image.source = _titrateLevemirImageClass;
			image.smooth = true;
			return image;
		}

		public function get name():String
		{
			return InsulinTitrationSupportHealthAction.HEALTH_ACTION_TYPE;
		}

		public function get description():String
		{
			return "Make a decision to change insulin dose";
		}

		public function get indication():String
		{
			return "Diabetes";
		}

		public function get primaryInstructions():String
		{
			return "";
		}

		public function get secondaryInstructions():String
		{
			return "";
		}

		public function get instructionalVideoPath():String
		{
			return "";
		}

		public function set instructionalVideoPath(value:String):void
		{

		}

		public function get additionalAdherenceInformation():String
		{
			return "...";
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			if (!_controller)
			{
				_controller = new HealthActionListViewControllerBase(_model)
			}
			return _controller;
		}

		public function createCustomView():IVisualElement
		{
			return null;
		}
	}
}
