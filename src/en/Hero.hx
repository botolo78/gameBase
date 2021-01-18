package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;
	var jumps : Int;

	public function new(e:Entity_Hero) {
		super(e.cx, e.cy);

		bumpFrict = 0.88;
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);

		// Idle
		spr.anim.registerStateAnim("heroIdle",0, ()->!isCrouching());
		spr.anim.registerStateAnim("heroCrouchIdle",0, ()->isCrouching());
		// Jump
		spr.anim.registerStateAnim("heroJumpUp",5, ()-> isJumpingUp() );
		spr.anim.registerStateAnim("heroJumpDown",5, 0.9,  ()-> isJumpingDown() );
		// Run
		spr.anim.registerStateAnim("heroRun",5, ()-> isRunning() && !isCrouching());		
		spr.anim.registerStateAnim("heroCrouchRun",6, ()->M.fabs(dx)>=0.05/tmod && isCrouching() );	

		// Set bound values (to be used for non solid entities)
		circularCollisions = true;

	}

	// States
	public inline function isIdle() { return isAlive() && state == Idle; }
	public inline function isRunning() { return isAlive() && state == Run; }
	public inline function isJumpingUp() { return isAlive() && state == JumpUp; }
	public inline function isJumpingDown() { return isAlive() && state == JumpDown; }



	override function startClimbing() {
		super.startClimbing();
		cd.unset("jumpForce");
		cd.unset("jumpExtra");
	}


	override function onLand(fallCHei:Float) {
		super.onLand(fallCHei);
		jumps = 0;
		if( fallCHei>=5 ) {
			Assets.SLIB.land0(1);
			game.popText(headX, headY, "#$@&%*!", 0xff4724);
		}
		else
			Assets.SLIB.land1(0.5 * M.fmin(1,fallCHei/2));

		var impact = M.fmin(1, fallCHei/6);
		dx *= (1-impact)*0.5;
		game.camera.bump(0, 2*impact);
		setSquashY(1-impact*0.7);

		if( fallCHei>=9 ) {
			lockControlS(0.3);
			game.camera.shakeS(1,0.3);
			cd.setS("heavyLand",0.3);
		}
		else if( fallCHei>=3 )
			lockControlS(0.03*impact);
		cd.setF("justLanded",5);
	}

	public inline function isCrouching() {
		return isAlive() && ( level.hasCollision(cx,cy-1) && level.hasCollision(cx,cy+1) || cd.has("heavyLand") );
	}


	public function jump() {
		var jumpKeyboardDown = ca.isKeyboardDown(K.Z) || ca.isKeyboardDown(K.W) || ca.isKeyboardDown(K.UP);
		if( !controlsLocked() && ca.aPressed() && !isCrouching() && ( !climbing && cd.has("onGroundRecently") || climbing && !jumpKeyboardDown ) ) {
			if( climbing ) {
				stopClimbing();
				cd.setS("climbLock",0.2);
				dx = dir*0.1;
				if( dy>0 )
					dy = 0.2;
				else {
					dy = -0.05;
					cd.setS("jumpForce",0.1);
					cd.setS("jumpExtra",0.1);
				}
			}
			else {
				setSquashX(0.7);
				dy = -0.1;
				cd.setS("jumpForce",0.1);
				cd.setS("jumpExtra",0.2);
			}
			jumps += 1;
		}
		else if( cd.has("jumpExtra") && ca.aDown() )
			dy -= 0.04*tmod;

		if( cd.has("jumpForce") && ca.aDown() )
			dy -= 0.05 * cd.getRatio("jumpForce") * tmod;	

		// Allow double jump for 0.2 seconds
		if ( (isJumpingUp() || isJumpingDown()) && ca.aPressed() ) {
			jumps += 1;
			if ( jumps == 2 )
				cd.setS("doubleJump",0.2);
		}
		if( !cd.has("disableDoubleJump") && cd.has("doubleJump") && ca.aDown() ) {
			dy = -0.2;
			cd.setS("jumpForce",0.1);
		}

		// Disable double jump when too close to an obstacle above
		if ( level.hasCollision(cx,cy-1) ) 
			cd.setMs("disableDoubleJump",300);


		else if( cd.has("bumperJump") ) {
			dy += -0.07*tmod;
		}
		else if( cd.has("extraJump") ) {
			dy += -0.04*tmod;
		}

	}
	
	override function dispose() {
		super.dispose();
		ca.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
		var spd = 0.025;

		if( onGround || climbing ) {
			cd.setS("onGroundRecently",0.1);
			cd.setS("airControl",10);
		}

		// Walk
		if( !controlsLocked() && ca.leftDist() > 0 ) {
			var xPow = Math.cos( ca.leftAngle() );
			dx += xPow * ca.leftDist() * spd * ( 0.4+0.6*cd.getRatio("airControl") ) * tmod;
			var old = dir;
			dir = M.fabs(xPow)>=0.1 ? M.sign(xPow) : dir;
		}
		else {
			dx*=Math.pow(0.8,tmod);
		}

		// Jump
		jump();



		// Entities - Additional collisions and interactions

		// Interact with test entities 16x16 (solid)
		for(e in en.TestEntity16x16.ALL) {

			// Entity is on the right
			if ( footXb == e.footXa && xr>=0.7 && footY <= e.footY && footY >= e.headY && dir == 1 ) {
				xr = 0.7;
				dx *= Math.pow(0.5,tmod);
				if ( !cd.has("hitRight") ) {
					cd.setMs("hitRight", 300);
					// trace("Right");
				}				
			}		
			// Entity is on the left
			if ( footXa == e.footXb && xr<=0.3 && footY <= e.footY && footY >= e.headY && dir == -1 ) {
				xr = 0.3;
				dx *= Math.pow(0.5,tmod);
				if ( !cd.has("hitLeft") ) {
					cd.setMs("hitLeft", 300);
					// trace("Left");
				}				
			}					
			// Entity is above
			if ( (footX >= e.footXa && footX <= e.footXb) && headY == e.footY && dy < 0 ) {
				if ( !cd.has("HitAbove") ) {
					cd.setMs("HitAbove", 300);
					dy *= Math.pow(0.5,tmod);
					// trace("Above");
				}
			}	
			// Entity is below
			if ( (footX >= e.footXa && footX <= e.footXb) && footY <= e.headY && cy+1 == e.cy && cd.has("justLanded") ) {
				if ( !cd.has("HitBelow") ) {
					cd.setMs("HitBelow", 300);
					// trace("Below");
				}
			}							

		}	




		// Interact with test entities 32x16 (solid)
		for(e in en.TestEntity32x16.ALL) {

			// Entity is on the right
			if ( footXb == e.footXa && xr>=0.7 && footY <= e.footY && footY >= e.headY && dir == 1 ) {
				xr = 0.7;
				dx *= Math.pow(0.5,tmod);
				if ( !cd.has("hitRight") ) {
					cd.setMs("hitRight", 300);
					// trace("Right");
				}				
			}		
			// Entity is on the left
			if ( footXa == e.footXb && xr<=0.3 && footY <= e.footY && footY >= e.headY && dir == -1 ) {
				xr = 0.3;
				dx *= Math.pow(0.5,tmod);
				if ( !cd.has("hitLeft") ) {
					cd.setMs("hitLeft", 300);
					// trace("Left");
				}				
			}				
			// Entity is above
			if ( (footX >= e.footXa && footX <= e.footXb) && headY == e.footY && dy < 0 ) {
				if ( !cd.has("HitAbove") ) {
					cd.setMs("HitAbove", 300);
					dy *= Math.pow(0.5,tmod);
					// trace("Above");
				}
			}	
			// Entity is below
			if ( (footX >= e.footXa && footX <= e.footXb) && footY <= e.headY && cy+1 == e.cy && cd.has("justLanded") ) {
				if ( !cd.has("HitBelow") ) {
					cd.setMs("HitBelow", 300);
					// trace("Below");
				}
			}								
		}	




		// // Circular collisions
		// if( hasCircularCollisions() ) {
		// 	var d = 0.;

		// 	// Interact with bumpers
		// 	for(e in en.Bumper.ALL) {
		// 		if( !cd.has("dead") && !cd.has("dieing") && e.isAlive() && !e.cd.has("open") && hasCircularCollisionsWith(e) ) {
		// 			d = M.dist(centerX,centerY, e.centerX,e.centerY);
		// 			if( d<=(radius+e.radius)-e.wid/2 ) {
		// 				e.onUse();
		// 				cancelVelocities();
		// 				cd.setS("bumperJump",0.2);
		// 				dy = -0.8;
		// 			}
		// 		}
		// 	}
		// }



		#if debug
		// debug( M.pretty(hxd.Timer.fps(),1) );
		// debug(state);
		// debug(game.get_heroLife());
		#end
	}
}