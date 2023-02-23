function Test-PullRequest {
    Param($Username, $Request, $CTFD_SERVER)
    if ($Request) {
        try {
            $Uri = [uri]([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Request)))

            if ($uri.Authority -notmatch $CTFD_SERVER -or $uri.PathAndQuery -notmatch 'users') { throw 'ERR:url' }
            $Id = $uri.Segments[-1]
            $Path = 'https://{0}/api/v1/users/{1}' -f $CTFD_SERVER, $Id

            $U = (Invoke-RestMethod -Uri $Path).data
            if ($Username -ne $U.name) { throw 'ERR:user' }

            $Readme = (Get-Content ./README.md -Raw).trim()

            if (!($Readme | Select-String $Username)) {
                $Message = "SUCCESS: Verification passed for $($U.Name)"
                $Readme = "{0}`n| {1} |" -f $Readme, $Username
                Set-Content -Path ./README.md -Value $Readme -Force | Out-Null
            }

            else {
                $Message = 'SUCCESS: You have already solved this challenge'
            }
            return $Message

        }
        catch {
            return "ERROR: Verification failed, please try again. ($($_.Exception.Message))"
        }
    }

    else {
        return 'ERROR: Comment not accepted, please try again.'
    }
}