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
    'Latest Updates & Alerts': 'नवीनतम अपडेट और अलर्ट',
    'Notifications': 'सूचनाएँ',
    'ALERT': 'अलर्ट',
    'EVENT': 'कार्यक्रम',
    'NEWS': 'समाचार',
    'INFO': 'जानकारी',
    'Heavy Rainfall Alert': 'भारी बारिश का अलर्ट',
    'Avoid travel to lower areas of Vaishno Devi track.':
        'वैष्णो देवी ट्रैक के निचले क्षेत्रों में जाने से बचें।',
    'Katra & Vaishno Devi track': 'कटरा और वैष्णो देवी ट्रैक',
    'Bhajan Sandhya': 'भजन संध्या',
    'Today at 7:00 PM at Bhawan Premises.':
        'आज शाम 7:00 बजे भवन परिसर में।',
    'Bhawan Premises': 'भवन परिसर',
    'New Facilities at Bhawan': 'भवन में नई सुविधाएँ',
    'Improved queue management system now live.':
        'कतार प्रबंधन की बेहतर प्रणाली अब शुरू हो गई है।',
    'Bhawan': 'भवन',
    'Helpline Update': 'हेल्पलाइन अपडेट',
    'New helpline number: 1800-891-9031 (sample)':
        'नया हेल्पलाइन नंबर: 1800-891-9031 (नमूना)',
    'Visitor support': 'आगंतुक सहायता',
    '2h ago': '2 घंटे पहले',
    '3h ago': '3 घंटे पहले',
    '5h ago': '5 घंटे पहले',
    '6h ago': '6 घंटे पहले',
    'Alert Details': 'अलर्ट का विवरण',
    'Advisory': 'सलाह',
    'Recommended precautions': 'अनुशंसित सावधानियाँ',
    'Heavy rainfall may affect visibility and travel conditions on parts of the route. Check official updates before departure.':
        'भारी बारिश से मार्ग के कुछ हिस्सों में दृश्यता और यात्रा की स्थिति प्रभावित हो सकती है। निकलने से पहले आधिकारिक अपडेट देखें।',
    'Avoid exposed or low-lying areas.':
        'खुले या निचले क्षेत्रों से बचें।',
    'Follow route staff and official guidance.':
        'मार्ग कर्मचारियों और आधिकारिक निर्देशों का पालन करें।',
    'Allow extra time; conditions may change.':
        'अतिरिक्त समय रखें; परिस्थितियाँ बदल सकती हैं।',
    'Bhajan Sandhya is scheduled for today at 7:00 PM at the Bhawan Premises.':
        'भजन संध्या आज शाम 7:00 बजे भवन परिसर में निर्धारित है।',
    'Arrive early and follow venue directions.':
        'जल्दी पहुँचें और स्थल के निर्देशों का पालन करें।',
    'Keep walkways clear and follow staff instructions.':
        'रास्ते खुले रखें और कर्मचारियों के निर्देशों का पालन करें।',
    'Check local announcements for schedule changes.':
        'समय-सारणी में बदलाव के लिए स्थानीय घोषणाएँ देखें।',
    'An improved queue management system is now available at Bhawan to help guide visitors through the premises.':
        'परिसर में आगंतुकों का मार्गदर्शन करने के लिए भवन में कतार प्रबंधन की बेहतर प्रणाली उपलब्ध है।',
    'Follow the queue signs and staff directions.':
        'कतार के संकेतों और कर्मचारियों के निर्देशों का पालन करें।',
    'Keep your registration details accessible.':
        'अपनी पंजीकरण जानकारी पास रखें।',
    'Allow extra time during busy periods.':
        'भीड़ के समय अतिरिक्त समय रखें।',
    'This sample notice includes a demonstration helpline number. Verify contact details through official channels before calling.':
        'इस नमूना सूचना में डेमो हेल्पलाइन नंबर है। कॉल करने से पहले आधिकारिक माध्यमों से संपर्क विवरण की पुष्टि करें।',
    'Do not rely on sample contact details.':
        'नमूना संपर्क विवरण पर निर्भर न रहें।',
    'Use verified official sources for assistance.':
        'सहायता के लिए सत्यापित आधिकारिक स्रोतों का उपयोग करें।',
    'For immediate danger, contact local emergency services.':
        'तत्काल खतरे में स्थानीय आपातकालीन सेवाओं से संपर्क करें।',
    'Illustrative alert content — not live update data.':
        'उदाहरण के लिए अलर्ट सामग्री — लाइव अपडेट नहीं।',
    'More': 'और',
    'Travel safely': 'सुरक्षित यात्रा',
    'A few essentials to help you stay prepared, aware and confident on your journey.':
        'आपकी यात्रा में तैयार, सतर्क और आत्मविश्वासी रहने के लिए कुछ ज़रूरी बातें।',
    'Move to a safe place. Contact local emergency services and share your location. Save the local emergency number before you travel.':
        'किसी सुरक्षित जगह पर जाएँ। स्थानीय आपातकालीन सेवाओं से संपर्क करें और अपनी लोकेशन साझा करें। यात्रा से पहले स्थानीय आपातकालीन नंबर सहेजें।',
    'Before you head out': 'निकलने से पहले',
    'Keep documents handy': 'ज़रूरी दस्तावेज़ पास रखें',
    'Carry a copy of your ID, visa and insurance. Store digital copies securely.':
        'अपने पहचान पत्र, वीज़ा और बीमा की प्रति साथ रखें। डिजिटल प्रतियाँ सुरक्षित रखें।',
    'Share your plans': 'अपनी योजनाएँ साझा करें',
    'Tell someone you trust where you are going and when you expect to return.':
        'किसी भरोसेमंद व्यक्ति को बताएँ कि आप कहाँ जा रहे हैं और कब लौटेंगे।',
    'Choose trusted transport': 'विश्वसनीय परिवहन चुनें',
    'Use licensed services. Check the driver and vehicle details before getting in.':
        'लाइसेंस प्राप्त सेवाओं का उपयोग करें। बैठने से पहले चालक और वाहन का विवरण जाँचें।',
    'Protect your belongings': 'अपने सामान की सुरक्षा करें',
    'Keep valuables out of sight and bags close. Never share PINs or one-time passwords.':
        'कीमती सामान नज़र से दूर और बैग पास रखें। PIN या OTP कभी साझा न करें।',
    'Plan for your health': 'अपनी सेहत की योजना बनाएँ',
    'Carry essential medicines and safe water. Check food hygiene and know your limits.':
        'ज़रूरी दवाएँ और सुरक्षित पानी साथ रखें। भोजन की स्वच्छता जाँचें और अपनी सीमाएँ जानें।',
    'Check local conditions': 'स्थानीय परिस्थितियाँ जाँचें',
    'Follow local advice, weather alerts and signs. Avoid isolated areas, especially after dark.':
        'स्थानीय सलाह, मौसम अलर्ट और संकेतों का पालन करें। खासकर अँधेरा होने के बाद सुनसान क्षेत्रों से बचें।',
    'Stay alert. Trust your instincts. Ask for help.':
        'सतर्क रहें। अपनी समझ पर भरोसा करें। ज़रूरत पड़ने पर मदद माँगें।',
    'Explore Jaipur': 'जयपुर देखें',
    'Find your place. Skip the crowds.':
        'अपनी जगह खोजें। भीड़ से बचें।',
    'Search tourist sites': 'पर्यटन स्थल खोजें',
    'All places': 'सभी जगहें',
    'Quiet now': 'अभी शांत',
    'Near me': 'मेरे पास',
    'Nearby suggestions are examples; location is not accessed.':
        'आस-पास के सुझाव उदाहरण हैं; लोकेशन का उपयोग नहीं किया जा रहा।',
    'A good time to explore': 'घूमने का अच्छा समय',
    'Sample crowd suggestions. Check local updates before you go.':
        'भीड़ के अनुमान उदाहरण हैं। जाने से पहले स्थानीय अपडेट देखें।',
    'Fort & Heritage': 'किला और विरासत',
    'Architecture': 'वास्तुकला',
    'Museum & Culture': 'संग्रहालय और संस्कृति',
    'Science & Heritage': 'विज्ञान और विरासत',
    'Palace & Scenic View': 'महल और दर्शनीय स्थल',
    'Museum · Architecture · Heritage': 'संग्रहालय · वास्तुकला · विरासत',
    'Fort · Scenic viewpoint · Heritage': 'किला · दर्शनीय स्थल · विरासत',
    'Military heritage · Fort · Photography':
        'सैन्य विरासत · किला · फ़ोटोग्राफ़ी',
    '11 km': '11 किमी',
    '1.2 km': '1.2 किमी',
    '2.1 km': '2.1 किमी',
    '2.2 km': '2.2 किमी',
    '4.8 km': '4.8 किमी',
    'Nearby': 'आस-पास',
    'Low': 'कम',
    'Moderate': 'मध्यम',
    'Busy': 'भीड़',
    'capacity': 'क्षमता',
    'Best time: now–11 AM': 'सबसे अच्छा समय: अभी–सुबह 11 बजे',
    'Quieter after 4 PM': 'शाम 4 बजे के बाद कम भीड़',
    'Try Amber Fort instead': 'इसके बजाय आमेर किला देखें',
    'Best time: 3–7 PM': 'सबसे अच्छा समय: दोपहर 3–7 बजे',
    'Best time: 4:30–5:30 PM': 'सबसे अच्छा समय: शाम 4:30–5:30 बजे',
    'Best time: 8–11 AM': 'सबसे अच्छा समय: सुबह 8–11 बजे',
    'Amber Fort · Crowd forecast': 'आमेर किला · भीड़ का अनुमान',
    'Now': 'अभी',
    'Sample crowd estimate — not live data.':
        'भीड़ का नमूना अनुमान — लाइव डेटा नहीं।',
    'No places found': 'कोई जगह नहीं मिली',
    'Try another search for': 'इसके लिए दूसरी खोज आज़माएँ',
    'Search': 'खोजें',
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
    'Confirm SOS': 'एसओएस की पुष्टि करें',
    'This is a demo. No alert will be sent and your location will not be shared.':
        'यह एक डेमो है। कोई अलर्ट नहीं भेजा जाएगा और आपकी लोकेशन साझा नहीं की जाएगी।',
    'Continue demo': 'डेमो जारी रखें',
    'How can we help?': 'हम आपकी कैसे मदद कर सकते हैं?',
    'For immediate danger, use SOS. For other concerns, send a non-urgent report.':
        'तत्काल खतरे में SOS का उपयोग करें। अन्य समस्याओं के लिए गैर-आपातकालीन रिपोर्ट भेजें।',
    'Need urgent help?': 'क्या आपको तुरंत मदद चाहिए?',
    'The SOS flow is a local demo and does not contact emergency services.':
        'SOS प्रक्रिया स्थानीय डेमो है और आपातकालीन सेवाओं से संपर्क नहीं करती।',
    'SOS Emergency': 'आपातकालीन SOS',
    'Report a non-urgent issue': 'गैर-आपातकालीन समस्या की रिपोर्ट करें',
    'Describe a safety, cleanliness, or facility concern.':
        'सुरक्षा, स्वच्छता या सुविधा से जुड़ी समस्या बताएँ।',
    'Start a report': 'रिपोर्ट शुरू करें',
    'Demo only: requests are not sent and location is not shared.':
        'केवल डेमो: अनुरोध नहीं भेजे जाते और लोकेशन साझा नहीं की जाती।',
    'Emergency Alert Demo': 'आपातकालीन अलर्ट डेमो',
    'Demo alert created': 'डेमो अलर्ट बनाया गया',
    'No emergency alert was sent and no location was shared.':
        'कोई आपातकालीन अलर्ट नहीं भेजा गया और लोकेशन साझा नहीं की गई।',
    'DEMO REQUEST ID': 'डेमो अनुरोध आईडी',
    'STATUS': 'स्थिति',
    'Not sent (demo)': 'नहीं भेजा गया (डेमो)',
    'Not shared': 'साझा नहीं की गई',
    'TIME': 'समय',
    'Call configured contact': 'कॉन्फ़िगर किए गए संपर्क को कॉल करें',
    'Configured contact': 'कॉन्फ़िगर किया गया संपर्क',
    'Could not open the phone app. Dial manually:':
        'फ़ोन ऐप नहीं खुला। इस नंबर पर मैन्युअल रूप से कॉल करें:',
    'Demo only: this report will not be sent to a support team.':
        'केवल डेमो: यह रिपोर्ट सहायता टीम को नहीं भेजी जाएगी।',
    'Demo Report Created': 'डेमो रिपोर्ट बनाई गई',
    'This demo report was not saved or sent to a support team.':
        'यह डेमो रिपोर्ट न सहेजी गई और न सहायता टीम को भेजी गई।',
    'DEMO REPORT ID': 'डेमो रिपोर्ट आईडी',
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
    'The reply timed out.': 'जवाब मिलने में समय समाप्त हो गया।',
    'The chat backend is unreachable. Start it with npm start from the backend folder.':
        'Chat backend तक पहुँचा नहीं जा सका। backend फ़ोल्डर में npm start चलाएँ।',
    'The Gemini proxy returned an invalid response.':
        'Gemini proxy ने अमान्य जवाब दिया।',
    'Gemini request failed.': 'Gemini अनुरोध विफल हुआ।',
    'Gemini returned an empty response.': 'Gemini ने खाली जवाब दिया।',
    'Could not connect to Gemini. Check the server connection and try again.':
        'Gemini से कनेक्ट नहीं हो सका। सर्वर कनेक्शन जाँचकर फिर कोशिश करें।',
    'Gemini quota exceeded. Check your API key and quota.':
        'Gemini quota समाप्त हो गया। API key और quota जाँचें।',
    'Gemini returned an invalid response.': 'Gemini ने अमान्य जवाब दिया।',
    'Gemini did not return a text response. Try rephrasing your message.':
        'Gemini ने पाठ वाला जवाब नहीं दिया। अपना संदेश बदलकर पूछें।',
    'Close menu': 'मेन्यू बंद करें',
    'About the app': 'ऐप के बारे में',
    'Privacy Policy': 'गोपनीयता नीति',
  };
}

class AppLanguagePersistenceException implements Exception {
  const AppLanguagePersistenceException();
}
