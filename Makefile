TARGET := iphone:clang:latest:12.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = Twitter X

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DLTwitter
DLTwitter_FILES = \
	Tweak.xm \
	DLHelper.m \
	DLSaveMedia.m \
	DLTwitterDownloader.m \
	DLAuthenticationView.m \
	DLDebuggingVC.m \
	DLBarButtonItem.m \
	DLButton.m \
	DLSettingsButton.m \
	DLTapGestureRecognizer.m \
	DLDownloaderMinimizeView.m \
	DLTwitterViewCell.m \
	DLRadioSelectView.m \
	DLPreferencesNavigationController.m \
	DLCrashViewController.m \
	DLMaxAlertAction.m \
	DLMaxAlertButton.m \
	DLMaxAlertTextView.m \
	DLMaxAlertViewController.m \
	DLJSInstrumentationFetcher.m \
	MBProgressHUD.m \
	MBBackgroundView.m \
	MBBarProgressView.m \
	MBRoundProgressView.m \
	MBProgressHUDRoundedButton.m \
	MBProgressHUDRoundedButton2.m \
	FRPreferences.m \
	FRPSection.m \
	FRPCell.m \
	FRPSettings.m \
	FRPSwitchCell.m \
	FRPSliderCell.m \
	FRPTextFieldCell.m \
	FRPListCell.m \
	FRPSelectListTable.m \
	FRPSegmentCell.m \
	FRPValueCell.m \
	FRPViewCell.m \
	FRPViewSection.m \
	FRPLinkCell.m \
	FRPDeveloperCell.m

DLTwitter_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
DLTwitter_FRAMEWORKS = UIKit Foundation AVFoundation Photos PhotosUI WebKit LocalAuthentication MessageUI CoreGraphics QuartzCore CoreMedia MobileCoreServices MediaPlayer ImageIO AssetsLibrary CFNetwork Security Social
DLTwitter_PRIVATE_FRAMEWORKS = Twitter

include $(THEOS_MAKE_PATH)/tweak.mk
