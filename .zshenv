# -*- sh -*-
# base
#export PATH=$HOME/local/bin:$HOME/usr/local/bin:$PATH

## via http://www.clear-code.com/blog/2011/9/5.html
## PATH
## 重複したパスを登録しない。
typeset -U path
## (N-/): 存在しないディレクトリは登録しない。
##    パス(...): ...という条件にマッチするパスのみ残す。
##            N: NULL_GLOBオプションを設定。
##               globがマッチしなかったり存在しないパスを無視する。
##            -: シンボリックリンク先のパスを評価。
##            /: ディレクトリのみ残す。
path=(
  $HOME/.rvm/bin # Add RVM to PATH for scripting
  # default
  $HOME/local/bin(N-/)
  $HOME/bin(N-/)
  # Homebrew
  /usr/local/bin(N-/)
  # MacPorts
  /opt/local/bin(N-/)
  # Debian GNU/Linux
  /var/lib/gems/*/bin(N-/)
  # Solaris
  /opt/csw/bin(N-/)
  /usr/sfw/bin(N-/)
  # Cygwin
  /cygdrive/c/meadow/bin(N-/)
  # system
  /usr/bin(N-/)
  /usr/games(N-/)
  /bin(N-/)
  /sbin(N-/)
)

## SUDO_PATH
## -x: export SUDO_PATHも一緒に行う。
## -T: SUDO_PATHとsudo_pathを連動する。
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=(
  {,/usr/pkg,/usr/local,/usr}/sbin(N-/)
  {,/usr/pkg,/usr/local,/usr}/bin(N-/)
)

## MANPATH
typeset -U manpath
manpath=(
  # default
  $HOME/local/share/man(N-/)
  # MacPorts
  $HOME/local/man(N-/)
  /opt/local/share/man(N-/)
  # Solaris
  /opt/csw/share/man(N-/)
  /usr/sfw/share/man(N-/)
  # system
  /usr/local/share/man(N-/)
  /usr/share/man(N-/)
)

## RUBYLIB
# export RUBYLIB=$HOME/local/lib/ruby/site_ruby/1.9.1:$HOME/local/lib/ruby
typeset -xT RUBYLIB ruby_path
typeset -u ruby_path
ruby_path=(
  # current
  ./lib
  # Mac
  $HOME/local/lib/ruby/sit_ruby/1.9.1(N-/)
  $HOME/local/lib/ruby(N-/)
)

## PYTHON
typeset -xT PYTHONPATH pythonpath
typeset -u pytonpath
pytonpath=(
  # current
  ./lib
)

## ENV
export LANG=ja_JP.UTF-8 # git commit log とか
#export TERM=vt100 # 
export BLOCKSIZE=K
export EDITOR=vim
## vimがなくてもvimでviを起動する。
if ! type vim > /dev/null 2>&1; then
    alias vim=vi
fi
if type lv > /dev/null 2>&1; then
  ## lvを優先する。
  export PAGER="lv"
else
  ## lvがなかったらlessを使う。
  export PAGER="less"
fi
if [ "$PAGER" = "lv" ]; then
    ## -c: ANSIエスケープシーケンスの色付けなどを有効にする。
    ## -l: 1行が長くと折り返されていても1行として扱う。
    ##     （コピーしたときに余計な改行を入れない。）
    export LV="-c -l"
else
    ## lvがなくてもlvでページャーを起動する。
    alias lv="$PAGER"
fi

## SCM
export SVN_EDITOR=vim
export GIT_EDITOR=vim
export GIT_SVN_ID=suVene
export GISTY_DIR=$HOME/dev/gisty
export GISTY_SSL_CA=/System/Library/OpenSSL/cert.pem
export GISTY_SSL_VERIFY=NONE

export GEM_HOME=$HOME/local/lib/ruby/gems

# PERL
export PERL5LIB=$HOME/local/lib/perl5:$HOME/local/lib/perl5/site_perl/

# permission denied taiou
export MAILPATH=$HOME/MailBox/postmaster/maildir

# PORTS
export INSTALL_AS_USER=yes
export PREFIX=$HOME/local
export LOCALBASE=$HOME/local
export PKG_DBDIR=$LOCALBASE/var/db/pkg
export PKG_TMPDIR=$LOCALBASE/tmp/
export PORT_DBDIR=$LOCALBASE/var/db/pkg
export DISTDIR=$LOCALASE/tmp/dist
export WRKDIRPREFIX=$LOCALASE/tmp/work
export PORTSDIR=$HOME/usr/ports
export PKGTOOLS_CONF=$LOCALBASE/etc/pkgtools.conf
export DEPENDS_TARGET='install clean'
export LD_LIBRARY_PATH=$HOME/local/lib

## GNU grepがあったら優先して使う。
if type ggrep > /dev/null 2>&1; then
    alias grep=ggrep
fi
## grepのバージョンを検出。
grep_version="$(grep --version | head -n 1 | sed -e 's/^[^0-9.]*\([0-9.]*\)$/\1/')"
## デフォルトオプションの設定
export GREP_OPTIONS
### バイナリファイルにはマッチさせない。
GREP_OPTIONS="--binary-files=without-match"
case "$grep_version" in
  1.*|2.[0-4].*|2.5.[0-3])
    ;;
  *)
	### grep 2.5.4以降のみの設定
  ### grep対象としてディレクトリを指定したらディレクトリ内を再帰的にgrepする。
	GREP_OPTIONS="--directories=recurse $GREP_OPTIONS"
    ;;
esac
### 拡張子が.tmpのファイルは無視する。
GREP_OPTIONS="--exclude=\*.tmp $GREP_OPTIONS"
## 管理用ディレクトリを無視する。
if grep --help | grep -q -- --exclude-dir; then
  GREP_OPTIONS="--exclude-dir=.svn $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.git $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.deps $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.libs $GREP_OPTIONS"
fi
### 可能なら色を付ける。
if grep --help | grep -q -- --color; then
  GREP_OPTIONS="--color=auto $GREP_OPTIONS"
fi

# sedの設定
## GNU sedがあったら優先して使う。
## 2012-03-04
if type gsed > /dev/null 2>&1; then
    alias sed=gsed
fi

[ -f ~/.zshenv.local ] && source ~/.zshenv.local


