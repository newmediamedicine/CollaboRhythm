package collaboRhythm.shared.controller
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.BackgroundProcessCollectionModel;
	import collaboRhythm.shared.model.settings.Settings;

	import spark.components.ViewNavigator;

	public interface IApplicationControllerBase
    {
        /**
         * Reloads the documents in the record and tells all app controllers to reload data.
         */
        function reloadData():void;

        function synchronize():void;

        /**
         * Close the entire application, sending out an event to any processes that might want to interrupt the closing
         */
        function exitApplication(exitMethod:String):void;

        function showAboutApplicationView():void;

        function get fastForwardEnabled():Boolean;

        function set fastForwardEnabled(value:Boolean):void;

        function useDemoPreset(demoPresetIndex:int):void;

        function set targetDate(value:Date):void;

        function reloadPlugins():void;

        function get settings():Settings;

        function get backgroundProcessModel():BackgroundProcessCollectionModel;

        function set backgroundProcessModel(value:BackgroundProcessCollectionModel):void;

		function openRecordAccount(sharedRecordAccount:Account):void;

		function get iCollaborationController():ICollaborationController;

		function sendCollaborationInvitation():void;

		function showSelectRecordView():void;

		function get navigator():ViewNavigator;

		function navigateHome(calledLocally:Boolean):void;

		function synchronizeBack(calledLocally:Boolean):void;
	}
}
