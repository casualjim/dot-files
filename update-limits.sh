#!/bin/bash

echo '
#!/bin/sh

set -e

syslog -s -l warn "Set environment variables with /etc/environment $(whoami) - start"

launchctl set GOROOT /usr/local/opt/go/libexec
launchctl set GOPATH /Users/ivan/go

if [ -x /usr/libexec/path_helper ]; then
    export PATH=""
    eval `/usr/libexec/path_helper -s`
    launchctl setenv PATH $PATH
fi

osascript -e "tell app \"Dock\" to quit"

syslog -s -l warn "Set environment variables with /etc/environment $(whoami) - complete"
' | sudo tee /etc/environment > /dev/null
sudo chmod +x /etc/environment

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>environment.user</string>
    <key>ProgramArguments</key>
    <array>
            <string>/etc/environment</string>
    </array>
    <key>KeepAlive</key>
    <false/>
    <key>RunAtLoad</key>
    <true/>
    <key>WatchPaths</key>
    <array>
        <string>/etc/environment</string>
    </array>
</dict>
</plist>' | sudo tee /Library/LaunchAgents/environment.user.plist > /dev/null

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>environment</string>
    <key>ProgramArguments</key>
    <array>
            <string>/etc/environment</string>
    </array>
    <key>KeepAlive</key>
    <false/>
    <key>RunAtLoad</key>
    <true/>
    <key>WatchPaths</key>
    <array>
        <string>/etc/environment</string>
    </array>
</dict>
</plist>' | sudo tee /Library/LaunchDaemons/environment.plist > /dev/null

launchctl load -w /Library/LaunchAgents/environment.user.plist
sudo launchctl load -w /Library/LaunchDaemons/environment.plist

