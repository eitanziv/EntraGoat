# Centralized color palette mirroring frontend/src/App.css CSS variables.
# Returned as a hashtable so XAML files can substitute via simple string replacement.

function Get-EntraGoatTheme {
    [pscustomobject]@{
        BgDarkest      = '#0A0A0A'
        BgDark         = '#141414'
        BgMedium       = '#1F1F1F'
        BgLight        = '#2A2A2A'
        BorderColor    = '#2F2F2F'
        TextPrimary    = '#E6E6E6'
        TextSecondary  = '#A0A0A0'
        TextMuted      = '#6A6A6A'
        Primary        = '#00B7FF'
        PrimaryDim     = '#0095CC'
        Success        = '#00FF88'
        SuccessDim     = '#00B85F'
        Warning        = '#FFB347'
        Danger         = '#FF4D6D'
        Beginner       = '#00FF88'
        Intermediate   = '#FFB347'
        Advanced       = '#FF4D6D'
        FontMono       = 'Consolas, JetBrains Mono, Courier New'
        FontUI         = 'Segoe UI, Inter, Arial'
    }
}

function Expand-EntraGoatTheme {
    # Replace {{KEY}} tokens in a XAML string with theme values.
    param(
        [Parameter(Mandatory)][string]$Xaml
    )
    $theme = Get-EntraGoatTheme
    foreach ($prop in $theme.PSObject.Properties) {
        $Xaml = $Xaml.Replace("{{$($prop.Name)}}", $prop.Value)
    }
    return $Xaml
}
