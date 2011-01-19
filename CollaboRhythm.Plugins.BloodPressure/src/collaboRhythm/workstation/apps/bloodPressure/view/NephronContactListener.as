package collaboRhythm.workstation.apps.bloodPressure.view
{
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	
	public class NephronContactListener extends b2ContactListener
	{
		public function NephronContactListener()
		{
			super();
		}
		
		public override function BeginContact(contact:b2Contact):void
		{
			var bodyA:b2Body = contact.GetFixtureA().GetBody();
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			
			if (bodyA != null && bodyB != null)
			{
				var bodyInfoA:BodyInfo = bodyA.GetUserData() as BodyInfo;
				var bodyInfoB:BodyInfo = bodyB.GetUserData() as BodyInfo;
				
				if (bodyInfoA != null && bodyInfoB != null)
				{
					updateBodiesOnContact(bodyInfoA, bodyInfoB);
					updateBodiesOnContact(bodyInfoB, bodyInfoA);
				}
			}
		}
		
		private function updateBodiesOnContact(bodyInfoA:BodyInfo, bodyInfoB:BodyInfo):void
		{
			if (bodyInfoA.isPlug && bodyInfoB.isSolute)
				bodyInfoB.hasBeenBlocked = true;
			else if (bodyInfoA.isSolute && bodyInfoB.isSolute && bodyInfoA.hasBeenBlocked)
				bodyInfoB.hasBeenBlocked = true;
		}
	}
}