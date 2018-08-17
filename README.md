# defcon26-materials
Slide deck and demo code for my DEFCON 26 talk, "Who Controls the Controllers — Hacking Crestron IoT Automation Systems". THE FOLLOWING CODE IS FOR EDUCATIONAL PURPOSES ONLY. USE AT YOUR OWN RISK.

## Slides
### crestron_lawshae_defcon26.pdf
* this is the version of my slides that I presented during my talk

## Code
### demo1_scanning.rb
* scan network for all Crestron devices, parse response data, try to connect to the CTP console of every device found, and run WHOAMI command
```
USAGE: ./demo1_scanning.rb
```
### demo2_mc3_shell.rb
* use backdoor account to escape CTP sandbox and open debug shell on vulnerable MC3 devices
```
USAGE: ./demo2_mc3_shell.rb [target_ip]
```
### demo2_mc3_unshell.rb
* undo what was done by demo2_mc3_shell.rb
```
USAGE: ./demo2_mc3_unshell.rb [target_ip]
```
### demo2_tsw_shell.rb
* use backdoor account to escape CTP sandbox and open debug shell on vulnerable TSW devices
```
USAGE: ./demo2_tsw_shell.rb [target_ip]
```
### demo2_tsw_unshell.rb
* undo what was done by demo2_tsw_shell.rb (reboot of target device required afterward)
```
USAGE: ./demo2_tsw_unshell.rb [target_ip]
```
### demo3_spying.rb
* use command injection vuln to modify a system config file on a vulnerable TSW device and restart a service to enable RTSP streaming
* also, automatically opens vlc to view the RTSP stream
```
USAGE: ./demo3_spying.rb [target_ip]
```
### demo3_unspying.rb
* undo what was done by demo3_spying.rb
```
USAGE: ./demo3_unspying.rb [target_ip]
```
