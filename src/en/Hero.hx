package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	var shadow : h2d.filter.DropShadow;

	public function new(e:Entity_Hero) {
		super(e.cx, e.cy);

		bumpFrict = 0.88;
		ca = Main.ME.controller.createAccess("hero");
		ca.setLeftDeadZone(0.2);

		spr.anim.registerStateAnim("heroIdle",0);

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
		var spd = 0.030;

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
		else
			dx*=Math.pow(0.8,tmod);


		// Jump
		var jumpKeyboardDown = ca.isKeyboardDown(K.Z) || ca.isKeyboardDown(K.W) || ca.isKeyboardDown(K.UP);
		if( !controlsLocked() && ca.aPressed() && ( !climbing && cd.has("onGroundRecently") || climbing && !jumpKeyboardDown ) ) {
			trace("jump");
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
				dy = -0.07;
				cd.setS("jumpForce",0.1);
				cd.setS("jumpExtra",0.1);
			}
		}
		else if( cd.has("jumpExtra") && ca.aDown() )
			dy-=0.04*tmod;

		if( cd.has("jumpForce") && ca.aDown() )
			dy -= 0.05 * cd.getRatio("jumpForce") * tmod;	

		#if debug
		// debug( M.pretty(hxd.Timer.fps(),1) );
		#end
	}
}