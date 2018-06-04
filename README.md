# IKEv2

## Created By.Farid Arjmand ##

### Connecting from iOS

To configure the VPN connection on an iOS device, follow these steps:

Send yourself an email with the root certificate attached.
Open the email on your iOS device and tap on the attached certificate file, then tap Install and enter your passcode. Once it installs, tap Done.
Go to Settings, General, VPN and tap Add VPN Configuration. This will bring up the VPN connection configuration screen.
Tap on Type and select IKEv2.
In the Description field, enter a short name for the VPN connection. This could be anything you like.
In the Server and Remote ID field, enter the server's domain name or IP address. The Local ID field can be left blank.
Enter your username and password in the Authentication section, then tap Done.
Select the VPN connection that you just created, tap the switch on the top of the page, and you'll be connected.

### Connecting from macOS

Follow these steps to import the certificate:

Double-click the certificate file. Keychain Access will pop up with a dialog that says "Keychain Access is trying to modify the system keychain. Enter your password to allow this."
Enter your password, then click on Modify Keychain
Double-click the newly imported VPN certificate. This brings up a small properties window where you can specify the trust levels. Set IP Security (IPSec) to Always Trust and you'll be prompted for your password again. This setting saves automatically after entering the password.
Now that the certificate is important and trusted, configure the VPN connection with these steps:

Go to System Preferences and choose Network.
Click on the small "plus" button on the lower-left of the list of networks.
In the popup that appears, Set Interface to VPN, set the VPN Type to IKEv2, and give the connection a name.
In the Server and Remote ID field, enter the server's domain name or IP address. Leave the Local ID blank.
Click on Authentication Settings, select Username, and enter your username and password you configured for your VPN user. Then click OK.

### Connecting from Windows

First, import the root certificate by following these steps:

Press WINDOWS+R to bring up the Run dialog, and enter mmc.exe to launch the Windows Management Console.
From the File menu, navigate to Add or Remove Snap-in, select Certificates from the list of available snap-ins, and click Add.
We want the VPN to work with any user, so select Computer Account and click Next.
We're configuring things on the local computer, so select Local Computer, then click Finish.
Under the Console Root node, expand the Certificates (Local Computer) entry, expand Trusted Root Certification Authorities, and then select the Certificates entry:
Certificates view
From the Action menu, select All Tasks and click Import to display the Certificate Import Wizard. Click Next to move past the introduction.
On the File to Import screen, press the Browse button and select the certificate file that you've saved. Then click Next.
Ensure that the Certificate Store is set to Trusted Root Certification Authorities, and click Next.
Click Finish to import the certificate.
Then configure the VPN with these steps:

Launch Control Panel, then navigate to the Network and Sharing Center.
Click on Set up a new connection or network, then select Connect to a workplace.
Select Use my Internet connection (VPN).
Enter the VPN server details. Enter the server's domain name or IP address in the Internet address field, then fill in Destination name with something that describes your VPN connection. Then click Done.
Your new VPN connection will be visible under the list of networks. Select the VPN and click Connect. You'll be prompted for your username and password. Type them in, click OK, and you'll be connected.
