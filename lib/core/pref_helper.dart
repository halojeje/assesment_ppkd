import 'package:assesment_ppkd/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  // Key Constants
  static const String keyIsLoggedIn = 'KEY_IS_LOGGED_IN';
  static const String keyAuthToken = 'KEY_AUTH_TOKEN';
  static const String keyUserId = 'KEY_USER_ID';
  static const String keyUserUid = 'KEY_USER_UID';
  static const String keyUserName = 'KEY_USER_NAME';
  static const String keyUserEmail = 'KEY_USER_EMAIL';
  static const String keyUserPhone = 'KEY_USER_PHONE';
  static const String keyProfilePhoto = 'KEY_PROFILE_PHOTO';
  static const String keyPlayerId = 'KEY_PLAYER_ID';
  static const String keyThemeMode = 'KEY_THEME_MODE';

  // ==================== AUTH TOKEN & SESSION ====================

  /// Menyimpan Bearer Token / Status Login
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAuthToken, token);
    await prefs.setBool(keyIsLoggedIn, true);
  }

  /// Mengambil Bearer Token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAuthToken);
  }

  /// Memeriksa apakah pengguna sedang login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // Static alias method for SplashPage
  static Future<bool> checkIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // ==================== USER DATA ====================

  /// Menyimpan data profil pengguna ke SharedPreferences
  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    if (user.id != null) await prefs.setInt(keyUserId, user.id!);
    await prefs.setString(keyUserName, user.name);
    await prefs.setString(keyUserEmail, user.email);
    if (user.phone != null) {
      await prefs.setString(keyUserPhone, user.phone!);
    }
    if (user.profilePhoto != null) {
      await prefs.setString(keyProfilePhoto, user.profilePhoto!);
    }
  }

  /// Mengambil data pengguna dari SharedPreferences
  Future<UserModel> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return UserModel(
      id: prefs.getInt(keyUserId),
      name: prefs.getString(keyUserName) ?? '',
      email: prefs.getString(keyUserEmail) ?? '',
      phone: prefs.getString(keyUserPhone),
      profilePhoto: prefs.getString(keyProfilePhoto),
    );
  }

  // ==================== DEVICE TOKEN ====================

  Future<void> savePlayerId(String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPlayerId, playerId);
  }

  Future<String?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPlayerId);
  }

  // ==================== THEME MODE ====================

  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyThemeMode, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyThemeMode) ?? false;
  }

  // ==================== CLEAR SESSION (LOGOUT) ====================

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(keyThemeMode);
    await prefs.clear();
    if (isDark != null) {
      await prefs.setBool(keyThemeMode, isDark);
    }
  }
}

/// Alias PreferenceHelper for compatibility with splashpage
class PreferenceHelper {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefHelper.keyIsLoggedIn) ?? false;
  }
}
