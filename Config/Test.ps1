Try {

    #Load our configs
    Write-Host "Loading configuration..."
    $Config = Import-PowerShellDataFile ".\Config\Client.psd1"

    Function TestMqtt {
        Param(
            [parameter(Mandatory = $true)]$MqttObject
        )
        
        $Recipe = ($MqttObject.topic) -replace ($Config.MQTT.Topics.Recipe + "/"), ""
        $RecipePath = $Config.RecipesPath+"\"+$Recipe
        Write-Host $Recipe
        Write-Host "Checking for $RecipePath..."

        If (Test-Path -Path ($RecipePath)) {

            Write-Host "Found script $RecipePath under path"

            $MessagePayload = $([System.Text.Encoding]::ASCII.GetString($MqttObject.Message))
            Write-Host ("Topic: " + $topic)
            Write-Host ("Message: " + $msg)
    
        } Else {
            Write-Host ("The recipe $Recipe does not exist.")
        }
    } 
} Catch {

    $_
}