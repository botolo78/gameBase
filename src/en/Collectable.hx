package en;

class Collectable extends Entity {
	public static var ALL : Array<Collectable> = [];
	public var type : Collectables;
	var data : Entity_Collectable;
	public var origin : Null<LPoint>;

	public function new(e:Entity_Collectable) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		type = e.f_collectables; 
		origin = makePoint();
		circularCollisions = true;
		set_hei(12);
		set_radius(6);
		spr.setCenterRatio(0.5,0.90);
		spr.anim.setGlobalSpeed(0.05);
		spr.anim.registerStateAnim("collected",1, 0.5, ()-> cd.has("collected"));    
		switch type {
            case Heart: 
				spr.anim.registerStateAnim("itemHeart",0, ()-> isAlive());
			case Diamond: 
				spr.anim.registerStateAnim("itemDiamond",0, ()-> isAlive());
		};
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}


	public function delayedDie() {
		super.onDie();
	
	}

	override function update() {
		super.update();
		gravityMul = 0.;
		dy = 0.;

		// Circular collisions
		if( hasCircularCollisions() ) {
			var d = 0.;
		// Interact with hero
			if( isAlive() && !cd.has("collected") ) {
				d = M.dist(centerX,centerY, hero.centerX,hero.centerY);
				if( d<=(radius+hero.radius) ) {
					switch type {
						case Heart: 
							if ( game.get_heroLife() < game.heroMaxLife ) {
								cd.setS("collected",Const.INFINITE);
								Assets.SLIB.pick(0.8);
								spr.anim.setGlobalSpeed(0.35);
								spr.setCenterRatio(0.5,0.75);				
								game.set_collHearts(1);
								game.set_heroLife(1);
								hud.invalidate();
								// Delay death to display popping animation
								game.delayer.addS(()->{
									delayedDie();
								}, 0.35);								
							}
						case Diamond: 
							cd.setS("collected",Const.INFINITE);
							Assets.SLIB.pick(0.8);
							spr.anim.setGlobalSpeed(0.35);
							spr.setCenterRatio(0.5,0.75);								
							game.set_collDiamonds(1);
							hud.invalidate();
							hud.shake();
							// Delay death to display popping animation
							game.delayer.addS(()->{
								delayedDie();
							}, 0.35);							
					};					

				}
			}
		}		
	}
}