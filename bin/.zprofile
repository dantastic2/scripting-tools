eval "$(/opt/homebrew/bin/brew shellenv)"

defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


alias news="cd Downloads/Newslazer"
cd ~/Downloads/NewsLazer/

rena() {
   python3 ~/scripting-tools/py/rename.py $1
}

killf() {
   while pkill Finder; do :; echo "killed Finder"; done
}
