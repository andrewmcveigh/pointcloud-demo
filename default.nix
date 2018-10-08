{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "pointcloud-demo";
  src = ./.;
  buildInputs = [
    pkgs.git
    pkgs.nodejs-8_x
    pkgs.pkgconfig
    pkgs.stack
    pkgs.zlib
  ];

  libraryPkgconfigDepends = [ pkgs.zlib ];

  buildPhase = ''
    rm -rf node_modules output bower_components
    HOME=. npm install --verbose
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    HOME=. ./bower update --force-latest
    npm run build
  '';
  checkPhase = ''
    npm run test
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r output/app.js node_modules $out/
    echo "#!${pkgs.bash}/bin/bash" > $out/bin/pointcloud-demo
    echo "${pkgs.nodejs-8_x}/bin/node $out/app.js" >> $out/bin/pointcloud-demo
    chmod +x $out/bin/pointcloud-demo
  '';
}
