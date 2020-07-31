# statnot
statnot is a [notification-daemon](http://www.galago-project.org/news/index.php) replacement for lightweight window managers like [dwm](http://dwm.suckless.org) and [wmii](http://wmii.suckless.org). It receives and displays notifications from the widely used [Desktop Notifications](http://www.galago-project.org/specs/notification/0.9/index.html) speficiation.

* [source repository](http://github.com/halhen/statnot/)

## Background
In some lightweight window managers, the text in the status bar is fed from an external process. For example dwm (version 5.4 and above) reads the status message from the X root window name, set by `xsetroot -name <text>`. A user typically enters a loop like below in .xinitrc to keep the status bar updating.

    while true
    do
        xsetroot -name "$(date +"%F %R")"
        sleep 30s # update every thirty seconds
    done &

This solution works well for status messages that are managed from a single point, for example when printing the same information every time. statnot lets you combine regular status messages with Desktop Notifications in a straightforward way. 

### Desktop Notifications
If you have used a "regular" window manager like KDE or Gnome, you have probably come across notifications. The are typically small windows with text messages and sometimes an icon that shows for a couple of seconds before they fade out. They are for example used to let the user know that a new instant message has arrived or that the battery is running low. Desktop Notifications is a specification created for freedesktop.org that many applications use. For example Pidgin and Evolution can be configured to notify for new messages using Desktop Notifications.

## Installation

To install statnot, first install the required dependencies:

* [python 3.5+](http://www.python.org)
* dbus-python
* PyGObject
* gtk3 - (not for GUI support)

Follow the [PyGObject installation instructions](https://pygobject.readthedocs.io/en/latest/getting_started.html) for your system.
That should take care of most of your dependencies.

Next, adjust the target directories in the `config.mk` file to fit your setup. 

To install, run as root:

    # make install

Finally, statnot needs to start with the window manager. You can for example add the following to .xinitrc:

    killall notification-daemon &> /dev/null
    statnot & 

Note that the statnot needs to be the only notification tool running. The example above makes sure that `notification-daemon` is not running.

## Configuration
The major, likely only, part you want to configure in statnot is what the status message should look like. During installation, a file called `.statusline.sh` is created in `$HOME/`. This gets called with regular intervals to retrieve the text that should be printed on the status line. statnot reads STDOUT, so a simple `echo <text>` is a good way to return the text.

During normal status updates, .statusline.sh is called without parameters. Here, you typically fetch and `echo` information about the computers performance, battery level or current time. 

Any pending notification is passed as the first argument to .statusline.sh. This way you can include additional information to the actual notification. 

Below is an example of .statusline.sh. It prints something like `[load 0.12 0.10 0.7]   11:42` in the status bar. When there is a pending notification, it prints `NOTIFICATION: <notification text>`.

    if [ $# -eq 0 ]; then
        loadavg="`cat /proc/loadavg | awk '{print $1, $2, $3}'`";
        echo "[load ${loadavg}]   `date +'%R'`";
    else
        echo "NOTIFICATION: $1";
    fi

For more advanced configuration, a configuration file can be passed to statnot on the command line, which overrides the default settings. This configuration file must be written in valid python, which will be read if the filename is given on the command line.  You do only need to set the variables you want to change, and can leave the rest out.

Below is an example of a configuration which sets the defaults.

    # Default time a notification is show, unless specified in notification
    DEFAULT_NOTIFY_TIMEOUT = 3000 # milliseconds
    
    # Maximum time a notification is allowed to show
    MAX_NOTIFY_TIMEOUT = 5000 # milliseconds
    
    # Maximum number of characters in a notification. 
    NOTIFICATION_MAX_LENGTH = 100 # number of characters
    
    # Time between regular status updates
    STATUS_UPDATE_INTERVAL = 2.0 # seconds
    
    # Command to fetch status text from. We read from stdout.
    # Each argument must be an element in the array
    # os must be imported to use os.getenv
    import os
    STATUS_COMMAND = ['/bin/sh', f'{os.getenv('HOME')}/.statusline.sh'] 
     
    # Always show text from STATUS_COMMAND? If false, only show notifications
    USE_STATUSTEXT=True
     
    # Put incoming notifications in a queue, so each one is shown.
    # If false, the most recent notification is shown directly.
    QUEUE_NOTIFICATIONS=True

    # update_text(text) is called when the status text should be updated
    # If there is a pending notification to be formatted, it is appended as
    # the final argument to the STATUS_COMMAND, e.g. as $1 in default shellscript
     
    # dwm statusbar update
    import subprocess
    def update_text(text):
        # Get first line
        first_line = text.splitline()[:-1]
        subprocess.call(["xsetroot", "-name", first_line])

## Possible errors
If no status message shows, verify that statnot is running. Also make sure your $HOME/.statusline.sh works and prints properly.

If notifications are not shown, make sure that no other notification-daemon is running. `killall notification-daemon` is a good command to try. Restart statnot if there was another daemon running. Also make sure that .statusline.sh takes care of and prints the $1 parameter (see section Configuration).

## Supported software
More and more applications use Desktop Notifications. Use [Google](http://www.google.com) to find solutions for your applications. `libnotify` is a good term to search, since it is a common library used by many applications.

You can also send your own notifications to statnot. This is easily done with the `notify-send` command. For example, `notify-send "Hello World"` will print `Hello World` in the status bar according to your speficiation. This is useful to notify that a long running task like a download or software build has finished.

notify-send can also be used for other, more direct messages. For exampe, I call a script called `dwm-volume` when my volume media buttons on the keyboard are pressed. This script adjusts the volume and sends a notification containing e.g. `vol [52%] [on]`. 

    #!/bin/sh
    if [ $# -eq 1 ]; then
        amixer -q set Master $1
    fi
    notify-send -t 0 "`amixer get Master | awk 'NR==5 {print "vol " $4, $6}'`"

As you can see, I use the option `-t 0` to notify-send, i.e. I request that the notification should show for zero milliseconds. For statnot, this means that the message should show for a regular status tick, by default two seconds, but if other notifications arrive, like a second press on the volume button, it goes away. This setup allows my audio volume to show only when I change it, while it updates instantly when I press the media buttons. Note that this option becomes useless if QUEUE_NOTIFICATIONS is set to False.

## Final notes
I'm sure there are other ways to use statnot. For example, one can create an update_text() that sends notifications as e-mail or instant messages, or that stores them to a log file. If you create any cool applications with statnot, I'd be happy to hear about them.

Released under the GPL. Please report any bugs or feature requests by email. Also, please drop me a line to let me know you like and use this software.

Authors:
 * Henrik Hallberg  (<halhen@k2h.se>); halhen@github
 * Olivier Ramonat; enzbang@github
 * Xavier Capaldi; xcapaldi@github
