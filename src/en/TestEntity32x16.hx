package en;

class TestEntity32x16 extends Entity {
	public static var ALL : Array<TestEntity32x16> = [];
	var data : Entity_TestEntity16x16;

	public function new(e:Entity_TestEntity32x16) {
		super(e.cx, e.cy);
		ALL.push(this);
		gravityMul = 0;
		dy = 0;
		spr.set("testEntity32x16");
		game.scroller.add(spr, Const.DP_BG);

		// Set bound values and collision
		set_wid(32);
		// circularCollisions = true;
		level.setExtraCollision(cx,cy, true);
		level.setExtraCollision(cx+1,cy, true);
		spr.setCenterRatio(0.25,1);
	}

	public function delayedDie() {
		super.onDie();
	}	

	override function dispose() {
		super.dispose();
	}

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();


    }
}
