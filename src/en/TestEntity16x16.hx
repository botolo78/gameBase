package en;

class TestEntity16x16 extends Entity {
	public static var ALL : Array<TestEntity16x16> = [];
	var data : Entity_TestEntity16x16;

	public function new(e:Entity_TestEntity16x16) {
		super(e.cx, e.cy);
		ALL.push(this);
		gravityMul = 0;
		dy = 0;
		spr.set("testEntity16x16");
		game.scroller.add(spr, Const.DP_BG);
		level.setExtraCollision(cx,cy, true);
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
