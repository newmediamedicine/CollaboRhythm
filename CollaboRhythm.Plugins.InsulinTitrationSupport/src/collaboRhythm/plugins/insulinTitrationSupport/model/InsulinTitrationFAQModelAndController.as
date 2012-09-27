package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.*;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModel;

	public class InsulinTitrationFAQModelAndController
	{
		private var _insulinTitrationFAQModel:InsulinTitrationFAQModel;
		private var _insulinTitrationFAQController:InsulinTitrationFAQController;

		public function InsulinTitrationFAQModelAndController(insulinTitrationFAQModel:InsulinTitrationFAQModel,
															  insulinTitrationFAQController:InsulinTitrationFAQController)
		{
			_insulinTitrationFAQModel = insulinTitrationFAQModel;
			_insulinTitrationFAQController = insulinTitrationFAQController;
		}

		public function get insulinTitrationFAQModel():InsulinTitrationFAQModel
		{
			return _insulinTitrationFAQModel;
		}

		public function get insulinTitrationFAQController():InsulinTitrationFAQController
		{
			return _insulinTitrationFAQController;
		}
	}
}
