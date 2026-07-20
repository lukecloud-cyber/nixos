{
  # Provide the X server used by Plasma's X11 session and XWayland clients.
  services.xserver.enable = true;

  # Start the SDDM login manager and KDE Plasma 6 desktop.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Ensure PolicyKit is ready before the firmware refresh service starts.
  systemd.services.fwupd-refresh = {
    after = [ "polkit.service" ];
    wants = [ "polkit.service" ];
  };

  # Use a plain US keyboard layout for X11 applications.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS printer discovery and job management.
  services.printing.enable = true;

  # Use PipeWire for low-latency audio and PulseAudio compatibility.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # Allow audio processes to request real-time priority.
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Route native ALSA clients through PipeWire.
    alsa.support32Bit = true; # Support 32-bit audio clients such as older games.
    pulse.enable = true; # Provide a PulseAudio-compatible server.
  };
}
