package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.VitalSignFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class TCellCountHealthActionCreationModel implements IHealthActionCreationModel
	{
		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;

		public function TCellCountHealthActionCreationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
		}

		public function saveTCellCount(tCellCount:String, selectedDate:Date):void
		{
			var vitalSignFactory:VitalSignFactory = new VitalSignFactory();

			var tCellCountVitalSign:VitalSign = vitalSignFactory.createTCellCount(selectedDate, tCellCount,
					_activeAccount.accountId, null, null, null, null, null);

			tCellCountVitalSign.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(tCellCountVitalSign);
			_activeRecordAccount.primaryRecord.saveAllChanges();
		}
	}
}
