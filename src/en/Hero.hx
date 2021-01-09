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
		var spd = 0.1;


		// Walk
		if( !controlsLocked() && ca.leftDist() > 0 ) {
			var xPow = Math.cos( ca.leftAngle() );
			dx += xPow * ca.leftDist() * spd * ( 0.4+0.6*cd.getRatio("airControl") ) * tmod;
			var old = dir;
			dir = M.fabs(xPow)>=0.1 ? M.sign(xPow) : dir;
		}
		else
			dx*=Math.pow(0.8,tmod);


		#if debug
		// debug( M.pretty(hxd.Timer.fps(),1) );
		#end
	}
}