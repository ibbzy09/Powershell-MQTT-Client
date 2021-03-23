Try {

    #Load our configs
    Write-Host "Loading configuration..."
    $Config = Import-PowerShellDataFile .\Config\Client.psd1
    Write-Host "Configuration loaded"

    If ($Loaded -ne $True) {
        Add-Type -Path ".\Library\M2Mqtt\M2Mqtt.Net.dll" 
        $Loaded = $True # Line Needed For Development Only
        Write-Host "Assembly loaded..."
    }
    
    $MqttClient = [uPLibrary.Networking.M2Mqtt.MqttClient]($Config.MQTT.Server)
    $MqttClient.Connect([guid]::NewGuid(), $Config.MQTT.Username, $Config.MQTT.Password, $Config.MQTT.WillRetain, $Config.MQTT.WillQoSLevel, 1, $Config.MQTT.Topics.Will, $Config.MQTT.Messages.Will, $Config.MQTT.CleanSession, $Config.MQTT.KeepAlivePeriod )
    $MqttClient.Publish($Config.MQTT.Topics.Status, [System.Text.Encoding]::UTF8.GetBytes($Config.MQTT.Messages.Online), $Config.MQTT.StatusQoS, $Config.MQTT.StatusRetain)
    Function Global:MQTTMsgReceived {
        Param(
            [parameter(Mandatory = $true)]$MqttObject
        )

        Try {
            $Recipe = ($MqttObject.topic -split '/')[-1]
            $RecipePath = $Config.RecipesPath + "\" + $Recipe
            Write-Host "Checking for $RecipePath..."

            If (Test-Path -Path ($RecipePath)) {

                Write-Host "Found script $RecipePath under path"

                $MessagePayload = $([System.Text.Encoding]::ASCII.GetString($MqttObject.Message))

                Write-Host "Running script"+ ($RecipePath + "\Main.ps1")
                . ($RecipePath+"\Main.ps1") -Config $Config -Message $MessagePayload
    
            }
            Else {
                Write-Host ("The recipe $Recipe does not exist.")
            }

        }
        Catch {
            Write-Host $_
        }
    }

    Get-EventSubscriber -Force | Unregister-Event -Force

    Register-ObjectEvent `
        -inputObject $MqttClient `
        -EventName MqttMsgPublishReceived `
        -Action { MQTTMsgReceived $($args[1]) }

    $MqttClient.Subscribe($Config.MQTT.Topics.Recipe, 0)

    While ($True) {
        Start-Sleep -Milliseconds $Config.ApplicationLoopInterval
    }
    
}
Catch {
    Write-Error $_
}
Finally {

    $MqttClient.Publish($Config.MQTT.Topics.Status, [System.Text.Encoding]::UTF8.GetBytes($Config.MQTT.Messages.OFfline), 0, 0)
    $MqttClient.Disconnect()
    Write-Host "Disconnecting from server..."     
    Write-Host "Unregistering events..."        
    Get-EventSubscriber -Force | Unregister-Event -Force

}    