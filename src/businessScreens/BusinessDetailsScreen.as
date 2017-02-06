package businessScreens
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.navigateToURL;

	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.text.TextFormat;
	import starling.utils.ScaleMode;

	import utils.NavigatorData;
	import utils.RoundedRect;

	public class BusinessDetailsScreen extends PanelScreen
	{
		public static const GO_DIRECTIONS:String = "goDirections";

		private var mainGroup:ScrollContainer;
		private var reviewsGroup:LayoutGroup;

		protected var _data:NavigatorData;

		public function get data():NavigatorData
		{
			return this._data;
		}

		public function set data(value:NavigatorData):void
		{
			this._data = value;
		}

		override protected function initialize():void
		{
			super.initialize();

			this.layout = new AnchorLayout();
			this.backButtonHandler = goBack;

			this.title = "Business Details";

			var backButton:Button = new Button();
			backButton.styleNameList.add("back-button");
			backButton.addEventListener(starling.events.Event.TRIGGERED, goBack);
			this.headerProperties.leftItems = new <DisplayObject>[backButton];

			var browserIcon:ImageLoader = new ImageLoader();
			browserIcon.source = "assets/icons/open_browser.png";
			browserIcon.width = browserIcon.height = 25;

			var browserButton:Button = new Button();
			browserButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
			{
				navigateToURL(new URLRequest(_data.currentBusiness.url));
			})
			browserButton.styleNameList.add("header-button");
			browserButton.defaultIcon = browserIcon;
			this.headerProperties.rightItems = new <DisplayObject>[browserButton];

			var layoutForMainGroup:VerticalLayout = new VerticalLayout();
			layoutForMainGroup.horizontalAlign = HorizontalAlign.CENTER;
			layoutForMainGroup.padding = 10;
			layoutForMainGroup.gap = 10;

			mainGroup = new ScrollContainer();
			mainGroup.hasElasticEdges = false;
			mainGroup.layout = layoutForMainGroup;
			mainGroup.layoutData = new AnchorLayoutData(10, 10, 10, 10, NaN, NaN);
			mainGroup.backgroundSkin = RoundedRect.createRoundedRect(0xFFFFFF);
			this.addChild(mainGroup);

			this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);
		}

		private function transitionComplete(event:starling.events.Event):void
		{
			this.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionComplete);

			var businessImage:ImageLoader = new ImageLoader();
			businessImage.layoutData = new VerticalLayoutData(100, NaN);
			businessImage.minWidth = businessImage.minHeight = 50;
			if (_data.currentBusiness.image_url != "") {
				businessImage.source = _data.currentBusiness.image_url;
			} else {
				businessImage.source = "assets/icons/person.png";
			}

			mainGroup.addChild(businessImage);

			var businessName:Label = new Label();
			businessName.layoutData = new VerticalLayoutData(100, NaN);
			businessName.text = _data.currentBusiness.name;
			businessName.fontStyles = new TextFormat("_sans", 20, 0x000000);
			businessName.fontStyles.bold = true;
			businessName.wordWrap = true;
			mainGroup.addChild(businessName);

			var mainRatingImage:ImageLoader = new ImageLoader();
			mainRatingImage.source = "assets/yelp/" + _data.currentBusiness.rating + ".png";
			mainRatingImage.height = 20;
			mainRatingImage.width = 106;
			mainGroup.addChild(mainRatingImage);

			var ratingsCount:Label = new Label();
			ratingsCount.text = _data.currentBusiness.review_count + " review(s)";
			mainGroup.addChild(ratingsCount);

			var addressLabel:Label = new Label();
			addressLabel.fontStyles = new TextFormat("_sans", 18, 0x000000);
			addressLabel.layoutData = new VerticalLayoutData(100, NaN);
			addressLabel.wordWrap = true;
			addressLabel.paddingBottom = 10;
			addressLabel.text = _data.currentBusiness.location.address1 + "\n" + _data.currentBusiness.location.city + ", " + _data.currentBusiness.location.state;
			mainGroup.addChild(addressLabel);

			reviewsGroup = new LayoutGroup();
			mainGroup.addChild(reviewsGroup);

			var spacer1:LayoutGroup = new LayoutGroup();
			spacer1.layoutData = new VerticalLayoutData(100, 100);
			mainGroup.addChild(spacer1);

			if (_data.currentBusiness.phone) {
				var phoneIcon:ImageLoader = new ImageLoader();
				phoneIcon.source = "assets/icons/phone.png";
				phoneIcon.width = phoneIcon.height = 25;

				var phoneButton:Button = new Button();
				phoneButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
				{
					navigateToURL(new URLRequest("tel:" + _data.currentBusiness.phone));
				})
				phoneButton.layoutData = new VerticalLayoutData(100, NaN);
				phoneButton.styleNameList.add("rounded-button");
				phoneButton.label = "Call: " + _data.currentBusiness.phone;
				phoneButton.defaultIcon = phoneIcon;
				mainGroup.addChild(phoneButton);
			}

			if (_data.currentBusiness.coordinates.latitude) {
				var directionsIcon:ImageLoader = new ImageLoader();
				directionsIcon.source = "assets/icons/directions.png";
				directionsIcon.width = directionsIcon.height = 25;

				var directionsButton:Button = new Button();
				directionsButton.addEventListener(starling.events.Event.TRIGGERED, function ():void
				{
					dispatchEventWith(GO_DIRECTIONS);
				})
				directionsButton.layoutData = new VerticalLayoutData(100, NaN);
				directionsButton.styleNameList.add("rounded-button");
				directionsButton.label = "Get Directions";
				directionsButton.defaultIcon = directionsIcon;
				mainGroup.addChild(directionsButton);
			}

			getReviews();
		}

		private function getReviews():void
		{
			var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + _data.yelpAccessToken);

			var request:URLRequest = new URLRequest("https://api.yelp.com/v3/businesses/" + _data.currentBusiness.id + "/reviews");
			request.requestHeaders.push(header);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, yelpResponse);
			loader.addEventListener(IOErrorEvent.IO_ERROR, yelpError);
			loader.load(request);
		}

		private function yelpResponse(event:flash.events.Event):void
		{
			event.currentTarget.removeEventListener(flash.events.Event.COMPLETE, yelpResponse);

			var layoutForReviewsGroup:VerticalLayout = new VerticalLayout();
			layoutForReviewsGroup.gap = 10;

			reviewsGroup.layout = layoutForReviewsGroup;
			reviewsGroup.layoutData = new VerticalLayoutData(100, NaN);

			var rawData:Object = JSON.parse(event.currentTarget.data);

			var reviewLabel:Label = new Label();
			reviewLabel.layoutData = new VerticalLayoutData(100, NaN);
			reviewLabel.text = "Top Reviews";
			reviewLabel.fontStyles = new TextFormat("_sans", 20, 0x000000);
			reviewLabel.fontStyles.bold = true;
			reviewsGroup.addChild(reviewLabel);

			for each(var item:Object in rawData.reviews) {
				reviewsGroup.addChild(createReviewBlock(item));
			}
		}

		private function createReviewBlock(review:Object):DisplayObject
		{
			var group:LayoutGroup = new LayoutGroup();
			group.layout = new AnchorLayout();
			group.layoutData = new VerticalLayoutData(100, NaN);

			var avatar:ImageLoader = new ImageLoader();
			avatar.scaleMode = ScaleMode.NO_BORDER;

			//IF the user doesn't have an avatar we use a placeholder one
			if (review.user.image_url == null) {
				avatar.color = 0x6666663;
				avatar.source = "assets/icons/account_circle.png";
			} else {
				var mask:Canvas = new Canvas();
				mask.drawCircle(25, 25, 25);

				avatar.mask = mask;
				avatar.source = review.user.image_url;
			}

			avatar.width = avatar.height = 50;
			avatar.layoutData = new AnchorLayoutData(5, NaN, NaN, 10, NaN, NaN);
			group.addChild(avatar);

			var nameLabel:Label = new Label();
			nameLabel.layoutData = new AnchorLayoutData(5, NaN, NaN, 70, NaN, NaN);
			nameLabel.text = "<b>" + review.user.name + "</b>";
			group.addChild(nameLabel);

			var ratingImage:ImageLoader = new ImageLoader();
			ratingImage.width = 106;
			ratingImage.height = 20;
			ratingImage.source = "assets/yelp/" + review.rating + ".png";
			ratingImage.layoutData = new AnchorLayoutData(30, NaN, NaN, 70, NaN, NaN);
			group.addChild(ratingImage);

			var reviewLabel:Label = new Label();
			reviewLabel.layoutData = new AnchorLayoutData(65, 10, 0, 10, NaN, NaN);
			reviewLabel.textRendererProperties.wordWrap = true;
			reviewLabel.text = review.text;
			group.addChild(reviewLabel);

			return group;
		}

		private function yelpError(event:flash.events.Event):void
		{
			trace(event.currentTarget.data);
		}

		private function goBack():void
		{
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}

	}
}