package collaboRhythm.plugins.foraD40b.controller
{
    import collaboRhythm.shared.controller.apps.AppControllerBase;
    import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

    public class ForaD40bAppController extends AppControllerBase
    {
        public static const DEFAULT_NAME:String = "FORA D40b";

        public function ForaD40bAppController(constructorParams:AppControllerConstructorParams)
        {
            super(constructorParams);
        }

        public override function get defaultName():String
        {
            return DEFAULT_NAME;
        }

    }
}
