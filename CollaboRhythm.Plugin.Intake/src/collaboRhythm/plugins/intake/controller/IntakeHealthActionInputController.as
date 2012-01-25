package collaboRhythm.plugins.intake.controller
{
	import collaboRhythm.plugins.intake.model.IntakeHealthActionInputModel;
	import collaboRhythm.plugins.intake.view.IntakeHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class IntakeHealthActionInputController implements IHealthActionInputController
		{
			private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = IntakeHealthActionInputView;

			private var _dataInputModel:IntakeHealthActionInputModel;
			private var _viewNavigator:ViewNavigator;

			public function IntakeHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider, viewNavigator:ViewNavigator)
			{
				_dataInputModel = new IntakeHealthActionInputModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
				_viewNavigator = viewNavigator;
			}

			public function showHealthActionInputView():void
			{
				var dataInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
						this);

				_viewNavigator.pushView(HEALTH_ACTION_INPUT_VIEW_CLASS, dataInputModelAndController, null,
						new SlideViewTransition());
			}


			public function updateVariables(urlVariables:URLVariables):void
			{
				_dataInputModel.urlVariables = urlVariables;
			}

			public function submitIntake():void
			{
				_dataInputModel.submitIntake();
				_viewNavigator.popView();
			}

			public function get healthActionInputViewClass():Class
			{
				return HEALTH_ACTION_INPUT_VIEW_CLASS;
			}
		}
	}

