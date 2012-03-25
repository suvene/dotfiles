# users generic .zshrc file for zsh(1)

#"漢のzsh"(http://journal.mycom.co.jp/column/zsh/index.html)第22回を元に改変

# @参考
#   http://d.hatena.ne.jp/giant_penguin/20081130/1228022016
#   http://www.cozmixng.org/~kou/linux/zsh
#   http://ogawa.s18.xrea.com/tdiary/20080331.html

###############プロンプトの設定################ {{{
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

#zshmisc(1)参照
    #   %B %b ボールドにする。終了する。
    #   %{...%} エスケープ文字列として読み込む。(あやしげな訳。原文はzshmisc(1)のvisual effectsの段落)
    #   %/ 現在のディレクトリ。
    #   ${fg[color]}文字色の設定。fgの部分をbgにすると背景色の設定。エスケープシークエンスで設定することもできる。

autoload colors
colors
case ${UID} in
0)
    PROMPT="%B%{${fg[red]}%}[%D %T]#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    RPROMPT="%{${fg[red]}%}[%4c]%{${reset_color}%} "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="%{${fg[red]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
*)
    PROMPT="%{${fg[cyan]}%}[%D %T]%%%{${reset_color}%} "
    PROMPT2="%{${fg[cyan]}%}%_%%%{${reset_color}%} "
    RPROMPT="%{${fg[cyan]}%}[%4c]%{${reset_color}%} "
    SPROMPT="%{${fg[cyan]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="%{${fg[red]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
esac

# おすすめzsh設定 - ククログ(2011-09-05) http://www.clear-code.com/blog/2011/9/5.html
# プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

## 256色生成用便利関数# {{{
### red: 0-5
### green: 0-5
### blue: 0-5
color256()
{
    local red=$1; shift
    local green=$2; shift
    local blue=$3; shift

    echo -n $[$red * 36 + $green * 6 + $blue + 16]
}

fg256()
{
    echo -n $'\e[38;5;'$(color256 "$@")"m"
}

bg256()
{
    echo -n $'\e[48;5;'$(color256 "$@")"m"
}
# }}}

## プロンプトの作成
### ↓のようにする。
###   -(user@debian)-(0)-<2011/09/01 00:54>------------------------------[/home/user]-
###   -[84](0)%                                                                   [~]

## バージョン管理システムの情報も表示する
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true
zstyle ':vcs_info:*' formats \
    '(%{%F{cyan}%}%s%{%f%})-[%{%F{cyan}%}%b%{%f%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{cyan}%}%s%{%f%})-[%{%F{cyan}%}%b%{%f%}|%{%F{white}%}%a%{%f%}]'
autoload -Uz is-at-least
if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"    # 適当な文字列に変更する
  zstyle ':vcs_info:git:*' unstagedstr "-"  # 適当の文字列に変更する
  zstyle ':vcs_info:*' formats \
    '(%{%F{cyan}%}%s%{%f%})-[%{%F{cyan}%}%b%{%f%}%c%u] '
  zstyle ':vcs_info:*' actionformats \
    '(%{%F{cyan}%}%s%{%f%})-[%{%F{cyan}%}%b%{%f%}|%u%a%{%f%}] '
fi


### プロンプトバーの左側
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %{%F{cyan}%}...%{%f%}: 「...」をシアン色の文字にする。
###   %n: ユーザ名
###   %m: ホスト名（完全なホスト名ではなくて短いホスト名）
###   %{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%f%k%b%}:
###                           最後に実行したコマンドが正常終了していれば
###                           太字で白文字で緑背景にして異常終了していれば
###                           太字で白文字で赤背景にする。
###   %{%F{white}%}: 白文字にする。
###     %(x.true-text.false-text): xが真のときはtrue-textになり
###                                偽のときはfalse-textになる。
###       ?: 最後に実行したコマンドの終了ステータスが0のときに真になる。
###       %K{green}: 緑景色にする。
###       %K{red}: 赤景色を赤にする。
###   %?: 最後に実行したコマンドの終了ステータス
###   %{%k%}: 背景色を元に戻す。
###   %{%f%}: 文字の色を元に戻す。
###   %{%b%}: 太字を元に戻す。
###   %D{%Y/%m/%d %H:%M}: 日付。「年/月/日 時:分」というフォーマット。
prompt_bar_left_self="(%{%B%F{red}%}%n%{%b%f%}%{%F{white}%}@%{%f%}%{%B%F{cyan}%}%m%{%b%f%})"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
### プロンプトバーの右側
###   %{%B%K{magenta}%F{white}%}...%{%f%k%b%}:
###       「...」を太字のマジェンタ背景の白文字にする。
###   %d: カレントディレクトリのフルパス（省略しない）
prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"

### 2行目左にでるプロンプト。
###   %h: ヒストリ数。
###   %(1j,(%j),): 実行中のジョブ数が1つ以上ある場合だけ「(%j)」を表示。
###     %j: 実行中のジョブ数。
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %#: 一般ユーザなら「%」、rootユーザなら「#」になる。
prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "

## プロンプトフォーマットを展開した後の文字数を返す。 count_prompt_characters# {{{
## 日本語未対応。
count_prompt_characters()
{
    # print:
    #   -P: プロンプトフォーマットを展開する。
    #   -n: 改行をつけない。
    # sed:
    #   -e $'s/\e\[[0-9;]*m//g': ANSIエスケープシーケンスを削除。
    # wc:
    #   -c: 文字数を出力する。
    # sed:
    #   -e 's/ //g': *BSDやMac OS Xのwcは数字の前に空白を出力するので削除する。
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}
# }}}

## プロンプトを更新する。 update_promt# {{{
update_prompt()
{
    # プロンプトバーの左側の文字数を数える。
    # 左側では最後に実行したコマンドの終了ステータスを使って
    # いるのでこれは一番最初に実行しなければいけない。そうし
    # ないと、最後に実行したコマンドの終了ステータスが消えて
    # しまう。
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    # プロンプトバーに使える残り文字を計算する。
    # $COLUMNSにはターミナルの横幅が入っている。
    local bar_rest_length=$[COLUMNS - bar_left_length]

    local bar_left="$prompt_bar_left"
    # パスに展開される「%d」を削除。
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    # 「%d」を抜いた文字数を計算する。
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    # パスの最大長を計算する。
    #   $[...]: 「...」を算術演算した結果で展開する。
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    # パスに展開される「%d」に最大文字数制限をつける。
    #   %d -> %(C,%${max_path_length}<...<%d%<<,)
    #     %(x,true-text,false-text):
    #         xが真のときはtrue-textになり偽のときはfalse-textになる。
    #         ここでは、「%N<...<%d%<<」の効果をこの範囲だけに限定させる
    #         ために用いているだけなので、xは必ず真になる条件を指定している。
    #       C: 現在の絶対パスが/以下にあると真。なので必ず真になる。
    #       %${max_path_length}<...<%d%<<:
    #          「%d」が「${max_path_length}」カラムより長かったら、
    #          長い分を削除して「...」にする。最終的に「...」も含めて
    #          「${max_path_length}」カラムより長くなることはない。
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    # 「${bar_rest_length}」文字分の「-」を作っている。
    # どうせ後で切り詰めるので十分に長い文字列を作っているだけ。
    # 文字数はざっくり。
    local separator="${(l:${bar_rest_length}::-:)}"
    # プロンプトバー全体を「${bar_rest_length}」カラム分にする。
    #   %${bar_rest_length}<<...%<<:
    #     「...」を最大で「${bar_rest_length}」カラムにする。
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"

    # プロンプトバーと左プロンプトを設定
    #   "${bar_left}${bar_right}": プロンプトバー
    #   $'\n': 改行
    #   "${prompt_left}": 2行目左のプロンプト
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    # 右プロンプト
    #   %{%B%F{white}%K{green}}...%{%k%f%b%}:
    #       「...」を太字で緑背景の白文字にする。
    #   %~: カレントディレクトリのフルパス（可能なら「~」で省略する）
    RPROMPT="[%{%B%F{white}%}%~%{%f%b%}]"
    case "$TERM_PROGRAM" in
        Apple_Terminal)
          # Mac OS Xのターミナルでは$COLUMNSに右余白が含まれていないので
          # 右プロンプトに「-」を追加して調整。
          ## 2011-09-05
          RPROMPT="${RPROMPT}-"
      ;;
    esac

    # バージョン管理システムの情報を取得する。
    LANG=en_US.UTF-8 vcs_info >&/dev/null
    psvar=()
    psvar[2]=$(git_not_pushed)
    # バージョン管理システムの情報があったら右プロンプトに表示する。
    if [ -n "$vcs_info_msg_0_" ]; then
        psvar[1]="$vcs_info_msg_0_"
        RPROMPT="${vcs_info_msg_0_}%2v-${RPROMPT}"
#        RPROMPT="%1(v|%F${CYAN}%1v%2v%f|)${vcs_info_git_pushed}${RESET}${WHITE}[${BLUE}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}"
    fi
}
# }}}

# プッシュしているかどうか git_not_pushed {{{
# via. (zsh版)pushし忘れないようにプロンプトに表示するようにした - ゆろよろ日記 http://d.hatena.ne.jp/yuroyoro/20110219/1298089409
git_not_pushed()
{
  if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
    head="$(git rev-parse HEAD)"
    for x in $(git rev-parse --remotes)
    do
      if [ "$head" = "$x" ]; then
        return 0
      fi
    done
    echo "{?}"
  fi
  return 0
}
# }}}

## コマンド実行前に呼び出されるフック。
precmd_functions=($precmd_functions update_prompt)

# }}}

###############こまごまとした設定################ {{{

# ディレクトリ名を入力するとそのディレクトリに移動
setopt auto_cd

# cd時に-[tab]で過去の移動先を補完
setopt auto_pushd
setopt pushd_ignore_dups # 同じディレクトリは重複させない
## 移動先を検索するリスト。
cdpath=(~)
## ディレクトリが変わったらディレクトリスタックを表示。
chpwd_functions=($chpwd_functions dirs)

# typoを修正
setopt correct

# 補完候補を詰めて表示する
setopt list_packed

# スラッシュを削除しない
setopt noautoremoveslash

# beepを鳴らさない
setopt nobeep
setopt no_beep
setopt nolistbeep


# キーバインド。
# vi。emacs風にするなら-e
bindkey -v
bindkey -a 'q' push-line
bindkey -a 'H' run-help
bindkey -a '^A' vi-beginning-of-line
bindkey -a '^E' vi-end-of-line
bindkey -v '[^OH' vi-beginning-of-line
bindkey -v '[^OF' vi-end-of-line

# エディタ機能を有効にする
autoload zed

# フロー制御を行わない(C-s, C-q)
setopt no_flow_control

# C-d でログアウトしない
set ignore_eof

# バックグラウンドジョブの終了を知らせ
setopt no_tify

# rm * の確認
setopt rmstar_wait

# ジョブ
## jobsでプロセスIDも出力する。
setopt long_list_jobs

# 実行時間
## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

# ログイン・ログアウト
## 全てのユーザのログイン・ログアウトを監視する。
watch="all"
## ログイン時にはすぐに表示する。
log

# 単語
## 「/」も単語区切りとみなす。
WORDCHARS=${WORDCHARS:s,/,,}
## 「|」も単語区切りとみなす。
## 2011-09-19
WORDCHARS="${WORDCHARS}|"
# }}}

##############履歴と補完################ {{{

# コマンド履歴関係のキーマップ
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end


# 履歴の保持数と履歴ファイルの設定
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
setopt hist_ignore_dups     # 同じコマンドを重複して記録しない
setopt hist_ignore_space    # 先頭がスペースなら履歴追加しない
setopt hist_expand          # 補完時にヒストリを自動的に展開する
setopt hist_ignore_dups     # 履歴呼出し後一旦編集可能
setopt share_history        # 履歴の共有
setopt no_clobber           # リダイレクトで上書きを許可しない
setopt auto_list            # ^Iで補完可能な一覧(曖昧)
## via http://www.clear-code.com/blog/2011/9/5.html
## ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
## すぐにヒストリファイルに追記する。
setopt inc_append_history

## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control
case "${TERM}" in
cygwin)
  ;;
*)
#    setopt auto_correct         # 補完時にスペルチェックする
  ;;
esac

# 補完設定ファイルのパスと補完機能の初期化
fpath=(~/.zsh/functions/Completion ${fpath})
autoload -U compinit
case "${TERM}" in
    cygwin)
        compinit -u
    ;;
    *)
        compinit
    ;;
esac

# タブを押さなくても補完候補を表示する
#autoload predict-on
#predict-off

## 補完方法毎にグループ化する。
### 補完方法の表示方法
###   %B...%b: 「...」を太字にする。
###   %d: 補完方法のラベル
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''

## 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。
###           ただし、補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2

## 補完候補に色を付ける。
### "": 空文字列はデフォルト値を使うという意味。
zstyle ':completion:*:default' list-colors ""

## 補完候補がなければより曖昧に候補を探す。
### m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
### r:|[._-]=*: 「.」「_」「-」の前にワイルドカード「*」があるものとして補完する。
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'

## 補完方法の設定。指定した順番に実行する。
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
zstyle ':completion:*' completer \
    _oldlist _complete _match _history _ignored _approximate _prefix

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
## 詳細な情報を使う。
zstyle ':completion:*' verbose yes
## sudo時にはsudo用のパスも使う。
zstyle ':completion:sudo:*' environ PATH="$SUDO_PATH:$PATH"

## カーソル位置で補完する。
setopt complete_in_word
## globを展開しないで候補の一覧から補完する。
setopt glob_complete
## 補完時にヒストリを自動的に展開する。
#setopt hist_expand
## 補完候補がないときなどにビープ音を鳴らさない。
#setopt no_beep
## 辞書順ではなく数字順に並べる。
setopt numeric_glob_sort


# 展開
## --prefix=~/localというように「=」の後でも
## 「~」や「=コマンド」などのファイル名展開を行う。
setopt magic_equal_subst
## 拡張globを有効にする。
## glob中で「(#...)」という書式で指定する。
setopt extended_glob
## globでパスを生成したときに、パスがディレクトリだったら最後に「/」をつける。
setopt mark_dirs

# }}}

# パッケージ管理(macとfreebsd)# {{{
case "${OSTYPE}" in
darwin*)
    alias updateports="sudo port selfupdate; sudo port outdated"
    alias portupgrade="sudo port upgrade installed"
    ;;
freebsd*)
    case ${UID} in
    0)
        updateports()
        {
            if [ -f /usr/ports/.portsnap.INDEX ]
            then
                portsnap fetch update
            else
                portsnap fetch extract update
            fi
            (cd /usr/ports/; make index)

            portversion -v -l \<
        }
        alias appsupgrade='pkgdb -F && BATCH=YES NO_CHECKSUM=YES portupgrade -a'
        ;;
    esac
    ;;
esac
# }}}

###############色の設定################ {{{

#$TERMを切り替える。($TERMがxtermまたはktermだとカラー表示にならない端末が有るらしいので-colorを設定する。)
#ついでに漢字が通らないっぽい端末使用時にはLANGをunsetしとく。
case "${TERM}" in
xterm)
    export TERM=xterm-color
    ;;
kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
cons25|linux)
    unset LANG
    ;;
esac

#lsとzshの補完に使用する色を設定。

#LSCOLORS    BSD ls用
    #前景色と背景色を下記の順番に設定する。
    #directory symboliclink socket fifo executable block-special setuid-executable setgid-executable other-dirctory-with-stickybit other-dirctory-without-sticybit
    #色(それぞれ大文字にすると太字)
    #a-black b-red c-green d-brown e-blue f-mazenda g-cyan h-white x-default

#LS_COLORS   GNU ls用
    #自分の使ってるsolarisのglsのバージョンが古いためか、su以降のLS_COLORSを設定するとエラーになるので$OSTYPEがsolaris*の時は設定しない。
    #変数=色;効果で設定する。
    #di-directory ln-symboliclink so-socket ex-executable bd-block special cd-charactor special su-setuid executable tw-other dirctory with stickybit ow-other dirctory without sticybit
    #色と効果
    #0-Default Colour 1-Bold 4-Underlined 5-Flashing Text 7-Reverse Field 31-Red 32-Green 33-Orange 34-Blue 35-Purple 36-Cyan 37-Grey 40-Black Background 41-Red Background 42-Green Background 43-Orange Background 44-Blue Background 45-Purple Background 46-Cyan Background 47-Grey Background 90-Dark Grey 91-Light Red 92-Light Green 93-Yellow 94-Light Blue 95-Light Purple 96-Turquoise 100-Dark Grey Background 101-Light Red Background 102-Light Green Background 103-Yellow Background 104-Light Blue Background 105-Light Purple Background 106-Turquoise Background

#"zstyle ':completion:*' list-colors"   zshの補完時に使用する色設定


unset LSCOLORS
export LSCOLORS=GxFxCxdxBxegedabagacad
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors 'di=36;1' 'ln=35;1' 'so=32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'

case "${OSTYPE}" in
solaris*)
    export LS_COLORS='di=36;1:ln=35;1:so=32;1:pi=33:ex=31;1:bd=46;34:cd=43;34'
    ;;
*)
    export LS_COLORS='di=36;1:ln=35;1:so=32;1:pi=33:ex=31;1:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
esac
# }}}

###############ウィンドウタイトル等の設定################ {{{

#エスケープシークエンス
    #printf(1),ascii(7)参照。
    #<特殊文字>=ascii=printfのエスケープシークエンス
    #<esc>=033=\e  <bell>=007=\a  <backslash>=134=\\

#xterm screenの制御文字
    #Xterm Control Sequences(http://www.xfree86.org/current/ctlseqs.html),screen(1)参照
    #<string terminator>=<esc><backslash>
    #<operating system command>=<esc>]

#screenの起動判定
    #$TERMでscreenの起動判定をしているが、$STY(screenのセッションを識別する環境変数)がNULLかどうかで判定する方法もある。例:[ -n $STY ] &&  .....
    #mac環境(OSX 10.4,PPC)で$TERMをscreenにするとvim7.x実行時にエラーになるため.screenrcにて$TERMをansiにしているので、$TERMがscreenまたはansiの時にscreenのウィンドウのタイトルが設定されるようにしている。(solaris,linuxの.screenrcでは$TERM=screenにしてる。)

#zsh組み込みの関数
    #zshmisc(1)を参照
    #preexec() 入力されたコマンドが実行される前に実行される。
    #precmd() プロンプトが表示される前に実行される。

#xtermのタイトル設定
    #Xterm Control Sequences参照
    #printf  "<operating system command>0;文字列<bell>"でxtermのウィンドウタイトルを文字列に設定する。終端の<bell>は<string terminator>でも可。
    #上記の文字列をプロンプトに含めることによっても設定可能。

#screenのタイトル設定
    #screen(1)参照
    #printf  "<esc>k文字列<string terminator>"でscreenのウィンドウタイトルを文字列に設定する。
    #screenのウィンドウタイトルを動的に変更するには、プロンプトに上記の文字列を含めたり、precmd()やpreexec()内でscreenコマンドを"-t"などのオプションをつけて実行する方法もある。

#その他
    #screen(1)参照
    #screenに文字列を評価させずにxtermに文字列を渡す(<esc>P文字列<terminator>で渡せる)ことによってxtermのタイトルを変更できる。
    #例:printf "<esc>P<operating system command>0;文字列<bell><string terminator>

case "${TERM}" in
kterm*|xterm*|mterm*)
    precmd() {
        printf "\e]0;${USER}@${HOST%%.*}:${PWD}\a"
    }
    chpwd() {
        echo -ne "\033]0;${PWD/${HOME}/~}\007"
        ls -A
    }
    ;;
screen*|ansi*|rxvt*|cygwin)
    preexec() {
        # screen使用時にもxtermのタイトルを変更できる。
        # precmdのコメントアウトされたprintfも同様。
        # ウィンドウ間の移動をするとコマンドを実行するかEnterを押すまで
        # 実際の状態と食い違ってしまうので注意。
        #printf "\eP\e]0;!${1%% *}\a\e\\"  
        #printf "\ek!${1%% *}\e\\" # コマンドのみ表示
        printf "\ek $1 \e\\"
    }
    precmd() {
        #printf "\eP\e]0;~$(basename $(pwd))\a\e\\"
        printf "\ek~/$(basename $(pwd))\e\\"
    }
    chpwd() {
        ls -A
    }
esac
# }}}

# functions {{{
findgrep() { find $1 -name "$2" -print0 | xargs -0 -e grep -nH -e "$3" }

# via. sudo.vimをzshから扱いやすくしたい | monoの開発ブログ http://blog.monoweb.info/article/2011120320.html# {{{
sudo() {
  local args
  # sudo='sudo -E ' のため、2番目の引数をチェック
  case $2 in
    *vi|*vim)
      args=()
      for arg in $@[3,-1]
      do
        if [ $arg[1] = '-' ]; then
          args[$(( 1+$#args ))]=$arg
        else
          args[$(( 1+$#args ))]="sudo:$arg"
        fi
      done
      command vim $args
      ;;
    *)
      command sudo $@
      ;;
  esac
}
# }}}

# }}}

##############エイリアスの設定################ {{{
# OSによる切り替えを行う

# エイリアスを設定したコマンドでも補完機能を使えるようにする
setopt complete_aliases
alias where="command -v"
alias j="jobs -l"

## lsとpsの設定
### ls: できるだけGNU lsを使う。
### ps: 自分関連のプロセスのみ表示。
case "${OSTYPE}" in
  *bsd*|darwin*)
    # alias ls="ls -G -w"
    if [ -x "$(which gnuls)" ]; then
      alias ls="gnuls"
      alias l="ls -lhAF --color=auto"
    else
      alias l="ls -lhAFG"
    fi
    alias ps="ps -fU$(whoami)"
    ;;
  linux*)
    alias l="ls -lhAF --color=auto"
    alias ps="ps -fU$(whoami) --forest"
    ;;
  solaris*)
    alias l='gls -F --color=auto '
    ;;
  SunOS)
    if [ -x "`which gls`" ]; then
      alias ls="gls"
      alias l="ls -lhAF --color=auto"
    else
      alias l="ls -lhAF"
    fi
    alias ps="ps -fl -u$(/usr/xpg4/bin/id -un)"
    ;;
  cygwin*)
    set convert-meta off
    set output-meta on
    set input-meta on
    export LESS=MrXEd
    alias ls="ls -G -F --color=auto --show-control-chars"
    ;;
  *)
    alias l="ls -lhAF --color=auto"
    alias ps="ps -fU$(whoami) --forest"
    ;;
esac

# pipe
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g L="|& $PAGER"
alias -g W='| wc'
alias -g S='| sed'
alias -g A='| awk'
alias -g W='| wc'

# base
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias du='du -h'
alias df='df -h'

alias sudo='sudo -E '
alias s='sudo '
alias su='su -l '

alias g='git'
alias sg='sudo git'

# Jump
alias jd='cd ~/dev/git/dotfiles/'
alias jw='cd ~/dev/wk/'

# }}}

###############他の設定ファイルを読み込む################ {{{

#文字コード、$PATH,$MANPATH,その他のエイリアスは分離
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
[[ -f "$HOME/.zsh.d/config/packages.zsh" ]] && source "$HOME/.zsh.d/config/packages.zsh"
# }}}
