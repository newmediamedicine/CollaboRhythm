package collaboRhythm.plugins.foraD40b.controller
{
	import avmplus.factoryXml;

	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.EatSomethingSugaryView;
	import collaboRhythm.plugins.foraD40b.view.RecheckBloodGlucoseTimerView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodGlucoseHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BloodGlucoseHealthActionInputView;

		private var _dataInputModel:BloodGlucoseHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;

		public function BloodGlucoseHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																viewNavigator:ViewNavigator)
		{
			_dataInputModel = new BloodGlucoseHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
		}

		public function showHealthActionInputView():void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);

			_dataInputModel.pushedViewCount += 1;
			_viewNavigator.pushView(HEALTH_ACTION_INPUT_VIEW_CLASS, healthActionInputModelAndController, null,
					new SlideViewTransition());
		}

		public function updateVariables(urlVariables:URLVariables):void
		{
			_dataInputModel.urlVariables = urlVariables;
		}

		public function submitBloodGlucose(bloodGlucose:String):void
		{
			_dataInputModel.bloodGlucose = bloodGlucose;
			_dataInputModel.previousBloodGlucose = _dataInputModel.bloodGlucose;
			if (int(_dataInputModel.bloodGlucose) < 70)
			{
				var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
						this);
				_dataInputModel.pushedViewCount += 1;
				_viewNavigator.pushView(EatSomethingSugaryView, healthActionInputModelAndController);
			}
			else
			{
				for (var pushedViewIndex:int = 0; pushedViewIndex < _dataInputModel.pushedViewCount; pushedViewIndex++)
				{
					_viewNavigator.popView();
				}
			}
			_dataInputModel.submitBloodGlucose();
			_dataInputModel.fromDevice = false;
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}

		public function showRecheckBloodGlucoseTimer():void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);
			_dataInputModel.repeatCount += 1;
			_dataInputModel.pushedViewCount += 1;
			_viewNavigator.pushView(RecheckBloodGlucoseTimerView, healthActionInputModelAndController);
		}

		public function recheckBloodGlucose():void
		{
			showHealthActionInputView();
		}
	}
}