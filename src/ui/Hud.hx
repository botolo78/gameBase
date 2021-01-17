package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flow : h2d.Flow;
	var life : h2d.Flow;
	public var diamonds : Text;

	var invalidated = true;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		// flow.debug=true;
		flow.verticalSpacing = 0;		

		var mBox = new h2d.Flow(flow);
		mBox.padding = 10;
		mBox.paddingTop = 24;
		mBox.verticalAlign = Middle;
		
		var diamondsIcon = Assets.tiles.h_get("itemDiamond1", mBox);
		diamondsIcon.scaleX = 2.5;
		diamondsIcon.scaleY = 2.5;
		diamonds = new Text(Assets.fontMedium, mBox);
		diamonds.dropShadow  = {dx: 0, dy: 2, color:0xFF0000, alpha:0.9};

		life = new h2d.Flow(flow);
		life.paddingLeft = 13;
		life.layout = Vertical;		
	}

	public function setDiamonds(v:Int) {
		diamonds.text = Std.string(v);
		diamonds.textColor = 0xFFFFFF;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate() invalidated = true;

	function render() {
		flow.reflow();		
		setDiamonds(game.get_collDiamonds());

		life.removeChildren();
		for(i in 0...Game.ME.heroMaxLife) {
			var lifeIcon = Assets.tiles.h_get(i+1<=Game.ME.heroLife ? "itemHeart1" : "itemHeart0", life);		
			lifeIcon.scaleX = 1.5;
			lifeIcon.scaleY = 1.5;
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
