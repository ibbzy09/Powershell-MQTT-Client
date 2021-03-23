
            $TopicRaw = "ps2mqtt/recipe/open-chrome"
            $MessageRaw = $MqttObject.Message

            Write-Host "Got... " $TopicRaw

            # Capture Params
            $Pattern = [regex]"\((.*)\)"            
            $Capture = [regex]::match($TopicRaw, $Pattern)
            
            If ($Capture.Groups.Success -eq $True) {
                $Parameters = $Capture.Groups[1] -split ","
                Write-Host "Parameters captured:" $Parameters.Count "..."
                $CleanedTopic = ($TopicRaw).replace($Capture.Groups[0].Value, "")
                Write-Host "Topic $CleanedTopic..."
                $Recipe = ($CleanedTopic -split '/')[-1]
            }
            else {
                $Recipe = ($TopicRaw -split '/')[-1]
            }
            
            $RecipePath = $Config.RecipesPath + "\" + $Recipe
            Write-Host "Checking for recipe $RecipePath..."
            
            If (($Recipe).IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1 ) {
                Throw "Exception: The folder name ($Recipe) contains invalid characters"
            }

            If (Test-Path -Path ("$RecipePath\Main.ps1")) {
            }


            $Async = $True
                
            If ( $Config.RecipeExecutionType -eq "sync") {
                $Async = $False
            }

            If ($Capture.Groups.Success -eq $True -and $Config.RecipeExecutionType -eq "sync") {
                $Async = $True
            }
            elseif ($Capture.Groups.Success -eq $True -and $Config.RecipeExecutionType -eq "sync") {
                $Async = $False
            }