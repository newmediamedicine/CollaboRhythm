package{
	
	import flash.display.Sprite;
	import flash.events.Event;
	// Classes used in this example
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	public class HelloWorld extends Sprite{
		
		public function HelloWorld(){
			
			
			
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World( gravity, doSleep);
			
			// set debug draw
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(this);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			m_world.SetDebugDraw(debugDraw);
			m_world.DrawDebugData();
			
			
			
			// Vars used to create bodies
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxShape:b2PolygonShape;
			var circleShape:b2CircleShape;
			
			
			
			// Add ground body
			bodyDef = new b2BodyDef();
			//bodyDef.position.Set(15, 19);
			bodyDef.position.Set(10, 12);
			//bodyDef.angle = 0.1;
			boxShape = new b2PolygonShape();
			boxShape.SetAsBox(30, 3);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = boxShape;
			fixtureDef.friction = 0.3;
			fixtureDef.density = 0; // static bodies require zero density
			// Add sprite to body userData
			bodyDef.userData = new PhysGround();
			bodyDef.userData.width = 30 * 2 * 30; 
			bodyDef.userData.height = 30 * 2 * 3; 
			addChild(bodyDef.userData);
			body = m_world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			// Add some objects
			for (var i:int = 1; i < 10; i++){
				bodyDef = new b2BodyDef();
				bodyDef.position.x = Math.random() * 15 + 5;
				bodyDef.position.y = Math.random() * 10;
				var rX:Number = Math.random() + 0.5;
				var rY:Number = Math.random() + 0.5;
				// Box
				if (Math.random() < 0.5){
					boxShape = new b2PolygonShape();
					boxShape.SetAsBox(rX, rY);
					fixtureDef.shape = boxShape;
					fixtureDef.density = 1.0;
					fixtureDef.friction = 0.5;
					fixtureDef.restitution = 0.2;
					bodyDef.userData = new PhysBox();
					bodyDef.userData.width = rX * 2 * 30; 
					bodyDef.userData.height = rY * 2 * 30; 
					body = m_world.CreateBody(bodyDef);
					body.CreateFixture(fixtureDef);
				} 
				// Circle
				else {
					circleShape = new b2CircleShape(rX);
					fixtureDef.shape = circleShape;
					fixtureDef.density = 1.0;
					fixtureDef.friction = 0.5;
					fixtureDef.restitution = 0.2;
					bodyDef.userData = new PhysCircle();
					bodyDef.userData.width = rX * 2 * 30; 
					bodyDef.userData.height = rX * 2 * 30; 
					body = m_world.CreateBody(bodyDef);
					body.CreateFixture(fixtureDef);
				}
				addChild(bodyDef.userData);
			}
			
		}
		
		public function Update(e:Event):void{
			
			m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			
			// Go through body list and update sprite positions/rotations
			for (var bb:b2Body = m_world.GetBodyList(); bb; bb = bb.GetNext()){
				if (bb.GetUserData() is Sprite){
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x = bb.GetPosition().x * 30;
					sprite.y = bb.GetPosition().y * 30;
					sprite.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
			
		}
		
		public var m_world:b2World;
		public var m_velocityIterations:int = 10;
		public var m_positionIterations:int = 10;
		public var m_timeStep:Number = 1.0/30.0;
		
	}

}