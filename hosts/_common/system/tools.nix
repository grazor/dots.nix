{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    inetutils
    netcat
    curl

    file
    tree
    unar
    unzip

    ncdu
    dua # <- aka ncdu

    ffmpeg
    gifsicle
  ];
}
