package renderers
{
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.utils.touch.TapToSelect;

	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextFormat;

	public class BusinessRenderer extends LayoutGroupListItemRenderer
	{
		private var _ratingLabel:Label;
		private var _ratingImage:ImageLoader;
		private var _businessLabel:Label;
		private var _businessImage:ImageLoader
		private var _select:TapToSelect;
		private var _currentState = ButtonState.UP;
		protected var touchID:int = -1;

		public function get currentState():String
		{
			return this._currentState;
		}

		public function set currentState(value:String):void
		{
			if (this._currentState == value) {
				return;
			}
			this._currentState = value;
			this.invalidate(INVALIDATION_FLAG_STATE);
		}

		public function BusinessRenderer()
		{
			super();
			this._select = new TapToSelect(this); //This helper allows our ItemRenderer to dispatch the starling.events.Event.CHANGE event.
		}

		override protected function initialize():void
		{
			super.initialize();

			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);

			this.layout = new AnchorLayout();
			this.height = 80;
			this.isQuickHitAreaEnabled = true;
			this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
			this.backgroundSelectedSkin = new Quad(3, 3, 0xD50000);

			_ratingImage = new ImageLoader();
			_ratingImage.layoutData = new AnchorLayoutData(NaN, 10, NaN, NaN, NaN, -10);
			_ratingImage.width = 65;
			_ratingImage.height = 15;
			this.addChild(_ratingImage);

			_ratingLabel = new Label();
			_ratingLabel.layoutData = new AnchorLayoutData(NaN, 10, NaN, NaN, NaN, 10);
			_ratingLabel.fontStyles = new TextFormat("_sans", 10, 0x00000, "center");
			_ratingLabel.width = 65;
			this.addChild(_ratingLabel);

			_businessImage = new ImageLoader();
			_businessImage.layoutData = new AnchorLayoutData(NaN, NaN, NaN, 10, NaN, 0);
			_businessImage.width = _businessImage.height = 60;
			this.addChild(_businessImage);

			_businessLabel = new Label();
			_businessLabel.wordWrap = true;
			_businessLabel.layoutData = new AnchorLayoutData(5, 80, 5, 85);
			_businessLabel.fontStyles = new TextFormat("_sans", 14, 0x000000, "left");
			_businessLabel.fontStyles.leading = 5;
			this.addChild(_businessLabel);

		}

		override protected function commitData():void
		{
			if (this._data && this._owner) {

				this._businessLabel.fontStyles.color = 0x000000;
				this._ratingLabel.fontStyles.color = 0x000000;
				this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);

				var path:String = _data.image_url;
				path = path.substr(0, path.length - 5);

				_businessImage.source = path + "m.jpg";

				_ratingImage.source = "assets/yelp/" + _data.rating + ".png";
				_businessLabel.text = "<b>" + _data.name + "</b>" + "\n" + _data.location.address1;
				_ratingLabel.text = _data.review_count + " review(s)";

				if(this.isSelected)
				{
					_businessLabel.fontStyles.color = 0xFFFFFF;
					_ratingLabel.fontStyles.color = 0xFFFFFF;
				}

			} else {
				_businessLabel.text = "";
				_ratingLabel.text = "";
			}
		}

		private function touchHandler(event:TouchEvent):void
		{
			if (!this._isEnabled) {
				this.touchID = -1;
				this.currentState = ButtonState.UP;
				return;
			}

			if (this.touchID >= 0) {
				var touch:Touch = event.getTouch(this, null, this.touchID);

				if (!touch) {
					return;
				}

				if (touch.phase == TouchPhase.ENDED) {
					this.currentState = ButtonState.UP;
					this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);

					if(this.isSelected)
					{
						_businessLabel.fontStyles.color = 0xFFFFFF;
						_ratingLabel.fontStyles.color = 0xFFFFFF;
					} else {
						this._businessLabel.fontStyles.color = 0x000000;
						this._ratingLabel.fontStyles.color = 0x000000;
					}

					this.touchID = -1;
				}
				return;
			}
			else {
				touch = event.getTouch(this, TouchPhase.BEGAN);

				if (!touch) {
					return;
				}

				this.currentState = ButtonState.DOWN;
				this.backgroundSkin = new Quad(3, 3, 0xD50000);
				this._businessLabel.fontStyles.color = 0xFFFFFF;
				this._ratingLabel.fontStyles.color = 0xFFFFFF;

				this.touchID = touch.id;
			}
		}

		private function removedFromStageHandler(event:Event):void
		{
			this.touchID = -1;
		}

	}
}