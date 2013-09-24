PluginConsole
=============

Extension for default Xcode console.

## Installation
Build this plugin, then the plugin will automatically be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.  
Relaunch Xcode and PluginConsole will make your life easier.

##Xcode 5
If you use Xcode 4 then you should not download latest commit. Latest commit uses for Xcode 5 only and Scheme was be updated.

## Usage
Copy `Client` folder to your plugin and add LogClient.h to your .pch file. And then use PluginLog() and PluginLogWithName() for log to the standart console.

When you debug your plugin, click to `Show Plugins Log` button and you will see debug information from your plugin.

![PC_ss01.png](http://cl.ly/image/2Y0U1t1j1L2A/Screen%20Shot%202013-05-16%20at%202.43.45.png)
![PC_ss02.png](http://cl.ly/image/0G2M0R0q443Y/Screen%20Shot%202013-05-16%20at%203.06.21.png)

## License
*PluginConsole* is released under the **MIT License**, see *LICENSE.txt*.
