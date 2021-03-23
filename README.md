
# PowerShell2MQTT

PowerShell2MQTT (PS2MQTT) is small PowerShell utility that lets you setup a tiny Windows agent to listen and subscribe to MQTT events. You can trigger workflows AKA "Recipes" based on MQTT topics. 


I wrote this utility to service my home, it's so good I decided to open source and share it.

* Comes with Premade Recipes I use around my home (Toast, Turn On/Off Screen and Open Chrome)
* Uses the common and popular MQTT client written in .net.
* Written in PowerShell so easy to read and auditable 
* Modular, MQTT Topics can run Recipes 
* Supports asynchronous and synchronous workflows

More background: There were many scenarios I wanted to achieve and after Googling around I couldn't find much or anyone who had done before, I wanted to show a Windows Toast on my screen after someone pressed my doorbell, turn on a screen and show a live camera feed of visitors and many other Windows automations. So I wrote this over the course of two evenings.


## Config

	\Config\Client.psd1


##### MQTT Server Settings
Set your MQTT server settings within the MQTT block, this includes Server name (can have port) , Schema names of the topics (You can change **ps2mqtt** to the name of your device for example) .

The messages block are for LWT, Online and Offline message settings for when the client connects to the broker.

Client DLL path is for the NuGet dependency this project uses. 

##### Recipes
The recipes directory should have all your recipes you wish to expose via MQTT. How this works..

Folder structure of a recipe should be
Recipe/EXAMPLE-RECIPE1
        -----------------------/Main.ps1

When a message is published to MQTT topic **ps2mqtt/recipe/EXAMPLE-RECIPE1** then the Main.ps1 file is executed.


	@{
		MQTT  =  @{
			Server  =  'mqtt'
			Username  =  $Null
			Password  =  $Null
			Topics  =  @{
				Recipe  =  "ps2mqtt/recipe/#"
				Will  =  "ps2mqtt/status"
				Status  =  "ps2mqtt/status"
			}
			Messages  =  @{
				Online  =  "online"
				OFfline  =  "offline"
				Will  =  "disconnected"
			}
			WillRetain  =  1
			WillQoSLevel  =  1
			WillFlag  =  1
			StatusQoS  =  1
			StatusRetain  =  1
			CleanSession  =  1
			KeepAlivePeriod  =  30
			ClientDLLPath  =  '.\Library\lib\net45\M2Mqtt.Net.dll'
		}
		RecipesPath  =  ".\Recipes"
		ApplicationLoopInterval  =  100
		RecipeExecutionType  =  "async"
	}


