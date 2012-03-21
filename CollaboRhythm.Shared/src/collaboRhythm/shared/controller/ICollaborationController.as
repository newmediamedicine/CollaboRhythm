package collaboRhythm.shared.controller
{
	import collaboRhythm.shared.model.ICollaborationModel;

	public interface ICollaborationController
	{
		function get collaborationModel():ICollaborationModel;

		function showRecordVideoView():void;

		function hideRecordVideoView():void;
	}
}
