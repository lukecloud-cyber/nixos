{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc # KDE desktop calculator.
    onlyoffice-desktopeditors # Desktop editor for documents, sheets, and slides.
  ];
}
