package renderers
{
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.utils.touch.DelayedDownTouchToState;
	import feathers.utils.touch.TapToSelect;

	import starling.display.Quad;
	import starling.text.TextFormat;

	public class BusinessRenderer extends LayoutGroupListItemRenderer
	{
		private var _ratingLabel:Label;
		private var _ratingImage:ImageLoader;
		private var _businessLabel:Label;
		private var _businessImage:ImageLoader
		private var _select:TapToSelect;
		private var _delay:DelayedDownTouchToState;

		public function BusinessRenderer()
		{
			super();
			this._select = new TapToSelect(this);
			this._delay = new DelayedDownTouchToState(this, changeState);
		}

		private function changeState(currentState:String):void
		{
			if(this._data)
			{
				if(currentState == "up")
				{
					if(this.isSelected)
					{
						_businessLabel.fontStyles.color = 0xFFFFFF;
						_ratingLabel.fontStyles.color = 0xFFFFFF;
					} else {
						this.backgroundSkin = new Quad(3, 3, 0xFFFFFF);
						_businessLabel.fontStyles.color = 0x000000;
						_ratingLabel.fontStyles.color = 0x000000;
					}
				}

				else if(currentState == "down")
				{
					this.backgroundSkin = new Quad(3, 3, 0xD50000);
					_businessLabel.fontStyles.color = 0xFFFFFF;
					_ratingLabel.fontStyles.color = 0xFFFFFF;
				}
			}
		}

		override protected function initialize():void
		{
			super.initialize();

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
				} else {
					_businessLabel.fontStyles.color = 0x000000;
					_ratingLabel.fontStyles.color = 0x000000;
				}

			} else {
				_businessLabel.text = "";
				_ratingLabel.text = "";
			}
		}

	}
}