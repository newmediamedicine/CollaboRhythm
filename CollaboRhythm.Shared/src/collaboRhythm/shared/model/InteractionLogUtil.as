package collaboRhythm.shared.model
{

	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerBase;

	import mx.logging.ILogger;

	public class InteractionLogUtil
	{
		public function InteractionLogUtil()
		{
		}

		public static function log(logger:ILogger, action:String, viaMechanism:String = null, additionalMessage:String = null):void
		{
			var viaClause:String = viaMechanism ? " (via " + viaMechanism + ")" : "";
			logger.info("User interaction: {0}{1}{2}", action, viaClause, additionalMessage ? " " + additionalMessage : "");
		}

		public static function logAppInstance(logger:ILogger, action:String, viaMechanism:String, appInstance:AppControllerBase):void
		{
			log(logger, action, viaMechanism, "app=" + appInstance.appClassName);
		}
		public static function logApp(logger:ILogger, action:String, viaMechanism:String, appControllerClass:Class):void
		{
			log(logger, action, viaMechanism, "app=" + ReflectionUtils.getClassInfo(appControllerClass).name);
		}
	}
}
