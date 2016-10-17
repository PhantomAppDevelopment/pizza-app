package
{
	public class Constants
	{
		//Customize with your Yelp prooject values
		public static const YELP_APP_ID:String = "";
		public static const YELP_APP_SECRET:String = "";

		//Customize with your Firebase project values
		public static const FIREBASE_API_KEY:String = "";
		private static const PROJECT_ID:String = "YOUR-FIREBASE-PROJECT-ID";

		//Auth and Storage URLs
		public static const FIREBASE_STORAGE_URL:String = "https://firebasestorage.googleapis.com/v0/b/" + PROJECT_ID + ".appspot.com/o/";
		public static const FIREBASE_REDIRECT_URL:String = "https://" + PROJECT_ID + ".firebaseapp.com/__/auth/handler";

		//Database URLs
		public static const FIREBASE_IMAGES_GALLERY_URL:String = 'https://' + PROJECT_ID + '.firebaseio.com/images';
		public static const FIREBASE_IMAGES_COMMENTS_BASE_URL:String = 'https://' + PROJECT_ID + '.firebaseio.com/images_comments/';
		public static const FIREBASE_IMAGES_VOTES_BASE_URL:String = 'https://' + PROJECT_ID + '.firebaseio.com/images_votes/';
		public static const FIREBASE_CHATROOMS_URL:String = 'https://' + PROJECT_ID + '.firebaseio.com/rooms.json';
		public static const FIREBASE_CHATROOM_BASE_URL:String = 'https://' + PROJECT_ID + '.firebaseio.com/messages/';

		//These URLs are used by the Auth service when using Federated login providers
		public static const FIREBASE_CREATE_AUTH_URL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/createAuthUri?key=" + FIREBASE_API_KEY;
		public static const FIREBASE_VERIFY_ASSERTION_URL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyAssertion?key=" + FIREBASE_API_KEY;
		public static const FIREBASE_ACCOUNT_SETINFO_URL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/setAccountInfo?key=" + FIREBASE_API_KEY;
		//This URL generates an access_token that is used to sign Auth and Storage requests
		public static const FIREBASE_AUTH_TOKEN_URL:String = "https://securetoken.googleapis.com/v1/token?key=" + FIREBASE_API_KEY;

	}
}