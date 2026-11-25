import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  AppLanguage._();

  static const _preferenceKey = 'yatra_flow.app_language.v1';
  static final ValueNotifier<String> language = ValueNotifier<String>(
    'English',
  );

  static String get current => language.value;
  static bool get isHindi => current == 'Hindi';
  static String get languageCode => isHindi ? 'hi' : 'en';

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_preferenceKey);
    if (savedLanguage == 'Hindi' || savedLanguage == 'English') {
      language.value = savedLanguage!;
    }
  }

  static Future<void> setLanguage(String value) async {
    final selectedLanguage = value == 'Hindi' ? 'Hindi' : 'English';
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _preferenceKey,
        selectedLanguage,
      );
      if (!saved) throw const AppLanguagePersistenceException();
    } on PlatformException {
      throw const AppLanguagePersistenceException();
    } on MissingPluginException {
      throw const AppLanguagePersistenceException();
    }
    language.value = selectedLanguage;
  }

  static String text(String english, String hindi) => isHindi ? hindi : english;

  static String translate(String english) =>
      isHindi ? (_hindiTranslations[english] ?? english) : english;

  static const _hindiTranslations = <String, String>{
    'Back': 'वापस',
    'Back to Home': 'होम पर वापस जाएँ',
    'Cancel': 'रद्द करें',
    'Continue': 'जारी रखें',
    'Done': 'पूरा हुआ',
    'Edit profile': 'प्रोफ़ाइल संपादित करें',
    'Home': 'होम',
    'Guide': 'गाइड',
    'Safety': 'सुरक्षा',
    'You': 'आप',
    'Menu': 'मेन्यू',
    'Profile': 'प्रोफ़ाइल',
    'Close': 'बंद करें',
    'My profile': 'मेरी प्रोफ़ाइल',
    'User ID': 'यूज़र आईडी',
    'Your details, all in one place': 'आपकी सभी जानकारी एक ही जगह',
    'Personal information': 'व्यक्तिगत जानकारी',
    'Email address': 'ईमेल पता',
    'Phone number': 'फ़ोन नंबर',
    'Home city': 'गृह नगर',
    'Travel preferences': 'यात्रा की प्राथमिकताएँ',
    'Language': 'भाषा',
    'Travel style': 'यात्रा शैली',
    'EMERGENCY CONTACT': 'आपातकालीन संपर्क',
    'Edit Profile': 'प्रोफ़ाइल संपादित करें',
    'Personal Information': 'व्यक्तिगत जानकारी',
    'Full Name *': 'पूरा नाम *',
    'Enter your full name': 'अपना पूरा नाम दर्ज करें',
    'Email Address *': 'ईमेल पता *',
    'Phone Number *': 'फ़ोन नंबर *',
    'Home City *': 'गृह नगर *',
    'Travel Preferences': 'यात्रा की प्राथमिकताएँ',
    'Travel Style': 'यात्रा शैली',
    'Emergency Contact': 'आपातकालीन संपर्क',
    'Contact Name *': 'संपर्क का नाम *',
    'Enter emergency contact name': 'आपातकालीन संपर्क का नाम दर्ज करें',
    'Contact Number *': 'संपर्क नंबर *',
    'Enter emergency contact number': 'आपातकालीन संपर्क नंबर दर्ज करें',
    'Account Settings': 'खाता सेटिंग',
    'Notification Preferences': 'सूचनाओं की प्राथमिकताएँ',
    'Get updates about new destinations': 'नए गंतव्यों के अपडेट पाएँ',
    'Privacy Settings': 'गोपनीयता सेटिंग',
    'Control your profile visibility':
        'अपनी प्रोफ़ाइल की दृश्यता नियंत्रित करें',
    'Save Changes': 'बदलाव सहेजें',
    'Change Photo': 'फ़ोटो बदलें',
    'JPG, PNG • Max 2 MB': 'JPG, PNG • अधिकतम 2 MB',
    'Full name is required.': 'पूरा नाम आवश्यक है।',
    'Email address is required.': 'ईमेल पता आवश्यक है।',
    'Enter a valid email address.': 'मान्य ईमेल पता दर्ज करें।',
    'Enter a valid phone number.': 'मान्य फ़ोन नंबर दर्ज करें।',
    'Emergency contact name is required.': 'आपातकालीन संपर्क का नाम आवश्यक है।',
    'Enter a valid emergency contact number.':
        'मान्य आपातकालीन संपर्क नंबर दर्ज करें।',
    'Could not update the app language. Please try again.':
        'ऐप की भाषा अपडेट नहीं हो सकी। कृपया फिर से कोशिश करें।',
    'Could not save your language preference. Please try again.':
        'भाषा की प्राथमिकता सहेजी नहीं जा सकी। कृपया फिर से कोशिश करें।',
    'Public profile': 'सार्वजनिक प्रोफ़ाइल',
    'Try again': 'फिर से कोशिश करें',
    'Profile updated.': 'प्रोफ़ाइल अपडेट की गई।',
    'Profile data could not be loaded. Please try again.':
        'प्रोफ़ाइल जानकारी लोड नहीं हो सकी। कृपया फिर से कोशिश करें।',
    'Saved profile data is invalid. Please try again.':
        'सहेजी गई प्रोफ़ाइल जानकारी मान्य नहीं है। कृपया फिर से कोशिश करें।',
    'Choose a JPG or PNG photo.': 'JPG या PNG फ़ोटो चुनें।',
    'Choose a photo smaller than 2 MB.': '2 MB से छोटी फ़ोटो चुनें।',
    'Could not open that photo. Please try again.':
        'फ़ोटो नहीं खुल सकी। कृपया फिर से कोशिश करें।',
    'Photo selection is not available on this device.':
        'इस डिवाइस पर फ़ोटो चुनने की सुविधा उपलब्ध नहीं है।',
    'This device does not support photo selection.':
        'यह डिवाइस फ़ोटो चुनने की सुविधा का समर्थन नहीं करता।',
    'Your changes could not be saved. Please try again.':
        'आपके बदलाव सहेजे नहीं जा सके। कृपया फिर से कोशिश करें।',
    'Back to profile': 'प्रोफ़ाइल पर वापस जाएँ',
    'Report a Problem': 'समस्या की रिपोर्ट करें',
    'Help us make this destination better for everyone.':
        'इस स्थान को सभी के लिए बेहतर बनाने में हमारी मदद करें।',
    'What type of problem are you reporting?':
        'आप किस प्रकार की समस्या की रिपोर्ट कर रहे हैं?',
    'Describe the problem': 'समस्या का विवरण दें',
    'Tell us a little more about what happened...':
        'क्या हुआ, इसके बारे में थोड़ा और बताएँ...',
    'Add a photo': 'फ़ोटो जोड़ें',
    'Add a Photo': 'फ़ोटो जोड़ें',
    'Open Camera': 'कैमरा खोलें',
    'Select from Files': 'फ़ाइलों से चुनें',
    'Choose a JPG, JPEG, PNG, or WebP image.':
        'JPG, JPEG, PNG या WebP छवि चुनें।',
    'Could not open the selected image. Please try again.':
        'चुनी गई छवि नहीं खुल सकी। कृपया फिर से कोशिश करें।',
    'Image selection is not available on this device.':
        'इस डिवाइस पर छवि चुनने की सुविधा उपलब्ध नहीं है।',
    'This device does not support selecting an image.':
        'यह डिवाइस छवि चुनने की सुविधा का समर्थन नहीं करता।',
    'Please select a problem category to continue.':
        'आगे बढ़ने के लिए समस्या की श्रेणी चुनें।',
    'Continue to Review': 'समीक्षा के लिए आगे बढ़ें',
    'Cleanliness': 'स्वच्छता',
    'Safety Issue': 'सुरक्षा समस्या',
    'Water Facilities': 'पानी की सुविधाएँ',
    'Overcrowding': 'भीड़भाड़',
    'Parking': 'पार्किंग',
    'Infrastructure': 'बुनियादी ढाँचा',
    'Others': 'अन्य',
    'Review Your Report': 'अपनी रिपोर्ट की समीक्षा करें',
    'Please check the details before submitting.':
        'सबमिट करने से पहले विवरण जाँच लें।',
    'CATEGORY': 'श्रेणी',
    'LOCATION': 'स्थान',
    'DESCRIPTION': 'विवरण',
    'PHOTO': 'फ़ोटो',
    'No description provided.': 'कोई विवरण नहीं दिया गया।',
    'No photo added': 'कोई फ़ोटो नहीं जोड़ी गई',
    'Photo preview unavailable': 'फ़ोटो का पूर्वावलोकन उपलब्ध नहीं है',
    'Submit Report': 'रिपोर्ट सबमिट करें',
    'Report Submitted!': 'रिपोर्ट सबमिट हो गई!',
    'Thank you for helping us improve this destination.':
        'इस स्थान को बेहतर बनाने में मदद करने के लिए धन्यवाद।',
    'REPORT ID': 'रिपोर्ट आईडी',
    'Keep this ID for reference': 'संदर्भ के लिए यह आईडी सुरक्षित रखें',
    'No camera was found on this device.': 'इस डिवाइस पर कोई कैमरा नहीं मिला।',
    'Camera access is not supported on this device.':
        'इस डिवाइस पर कैमरा एक्सेस उपलब्ध नहीं है।',
    'Could not access the camera. Please try again.':
        'कैमरे का उपयोग नहीं हो सका। कृपया फिर से कोशिश करें।',
    'Camera permission was denied. Allow camera access in your device settings, then try again.': 'कैमरे की अनुमति नहीं मिली। डिवाइस सेटिंग में कैमरा एक्सेस की अनुमति दें और फिर कोशिश करें।',
    'Camera access is restricted on this device.':
        'इस डिवाइस पर कैमरा एक्सेस प्रतिबंधित है।',
    'Could not open the camera. Check that it is connected and try again.':
        'कैमरा नहीं खुल सका। जाँचें कि कैमरा जुड़ा है और फिर कोशिश करें।',
    'Camera capture is not supported on this device.':
        'इस डिवाइस पर कैमरे से फ़ोटो लेना उपलब्ध नहीं है।',
    'The photo could not be captured. Please try again.':
        'फ़ोटो नहीं ली जा सकी। कृपया फिर से कोशिश करें।',
    'Take a Photo': 'फ़ोटो लें',
    'Try Again': 'फिर से कोशिश करें',
    'Photo attached': 'फ़ोटो जोड़ी गई',
    'Replace photo': 'फ़ोटो बदलें',
    'Remove photo': 'फ़ोटो हटाएँ',
    'STEP 1 OF 3': 'चरण 1 / 3',
    'STEP 2 OF 3': 'चरण 2 / 3',
    'STEP 3 OF 3': 'चरण 3 / 3',
    'Hello! So how may I help you?': 'नमस्ते! मैं आपकी क्या मदद कर सकता हूँ?',
    'What would you like to know?': 'आप क्या जानना चाहेंगे?',
    'Send message': 'संदेश भेजें',
    'Go back': 'वापस जाएँ',
    'Your journey starts here': 'आपकी यात्रा यहाँ से शुरू होती है',
    'Enter your mobile number to continue':
        'आगे बढ़ने के लिए अपना मोबाइल नंबर दर्ज करें',
    'Mobile number': 'मोबाइल नंबर',
    'Could not send a code. Please try again.':
        'कोड नहीं भेजा जा सका। कृपया फिर से कोशिश करें।',
    'We’ll send you a one-time verification code':
        'हम आपको एक बार उपयोग होने वाला सत्यापन कोड भेजेंगे',
    'Need help?': 'मदद चाहिए?',
    'Enter a valid 10-digit mobile number to receive a verification code.':
        'सत्यापन कोड पाने के लिए 10 अंकों का मान्य मोबाइल नंबर दर्ज करें।',
    'Got it': 'समझ गया',
    'Select country': 'देश चुनें',
    'Enter your mobile number': 'अपना मोबाइल नंबर दर्ज करें',
    'Enter mobile number': 'मोबाइल नंबर दर्ज करें',
    'India': 'भारत',
    'United States': 'संयुक्त राज्य अमेरिका',
    'United Kingdom': 'यूनाइटेड किंगडम',
    'Australia': 'ऑस्ट्रेलिया',
    'United Arab Emirates': 'संयुक्त अरब अमीरात',
    'Could not resend the code. Try again.':
        'कोड फिर से नहीं भेजा जा सका। कृपया कोशिश करें।',
    'That code didn’t match. Please try again.':
        'यह कोड मेल नहीं खाता। कृपया फिर से कोशिश करें।',
    'Could not verify the code. Please try again.':
        'कोड की पुष्टि नहीं हो सकी। कृपया फिर से कोशिश करें।',
    'Verify your number': 'अपने नंबर की पुष्टि करें',
    'You’re all set!': 'सब तैयार है!',
    'Your mobile number has been verified.':
        'आपके मोबाइल नंबर की पुष्टि हो गई है।',
    'Verification code': 'सत्यापन कोड',
    'Enter the complete 6-digit code': 'पूरा 6 अंकों का कोड दर्ज करें',
    'Verify': 'पुष्टि करें',
    'Didn’t receive the code? ': 'कोड नहीं मिला? ',
    'Resend code': 'कोड फिर से भेजें',
    'Change mobile number': 'मोबाइल नंबर बदलें',
    'Demo mode: use 123456 to verify. Replace DemoAuthService with Firebase Phone Auth when you are ready.': 'डेमो मोड: पुष्टि के लिए 123456 दर्ज करें। तैयार होने पर DemoAuthService को Firebase Phone Auth से बदलें।',
    'Select your language': 'अपनी भाषा चुनें',
    'English (default)': 'अंग्रेज़ी (डिफ़ॉल्ट)',
    'Hindi (हिन्दी)': 'हिन्दी',
    'Select an ID type': 'पहचान पत्र का प्रकार चुनें',
    'Government ID Type': 'सरकारी पहचान पत्र का प्रकार',
    'Select your ID document': 'अपना पहचान पत्र चुनें',
    'Select ID document': 'पहचान पत्र चुनें',
    'Choose one government-issued identity':
        'सरकार द्वारा जारी एक पहचान पत्र चुनें',
    'This field is required': 'यह जानकारी आवश्यक है',
    'Select your date of birth': 'अपनी जन्म तिथि चुनें',
    'Date of Birth': 'जन्म तिथि',
    'Enter the OTP sent to the registered mobile number.':
        'पंजीकृत मोबाइल नंबर पर भेजा गया OTP दर्ज करें।',
    'Enter the valid 6-digit OTP 123456.':
        'मान्य 6 अंकों का OTP 123456 दर्ज करें।',
    'Demo mode: use 123456.': 'डेमो मोड: 123456 दर्ज करें।',
    'Scan me': 'मुझे स्कैन करें',
    'You can enter now': 'अब आप प्रवेश कर सकते हैं',
    'Emergency & Support': 'आपातकालीन सहायता',
    'Register': 'पंजीकरण',
    'Near Places': 'आस-पास की जगहें',
    'Not provided': 'नहीं दिया गया',
    '(optional)': '(वैकल्पिक)',
    'English, Hindi': 'अंग्रेज़ी, हिंदी',
    'New Delhi, India': 'नई दिल्ली, भारत',
    'Jaipur, India': 'जयपुर, भारत',
    'Varanasi, India': 'वाराणसी, भारत',
    'Rishikesh, India': 'ऋषिकेश, भारत',
    'Haridwar, India': 'हरिद्वार, भारत',
    'Mumbai, India': 'मुंबई, भारत',
    'Other': 'अन्य',
    'Culture & Nature': 'संस्कृति और प्रकृति',
    'Spiritual': 'आध्यात्मिक',
    'Adventure': 'रोमांच',
    'Relaxed': 'आरामदायक',
    'Family': 'परिवार',
    'Search destinations, tourist places...': 'गंतव्य और पर्यटन स्थल खोजें...',
    'Open travel assistant': 'यात्रा सहायक खोलें',
    'Close menu': 'मेन्यू बंद करें',
    'About the app': 'ऐप के बारे में',
    'Privacy Policy': 'गोपनीयता नीति',
  };
}

class AppLanguagePersistenceException implements Exception {
  const AppLanguagePersistenceException();
}
