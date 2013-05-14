package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class ViralLoadHealthActionCreationModel implements IHealthActionCreationModel
	{
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;

		public function ViralLoadHealthActionCreationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
		}

		public function saveViralLoad(viralLoad:String, selectedDate:Date):void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var viralLoadVitalSign:VitalSign = vitalSignFactory.createViralLoad(selectedDate, viralLoad, _activeAccount.accountId, null, null, null, null, null);

			viralLoadVitalSign.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(viralLoadVitalSign);
			_activeRecordAccount.primaryRecord.saveAllChanges();
		}
	}
}
