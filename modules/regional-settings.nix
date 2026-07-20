{
  # Interpret the system clock and display local time in the US Central zone.
  time.timeZone = "America/Chicago";

  # Use US English and UTF-8 as the default locale.
  i18n.defaultLocale = "en_US.UTF-8";

  # Keep address, measurement, formatting, and identity conventions consistent.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
