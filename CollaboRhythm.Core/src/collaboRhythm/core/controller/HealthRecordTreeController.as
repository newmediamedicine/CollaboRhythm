package collaboRhythm.core.controller
{
	import collaboRhythm.core.model.HealthRecordServiceModel;
	import collaboRhythm.core.model.HealthRecordTreeModel;
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.view.HealthRecordDocumentView;
	import collaboRhythm.core.view.HealthRecordTree;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import spark.components.ViewNavigator;

	public class HealthRecordTreeController
	{
		private var _healthRecordTree:HealthRecordTree;
		private var _model:HealthRecordTreeModel;
		private var _navigator:ViewNavigator;

		public function HealthRecordTreeController(model:HealthRecordTreeModel,
												   navigator:ViewNavigator)
		{
			_model = model;
			_navigator = navigator;
		}

		public function get healthRecordTree():HealthRecordTree
		{
			return _healthRecordTree;
		}

		public function set healthRecordTree(value:HealthRecordTree):void
		{
			_healthRecordTree = value;
		}

		public function get model():HealthRecordTreeModel
		{
			return _model;
		}

		public function set model(value:HealthRecordTreeModel):void
		{
			_model = value;
		}

		public function viewSelectedDocument():void
		{
			if (_healthRecordTree.selectedDocument != null)
			{
				_navigator.pushView(HealthRecordDocumentView, new HealthRecordDocumentController(new HealthRecordServiceModel(_healthRecordTree.selectedDocument, _model.healthRecordServiceFacade)));
			}
		}

		public function voidSelectedDocument():void
		{
			if (_healthRecordTree.selectedDocument != null)
			{
				_model.record.removeDocument(_healthRecordTree.selectedDocument, true, true, DocumentBase.ACTION_VOID, "removed by user");
			}
		}

		public function save():void
		{
			_model.record.saveAllChanges();
		}
	}
}
