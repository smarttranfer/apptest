class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "https://vms.bkav.com";

  static const String basePort = ":20003";

  static const String apiUrl = baseUrl + basePort + "/vms/api";

  // Basic Auth Data
  static const String user = "91e9acf6-6f08-48d2-8ebe-970431fcfe30";
  static const String pass = "BASryHYPZyplDtHyYOEnxHISK2fyVN117I2WklCu";

  // receiveTimeout
  static const int receiveTimeout = 20000;

  // connectTimeout
  static const int connectionTimeout = 15000;

  static const String continentsUrl = "$apiUrl/continents";
  static const String countriesUrl = "$apiUrl/countries";
}
