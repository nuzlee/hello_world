class AppConstants {
  // Define your API URL here

  static const String baseUrl = 'https://openelite.ekonomi.gov.my';
  static const String baseUrllocal = 'http://127.0.0.1:8000';

  static const String clientId = 'podlatihan';
  static const String clientSecret = 'ncypeFkaHuq0xEuaIAq77gDiJthEKkLh';

  static const String openIdConnect =
      'https://sign.ekonomi.gov.my/realms/kementerian-ekonomi/protocol/openid-connect/token';
  static const String introSpect =
      'https://sign.ekonomi.gov.my/realms/kementerian-ekonomi/protocol/openid-connect/token/introspect';
  static const String loginSso = 'https://openelite.ekonomi.gov.my/loginSSO';
  static const String educationList = '$baseUrl/maklumat-pendidikan';

  // static var educationList;
}
