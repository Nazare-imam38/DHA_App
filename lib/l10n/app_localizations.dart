import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DHA MARKETPLACE'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'PROJECTS'**
  String get projects;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get search;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'MY BOOKINGS'**
  String get myBookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @johnDoe.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get johnDoe;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dhaProjectsMap.
  ///
  /// In en, this message translates to:
  /// **'DHA PROJECTS MAP'**
  String get dhaProjectsMap;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get searchProjects;

  /// No description provided for @satellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satellite;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'PROPERTIES'**
  String get properties;

  /// No description provided for @searchProperties.
  ///
  /// In en, this message translates to:
  /// **'Search properties...'**
  String get searchProperties;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @houses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get houses;

  /// No description provided for @flats.
  ///
  /// In en, this message translates to:
  /// **'Flats'**
  String get flats;

  /// No description provided for @plots.
  ///
  /// In en, this message translates to:
  /// **'Plots'**
  String get plots;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @limited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limited;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @phase6.
  ///
  /// In en, this message translates to:
  /// **'Phase 6'**
  String get phase6;

  /// No description provided for @phase5.
  ///
  /// In en, this message translates to:
  /// **'Phase 5'**
  String get phase5;

  /// No description provided for @phase3.
  ///
  /// In en, this message translates to:
  /// **'Phase 3'**
  String get phase3;

  /// No description provided for @phase2.
  ///
  /// In en, this message translates to:
  /// **'Phase 2'**
  String get phase2;

  /// No description provided for @marla10.
  ///
  /// In en, this message translates to:
  /// **'10 Marla'**
  String get marla10;

  /// No description provided for @marla5.
  ///
  /// In en, this message translates to:
  /// **'5 Marla'**
  String get marla5;

  /// No description provided for @kanal1.
  ///
  /// In en, this message translates to:
  /// **'1 Kanal'**
  String get kanal1;

  /// No description provided for @kanal2.
  ///
  /// In en, this message translates to:
  /// **'2 Kanal'**
  String get kanal2;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @plotFinder.
  ///
  /// In en, this message translates to:
  /// **'Plot Finder'**
  String get plotFinder;

  /// No description provided for @interactiveSocietyMaps.
  ///
  /// In en, this message translates to:
  /// **'Interactive Society Maps'**
  String get interactiveSocietyMaps;

  /// No description provided for @plotsCount.
  ///
  /// In en, this message translates to:
  /// **'1.2M+ Plots | 2500+ Societies'**
  String get plotsCount;

  /// No description provided for @tryItNow.
  ///
  /// In en, this message translates to:
  /// **'Try It Now'**
  String get tryItNow;

  /// No description provided for @postYourProperty.
  ///
  /// In en, this message translates to:
  /// **'Post Your Property'**
  String get postYourProperty;

  /// No description provided for @sellOrRentOut.
  ///
  /// In en, this message translates to:
  /// **'Sell or Rent Out'**
  String get sellOrRentOut;

  /// No description provided for @reachBuyers.
  ///
  /// In en, this message translates to:
  /// **'Reach 1M+ Active Buyers'**
  String get reachBuyers;

  /// No description provided for @postAnAd.
  ///
  /// In en, this message translates to:
  /// **'Post an Ad'**
  String get postAnAd;

  /// No description provided for @residentialProperties.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get residentialProperties;

  /// No description provided for @commercialProperties.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercialProperties;

  /// No description provided for @propertiesCount.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesCount;

  /// No description provided for @residentialCount.
  ///
  /// In en, this message translates to:
  /// **'75'**
  String get residentialCount;

  /// No description provided for @commercialCount.
  ///
  /// In en, this message translates to:
  /// **'15'**
  String get commercialCount;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChanged;

  /// No description provided for @languageChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'App language has been changed to {language} successfully!'**
  String languageChangedMessage(Object language);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @websiteUrl.
  ///
  /// In en, this message translates to:
  /// **'www.dhamarketplace.com'**
  String get websiteUrl;

  /// No description provided for @physicalAddress.
  ///
  /// In en, this message translates to:
  /// **'DHA Phase 1, Lahore, Pakistan'**
  String get physicalAddress;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// No description provided for @howWouldYouRate.
  ///
  /// In en, this message translates to:
  /// **'How would you rate our app?'**
  String get howWouldYouRate;

  /// No description provided for @loveIt.
  ///
  /// In en, this message translates to:
  /// **'Love it!'**
  String get loveIt;

  /// No description provided for @likeIt.
  ///
  /// In en, this message translates to:
  /// **'Like it'**
  String get likeIt;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @notGood.
  ///
  /// In en, this message translates to:
  /// **'Not good'**
  String get notGood;

  /// No description provided for @hateIt.
  ///
  /// In en, this message translates to:
  /// **'Hate it'**
  String get hateIt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @rateOnAppStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on App Store'**
  String get rateOnAppStore;

  /// No description provided for @wouldYouLikeToRate.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rate our app on the App Store?'**
  String get wouldYouLikeToRate;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @filterProjects.
  ///
  /// In en, this message translates to:
  /// **'Filter Projects'**
  String get filterProjects;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @allPhases.
  ///
  /// In en, this message translates to:
  /// **'All Phases'**
  String get allPhases;

  /// No description provided for @phase1.
  ///
  /// In en, this message translates to:
  /// **'Phase 1'**
  String get phase1;

  /// No description provided for @phase4.
  ///
  /// In en, this message translates to:
  /// **'Phase 4'**
  String get phase4;

  /// No description provided for @phase7.
  ///
  /// In en, this message translates to:
  /// **'Phase 7'**
  String get phase7;

  /// No description provided for @phase8.
  ///
  /// In en, this message translates to:
  /// **'Phase 8'**
  String get phase8;

  /// No description provided for @hospitality.
  ///
  /// In en, this message translates to:
  /// **'Hospitality'**
  String get hospitality;

  /// No description provided for @educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get educational;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @underConstruction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get underConstruction;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get loadingMap;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @floors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floors;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @newProjects.
  ///
  /// In en, this message translates to:
  /// **'New Projects'**
  String get newProjects;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @searchBookings.
  ///
  /// In en, this message translates to:
  /// **'Search bookings...'**
  String get searchBookings;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @browseProperties.
  ///
  /// In en, this message translates to:
  /// **'Browse properties'**
  String get browseProperties;

  /// No description provided for @viewDhaProjects.
  ///
  /// In en, this message translates to:
  /// **'View DHA projects'**
  String get viewDhaProjects;

  /// No description provided for @findProperties.
  ///
  /// In en, this message translates to:
  /// **'Find properties'**
  String get findProperties;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @faqAndContact.
  ///
  /// In en, this message translates to:
  /// **'FAQ and contact'**
  String get faqAndContact;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'DHA Marketplace v1.0.0'**
  String get appVersion;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your DHA Marketplace account'**
  String get signInToAccount;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinDhaMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Join DHA Marketplace'**
  String get joinDhaMarketplace;

  /// No description provided for @createAccountToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToGetStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @followUsOn.
  ///
  /// In en, this message translates to:
  /// **'Follow us on'**
  String get followUsOn;

  /// No description provided for @getInTouchWithUs.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us for any inquiries or support'**
  String get getInTouchWithUs;

  /// No description provided for @visitOurOffice.
  ///
  /// In en, this message translates to:
  /// **'Visit Our Office'**
  String get visitOurOffice;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @mainOffice.
  ///
  /// In en, this message translates to:
  /// **'Main Office'**
  String get mainOffice;

  /// No description provided for @directLines.
  ///
  /// In en, this message translates to:
  /// **'Direct Lines'**
  String get directLines;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @emailMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Email Marketplace'**
  String get emailMarketplace;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get businessHours;

  /// No description provided for @whyChooseDhaMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Why Choose DHA Marketplace?'**
  String get whyChooseDhaMarketplace;

  /// No description provided for @trustedPartnerForProperty.
  ///
  /// In en, this message translates to:
  /// **'Your trusted partner for premium property investments in DHA Islamabad'**
  String get trustedPartnerForProperty;

  /// No description provided for @secureTransactions.
  ///
  /// In en, this message translates to:
  /// **'Secure Transactions'**
  String get secureTransactions;

  /// No description provided for @secureTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'100% secure and transparent property transactions'**
  String get secureTransactionsDesc;

  /// No description provided for @expertSupport.
  ///
  /// In en, this message translates to:
  /// **'Expert Support'**
  String get expertSupport;

  /// No description provided for @expertSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated team of property investment experts'**
  String get expertSupportDesc;

  /// No description provided for @premiumLocations.
  ///
  /// In en, this message translates to:
  /// **'Premium Locations'**
  String get premiumLocations;

  /// No description provided for @premiumLocationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive access to prime DHA properties'**
  String get premiumLocationsDesc;

  /// No description provided for @quickProcessing.
  ///
  /// In en, this message translates to:
  /// **'Quick Processing'**
  String get quickProcessing;

  /// No description provided for @quickProcessingDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast and efficient property booking process'**
  String get quickProcessingDesc;

  /// No description provided for @readyToInvestInFuture.
  ///
  /// In en, this message translates to:
  /// **'Ready to Invest in Your Future?'**
  String get readyToInvestInFuture;

  /// No description provided for @joinThousandsOfInvestors.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of satisfied investors who have made DHA Marketplace their trusted property partner'**
  String get joinThousandsOfInvestors;

  /// No description provided for @exploreProperties.
  ///
  /// In en, this message translates to:
  /// **'Explore Properties'**
  String get exploreProperties;

  /// No description provided for @getStartedToday.
  ///
  /// In en, this message translates to:
  /// **'Get Started Today'**
  String get getStartedToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
