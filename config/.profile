if [ -d "/usr/local/go/bin" ]; then
    PATH="/usr/local/go/bin:$PATH"
fi
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi


if [ -n "$GOPATH" ]; then
    export GOPATH=$HOME:$GOPATH
else
    export GOPATH=$HOME
fi


export EDITOR=nvim

# Launch byobu when logging in from a remote location.
case "$(hostname)" in
    raspi|raspberrypi|choco|ratana)  byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true ;;
esac
