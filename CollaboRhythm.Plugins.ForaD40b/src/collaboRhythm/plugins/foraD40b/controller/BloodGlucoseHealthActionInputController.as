package collaboRhythm.plugins.foraD40b.controller
{
	import collaboRhythm.ane.applicationMessaging.actionScript.ApplicationMessaging;
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModel;
	import collaboRhythm.plugins.foraD40b.model.BloodGlucoseHealthActionInputModelCollection;
	import collaboRhythm.plugins.foraD40b.model.ForaD40bHealthActionInputControllerFactory;
	import collaboRhythm.plugins.foraD40b.model.ReportBloodGlucoseItemData;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHealthActionInputView;
	import collaboRhythm.plugins.foraD40b.view.BloodGlucoseHistoryView;
	import collaboRhythm.plugins.foraD40b.view.HypoglycemiaActionPlanSummaryView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.BackgroundProcessCollectionModel;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import com.adobe.nativeExtensions.Vibration;

	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class BloodGlucoseHealthActionInputController extends HealthActionInputControllerBase implements IHealthActionInputController
	{
		private static const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = BloodGlucoseHealthActionInputView;
		public static const BATCH_TRANSFER_URL_VARIABLE:String = "batchTransfer";

		private var _dataInputModelCollection:BloodGlucoseHealthActionInputModelCollection;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;
		private var _duplicateDetected:Boolean = false;
		protected var _logger:ILogger;
		protected var _backgroundProcessModel:BackgroundProcessCollectionModel;

		private var _stopIfOutOfOrder:Boolean = false;
		private var _shouldDetectDuplicates:Boolean = false;

		public function BloodGlucoseHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																scheduleCollectionsProvider:IScheduleCollectionsProvider,
																viewNavigator:ViewNavigator)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_dataInputModelCollection = new BloodGlucoseHealthActionInputModelCollection(scheduleItemOccurrence,
					healthActionModelDetailsProvider, scheduleCollectionsProvider, this);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			_backgroundProcessModel = BackgroundProcessCollectionModel(WorkstationKernel.instance.resolve(BackgroundProcessCollectionModel));

			BindingUtils.bindSetter(currentView_changeHandler, _dataInputModelCollection, "currentView");
		}

		public function get backgroundProcessModel():BackgroundProcessCollectionModel
		{
			return _backgroundProcessModel;
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModelCollection.handleHealthActionResult();
		}

		public function handleHealthActionSelected():void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModelCollection.handleHealthActionSelected();
		}

		public static const BATCH_TRANSFER_PROCESS_KEY:String = "BloodGlucoseHealthActionInputController_BeginBatchTransfer";

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			addCollaborationViewSynchronizationEventListener();

			var batchTransferAction:String = urlVariables[BATCH_TRANSFER_URL_VARIABLE];
			if (batchTransferAction == "begin")
			{
				_duplicateDetected = false;
				backgroundProcessModel.updateProcess(BATCH_TRANSFER_PROCESS_KEY, "Transferring data from " + ForaD40bHealthActionInputControllerFactory.EQUIPMENT_NAME + "...", true);
			}
			else if (batchTransferAction == "end")
			{
				_duplicateDetected = false;
				backgroundProcessModel.updateProcess(BATCH_TRANSFER_PROCESS_KEY, null, false);
			}
			else
			{
				handleUrlVariablesNewMeasurement(urlVariables);
			}
		}

		private function handleUrlVariablesNewMeasurement(urlVariables:URLVariables):void
		{
			// previously detected duplicate
			if (_duplicateDetected)
				return;

			_duplicateDetected = _shouldDetectDuplicates && detectDuplicates(urlVariables);

			if (!_duplicateDetected)
			{
				if (!isValidMeasurement(urlVariables))
				{
					_logger.debug("handleUrlVariablesNewMeasurement invalid urlVariables " + urlVariables.toString());
					return;
				}

				var itemData:ReportBloodGlucoseItemData = _dataInputModelCollection.reportBloodGlucoseItemDataCollection.length >
						0 ? _dataInputModelCollection.reportBloodGlucoseItemDataCollection[0] as
						ReportBloodGlucoseItemData : null;
				if (_dataInputModelCollection.reportBloodGlucoseItemDataCollection.length > 1 ||
						_dataInputModelCollection.reportBloodGlucoseItemDataCollection.length == 1 &&
								(itemData).dataInputModel.isFromDevice)
				{
					// only handle additional measurements if they are before the currently queued measurement(s)
					var previousDataInputModel:BloodGlucoseHealthActionInputModel = (_dataInputModelCollection.reportBloodGlucoseItemDataCollection[_dataInputModelCollection.reportBloodGlucoseItemDataCollection.length -
							1] as ReportBloodGlucoseItemData).dataInputModel;
					if (_stopIfOutOfOrder && DateUtil.parseW3CDTF(urlVariables.correctedMeasuredDate).valueOf() >=
							previousDataInputModel.dateMeasuredStart.valueOf())
					{
						_logger.warn("handleUrlVariables ignored because incoming correctedMeasuredDate " +
								urlVariables.correctedMeasuredDate + " was not before currently queued measurement " +
								DateUtil.format(previousDataInputModel.dateMeasuredStart) + ". urlVariables: " +
								urlVariables.toString());
						return;
					}

					itemData = new ReportBloodGlucoseItemData(new BloodGlucoseHealthActionInputModel(null,
							_dataInputModelCollection.healthActionModelDetailsProvider,
							_dataInputModelCollection.scheduleCollectionsProvider,
							_dataInputModelCollection), this);
					_dataInputModelCollection.reportBloodGlucoseItemDataCollection.addItem(itemData);
				}
				itemData.dataInputModel.handleUrlVariables(urlVariables);

				var guessedScheduleItemOccurrence:ScheduleItemOccurrence = itemData.dataInputModel.guessScheduleItemOccurrence();
				handleAdherenceChange(itemData.dataInputModel, guessedScheduleItemOccurrence, true);
			}
		}

		private static function isValidMeasurement(urlVariables:URLVariables):Boolean
		{
			return StringUtils.isNumeric(urlVariables.bloodGlucose) && DateUtil.parseW3CDTF(urlVariables.correctedMeasuredDate) != null;
		}

		private function detectDuplicates(urlVariables:URLVariables):Boolean
		{
			var isDebugger:Boolean = Capabilities.isDebugger;
			var playerType:String = Capabilities.playerType;

			// check all existing blood glucose measurements
			for each (var bloodGlucoseVitalSign:VitalSign in _dataInputModelCollection.healthActionModelDetailsProvider.record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.BLOOD_GLUCOSE_CATEGORY))
			{
				if (isDuplicate(urlVariables, bloodGlucoseVitalSign))
				{
					if (playerType == "Desktop" && isDebugger)
					{
					}
					else
					{
						sendBroadcastDuplicateDetected();
					}

					return true;
				}
			}
			return false;
		}

		private function sendBroadcastDuplicateDetected():void
		{
			var extension:ApplicationMessaging = new ApplicationMessaging();
			extension.sendBroadcast("CollaboRhythm-health-action-received-v1", "duplicate",
					"healthActionStringTest1");
		}

		private static function isDuplicate(urlVariables:URLVariables, bloodGlucoseVitalSign:VitalSign):Boolean
		{
			if (bloodGlucoseVitalSign.result && bloodGlucoseVitalSign.result.value == urlVariables.bloodGlucose)
			{
				var deviceMeasuredDateKey:String = "deviceMeasuredDate";
				var existingDeviceMeasuredDateString:String = parseVitalSignComment(bloodGlucoseVitalSign.comments, deviceMeasuredDateKey);
				if (existingDeviceMeasuredDateString)
				{
					return existingDeviceMeasuredDateString == urlVariables[deviceMeasuredDateKey];
				}
				else
				{
					// if the comments can't be parsed or do not include the deviceMeasuredDate, assume that it is a duplicate
					return true;
				}
			}
			return false;
		}

		private static function parseVitalSignComment(comments:String, key:String):String
		{
			if (comments == null)
			{
				return null;
			}

			var parts:Array = comments.split(" ");
			var urlVariablesString:String = parts[parts.length - 1];
			var urlVariables:URLVariables;
			try
			{
				urlVariables = new URLVariables(urlVariablesString);
			} catch (e:Error)
			{
			}

			return urlVariables ? urlVariables[key] : null;
		}

		public function nextStep():void
		{
			if (_synchronizationService.synchronize("nextStep"))
			{
				return;
			}

			_dataInputModelCollection.nextStep(_synchronizationService.initiatedLocally);
		}

		public function createAndSubmitBloodGlucoseVitalSign():void
		{
			if (_synchronizationService.synchronize("createAndSubmitBloodGlucoseVitalSign"))
			{
				return;
			}

			// add the items in reverse order, oldest to newest
			var reversedCollection:ArrayCollection = new ArrayCollection();
			reversedCollection.addAll(_dataInputModelCollection.reportBloodGlucoseItemDataCollection);
			reversedCollection.source.reverse();

			for each (var itemData:ReportBloodGlucoseItemData in reversedCollection)
			{
				var model:BloodGlucoseHealthActionInputModel = itemData.dataInputModel;
				model.createBloodGlucoseVitalSign();

				if (itemData.dataInputModel == _dataInputModelCollection.firstInputModel)
					model.submitBloodGlucose(model.bloodGlucoseVitalSign, _synchronizationService.initiatedLocally);
				else
					model.saveBloodGlucose(model.bloodGlucoseVitalSign, _synchronizationService.initiatedLocally, false);
			}
		}

		private function currentView_changeHandler(currentView:Class):void
		{
			if (currentView == null)
			{
				if (_synchronizationService && _synchronizationService.initiatedLocally &&
						_dataInputModelCollection.pushedViewCount != 0)
				{
					for (var pushedViewIndex:int = 0; pushedViewIndex < _dataInputModelCollection.pushedViewCount;
						 pushedViewIndex++)
					{
						_viewNavigator.popView();
					}
					_dataInputModelCollection.pushedViewCount = 0;
				}

				removeCollaborationViewSynchronizationEventListener();
			}
			else
			{
				pushView(currentView);
			}
		}

		private function pushView(currentView:Class):void
		{
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModelCollection,
					this);
			_viewNavigator.pushView(currentView, healthActionInputModelAndController, null, new SlideViewTransition());
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}

		public function startWaitTimer():void
		{
			if (_synchronizationService.synchronize("startWaitTimer"))
			{
				return;
			}

			_dataInputModelCollection.startWaitTimer();
		}

		public function updateManualBloodGlucose(text:String = ""):void
		{
			if (_synchronizationService.synchronize("updateManualBloodGlucose", text))
			{
				return;
			}

			_dataInputModelCollection.manualBloodGlucose = text;
		}

		public function updateDateMeasuredStart(selectedDate:Date):void
		{
			if (_synchronizationService.synchronize("updateDateMeasuredStart", selectedDate))
			{
				return;
			}

			_dataInputModelCollection.dateMeasuredStart = selectedDate;
		}

		public function quitHypoglycemiaActionPlan():void
		{
			if (_synchronizationService.synchronize("quitHypoglycemiaActionPlan"))
			{
				return;
			}

			_dataInputModelCollection.quitHypoglycemiaActionPlan(_synchronizationService.initiatedLocally);
		}

		public function addEatCarbsHealthAction(description:String):void
		{
			if (_synchronizationService.synchronize("addEatCarbsHealthAction", description))
			{
				return;
			}

			_dataInputModelCollection.addEatCarbsHealthAction(description);
		}

		public function showHypoglycemiaActionPlanSummaryView(bloodGlucoseVitalSignDate:Date):void
		{
			if (_synchronizationService.synchronize("showHypoglycemiaActionPlanSummaryView", bloodGlucoseVitalSignDate))
			{
				return;
			}

			_viewNavigator.pushView(HypoglycemiaActionPlanSummaryView,
					[bloodGlucoseVitalSignDate, this, _dataInputModelCollection]);
		}

		public function addWaitHealthAction(seconds:int):void
		{
			if (_synchronizationService.synchronize("addWaitHealthAction", seconds))
			{
				return;
			}

			_dataInputModelCollection.addWaitHealthAction(seconds);
		}

		public function setBloodGlucoseHistoryListScrollPosition(scrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("setBloodGlucoseHistoryListScrollPosition", scrollPosition, false))
			{
				return;
			}

			_dataInputModelCollection.setBloodGlucoseHistoryListScrollerPosition(scrollPosition);
		}

		public function simpleCarbsItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("simpleCarbsItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModelCollection.simpleCarbsItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs15gItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs15gItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModelCollection.complexCarbs15gItemList_changeHandler(selectedIndex);
		}

		public function complexCarbs30gItemList_changeHandler(selectedIndex:int):void
		{
			if (_synchronizationService.synchronize("complexCarbs30gItemList_changeHandler", selectedIndex, false))
			{
				return;
			}

			_dataInputModelCollection.complexCarbs30gItemList_changeHandler(selectedIndex);
		}

		public function synchronizeActionsListScrollPosition(verticalScrollPosition:Number = 0):void
		{
			if (_synchronizationService.synchronize("synchronizeActionsListScrollPosition", verticalScrollPosition,
					false))
			{
				return;
			}

			_dataInputModelCollection.synchronizeActionsListScrollerPosition(verticalScrollPosition);
		}

		public function addCollaborationViewSynchronizationEventListener():void
		{
			if (!_synchronizationService)
			{
				_synchronizationService = new SynchronizationService(this,
						_collaborationLobbyNetConnectionServiceProxy);
			}
		}

		public function removeCollaborationViewSynchronizationEventListener():void
		{
			if (_synchronizationService)
			{
				if (_synchronizationService.synchronize("removeCollaborationViewSynchronizationEventListener"))
				{
					return;
				}

				_synchronizationService.removeEventListener(this);
			}
		}

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}

		public function showBloodGlucoseHistoryView():void
		{
			if (_synchronizationService.synchronize("showBloodGlucoseHistoryView"))
			{
				return;
			}

			pushView(BloodGlucoseHistoryView);
		}

		public function playVideo(instructionalVideoPath:String):void
		{
			// TODO: Currently using the vibration native extension with modifications to play a video
			var vibration:Vibration = new (Vibration);
			vibration.vibrate(instructionalVideoPath, "video/*");
		}

		public function handleHealthActionCommandButtonClick(event:MouseEvent):void
		{
		}

		public function removeEventListener():void
		{
		}

		override public function handleAdherenceChange(dataInputModel:IHealthActionInputModel,
													   scheduleItemOccurrence:ScheduleItemOccurrence,
													   selected:Boolean):void
		{
			super.handleAdherenceChange(dataInputModel, scheduleItemOccurrence, selected);

			if (selected)
				dataInputModel.scheduleItemOccurrence = scheduleItemOccurrence;
			else
				dataInputModel.scheduleItemOccurrence = null;

			if (selected && scheduleItemOccurrence != null)
			{
				for each (var itemData:ReportBloodGlucoseItemData in
						_dataInputModelCollection.reportBloodGlucoseItemDataCollection)
				{
					var model:BloodGlucoseHealthActionInputModel = itemData.dataInputModel;
					if (model != dataInputModel && scheduleItemOccurrence.equals(model.scheduleItemOccurrence))
					{
						// Each scheduleItemOccurrence can only be associated with one measurement
						model.scheduleItemOccurrence = null;
					}
				}
			}
		}
	}
}