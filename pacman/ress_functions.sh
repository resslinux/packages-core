tmpdir="/tmp/makepkg"

package-init() {
  rm -rf "$tmpdir"
  mkdir -p "$tmpdir"
}

package-doc() {
  options=(!strip)
  depends=(${depends_doc[*]})
  pkgdesc="$pkgdesc (documentation)"
  
  local i
  for i in doc man info html sgml licenses gtk-doc ri help; do
    if [ -d "$tmpdir/usr/share/$i" ]; then
      mkdir -p "$pkgdir/usr/share"
      mv "$tmpdir/usr/share/$i" "$pkgdir/usr/share/"
    fi
  done
  
  rm -f "$pkgdir/usr/share/info/dir"
  rmdir --ignore-fail-on-non-empty "$tmpdir/usr/share" "$tmpdir/usr" 2>/dev/null	
}

package-dev() {
  local i= j=
  depends=(${depends_dev[*]})
  pkgdesc="$pkgdesc (development files)"
  
  cd "$tmpdir"
  
  local libdirs=usr/
  
  [ -d lib/ ] && libdirs="lib/ $libdirs"
  for i in usr/include usr/lib/pkgconfig usr/share/aclocal\
           usr/share/gettext usr/bin/*-config	\
           usr/share/vala/vapi usr/share/gir-[0-9]*\
           usr/share/qt*/mkspecs			\
           usr/lib/qt*/mkspecs			\
           usr/lib/cmake				\
           usr/lib/m4				\
           $(find . -name include -type d) 	\
           $(find $libdirs -name '*.[acho]' \
           -o -name '*.prl' 2>/dev/null); do
             if [ -e "$tmpdir/$i" ] || [ -L "$tmpdir/$i" ]; then
               d="$pkgdir/${i%/*}"	# dirname $i
               mkdir -p "$d"
               mv "$tmpdir/$i" "$d"
               rmdir --ignore-fail-on-non-empty "$tmpdir/${i%/*}" 2>/dev/null
             fi
  done
  
  # move *.so links needed when linking the apps to -dev packages
  for i in lib/*.so usr/lib/*.so; do
    if [ -L "$i" ]; then
      mkdir -p "$pkgdir"/"${i%/*}"
      mv "$i" "$pkgdir/$i"
    fi
  done
}

package-lib() {
  pkgdesc="$pkgdesc (libraries)"
  depends=(${depends_lib[*]})
  local dir= file=
  
  for dir in lib usr/lib; do
    for file in "$tmpdir"/$dir/lib*.so.[0-9]*; do
      [ -f "$file" ] || continue
      mkdir -p "$pkgdir"/$dir
      mv "$file" "$pkgdir"/$dir/
    done    
  done
}

package-base() {
  mv "$tmpdir"/* "$pkgdir/"
}
