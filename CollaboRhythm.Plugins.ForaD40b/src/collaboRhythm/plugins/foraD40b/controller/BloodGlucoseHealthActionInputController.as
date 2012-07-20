package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.HypoglycemiaActionPlanSummaryView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.net.URLVariables;

	import mx.binding.utils.BindingUtils;

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

			BindingUtils.bindSetter(currentView_changeHandler, _dataInputModel, "currentView");


		}

		public function handleHealthActionResult():void
		{
			_dataInputModel.handleHealthActionResult();
		}

		public function handleHealthActionSelected():void
		{
			_dataInputModel.handleHealthActionSelected();
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			_dataInputModel.handleUrlVariables(urlVariables);
		}

		public function nextStep():void
		{
			_dataInputModel.nextStep();
		}

		public function submitBloodGlucose(bloodGlucose:String):void
		{
			_dataInputModel.submitBloodGlucose(bloodGlucose);
		}

		private function currentView_changeHandler(currentView:Class):void
		{
			if (currentView == null)
			{
				if (_dataInputModel.pushedViewCount != 0)
				{
					for (var pushedViewIndex:int = 0; pushedViewIndex < _dataInputModel.pushedViewCount;
						 pushedViewIndex++)
					{
						_viewNavigator.popView();
					}
				}
			}
			else
			{
				pushView(currentView);
			}
		}

		private function pushView(currentView:Class):void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);
			_viewNavigator.pushView(currentView, healthActionInputModelAndController, null,	new SlideViewTransition());
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}

		public function startWaitTimer():void
		{
			_dataInputModel.startWaitTimer();
		}

		public function updateManualBloodGlucose(text:String):void
		{
			_dataInputModel.updateManualBloodGlucose(text);
		}

		public function quitHypoglycemiaActionPlan():void
		{
			_dataInputModel.quitHypoglycemiaActionPlan();
		}

		public function goBack():void
		{
			_viewNavigator.popView();
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			_dataInputModel.addEatCarbsHealthAction(description);
		}

		public function showHypoglycemiaActionPlanSummaryView(bloodGlucoseVitalSign:VitalSign):void
		{
			_viewNavigator.pushView(HypoglycemiaActionPlanSummaryView, bloodGlucoseVitalSign);
		}
	}
}