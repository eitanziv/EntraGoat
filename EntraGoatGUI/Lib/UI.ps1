# UI helpers for the EntraGoat WPF GUI.
# Requires PresentationFramework / PresentationCore / WindowsBase to be loaded
# (handled by Start-EntraGoat.ps1 entry script).

$script:EntraGoatRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

# Ram icons — shuffled randomly each launch so cards look fresh
$script:AllRamIcons = Get-ChildItem (Join-Path $PSScriptRoot '..\..\icons') -Filter '*.png' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne 'icons.png' } | ForEach-Object { $_.Name }
$script:ShuffledIcons = $script:AllRamIcons | Get-Random -Count ([Math]::Min($script:AllRamIcons.Count, 20))

function Get-EntraGoatRootPath { $script:EntraGoatRoot }

function Read-EntraGoatXaml {
    param([Parameter(Mandatory)][string]$RelativePath)
    $full = Join-Path $script:EntraGoatRoot $RelativePath
    $raw  = Get-Content -LiteralPath $full -Raw
    Expand-EntraGoatTheme -Xaml $raw
}

function ConvertTo-EntraGoatWindow {
    # Parse a XAML string into a WPF Window object.
    param([Parameter(Mandatory)][string]$Xaml)
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($Xaml))
    try {
        return [Windows.Markup.XamlReader]::Load($reader)
    } finally {
        $reader.Dispose()
    }
}

function New-EntraGoatBrush {
    param([string]$Hex)
    $color = [System.Windows.Media.ColorConverter]::ConvertFromString($Hex)
    [System.Windows.Media.SolidColorBrush]::new($color)
}

function Get-EntraGoatDifficultyBrush {
    param([string]$Difficulty)
    $theme = Get-EntraGoatTheme
    switch ($Difficulty) {
        'Beginner'     { New-EntraGoatBrush $theme.Beginner }
        'Intermediate' { New-EntraGoatBrush $theme.Intermediate }
        'Advanced'     { New-EntraGoatBrush $theme.Advanced }
        default        { New-EntraGoatBrush $theme.TextSecondary }
    }
}

function New-EntraGoatStatCard {
    param([string]$Label, [string]$Value, [string]$ValueColor)
    $theme = Get-EntraGoatTheme
    $border = [System.Windows.Controls.Border]::new()
    $border.Background = New-EntraGoatBrush $theme.BgMedium
    $border.BorderBrush = New-EntraGoatBrush $theme.BorderColor
    $border.BorderThickness = '1'
    $border.CornerRadius = '6'
    $border.Padding = '24,14'
    $border.Margin = '8,0'
    $border.MinWidth = 130

    $stack = [System.Windows.Controls.StackPanel]::new()
    $stack.HorizontalAlignment = 'Center'

    $valueTb = [System.Windows.Controls.TextBlock]::new()
    $valueTb.Text = $Value
    $valueTb.FontSize = 28
    $valueTb.FontWeight = 'Bold'
    $valueTb.HorizontalAlignment = 'Center'
    $valueTb.Foreground = New-EntraGoatBrush $ValueColor
    $valueTb.FontFamily = $theme.FontUI

    $labelTb = [System.Windows.Controls.TextBlock]::new()
    $labelTb.Text = $Label
    $labelTb.FontSize = 11
    $labelTb.HorizontalAlignment = 'Center'
    $labelTb.Foreground = New-EntraGoatBrush $theme.TextMuted
    $labelTb.FontFamily = $theme.FontUI
    $labelTb.Margin = '0,4,0,0'

    [void]$stack.Children.Add($valueTb)
    [void]$stack.Children.Add($labelTb)
    $border.Child = $stack
    return $border
}

function New-EntraGoatChallengeCard {
    param(
        [Parameter(Mandatory)]$Challenge,
        [Parameter(Mandatory)][bool]$IsCompleted
    )
    $theme = Get-EntraGoatTheme
    $accent = if ($IsCompleted) { $theme.Success } else { $theme.Primary }

    $border = [System.Windows.Controls.Border]::new()
    $border.Background = New-EntraGoatBrush $theme.BgMedium
    $border.BorderBrush = New-EntraGoatBrush $accent
    $border.BorderThickness = '1.5'
    $border.CornerRadius = '8'
    $border.Padding = '18'
    $border.Margin = '10'
    $border.Cursor = 'Hand'

    # Hover effect via mouse enter/leave
    $border.Add_MouseEnter({
        $this.Background = New-EntraGoatBrush '#262626'
    })
    $border.Add_MouseLeave({
        $this.Background = New-EntraGoatBrush '#1F1F1F'
    })

    $grid = [System.Windows.Controls.Grid]::new()
    $rd1 = [System.Windows.Controls.RowDefinition]::new(); $rd1.Height = 'Auto'
    $rd2 = [System.Windows.Controls.RowDefinition]::new(); $rd2.Height = '*'
    $rd3 = [System.Windows.Controls.RowDefinition]::new(); $rd3.Height = 'Auto'
    [void]$grid.RowDefinitions.Add($rd1)
    [void]$grid.RowDefinitions.Add($rd2)
    [void]$grid.RowDefinitions.Add($rd3)

    # Header: title + id badge
    $headerGrid = [System.Windows.Controls.Grid]::new()
    $headerGrid.Margin = '0,0,0,10'
    $cd1 = [System.Windows.Controls.ColumnDefinition]::new(); $cd1.Width = '*'
    $cd2 = [System.Windows.Controls.ColumnDefinition]::new(); $cd2.Width = 'Auto'
    [void]$headerGrid.ColumnDefinitions.Add($cd1)
    [void]$headerGrid.ColumnDefinitions.Add($cd2)

    $titleTb = [System.Windows.Controls.TextBlock]::new()
    $titleTb.Text = $Challenge.Title
    $titleTb.Foreground = New-EntraGoatBrush $accent
    $titleTb.FontWeight = 'SemiBold'
    $titleTb.FontSize = 14
    $titleTb.TextWrapping = 'Wrap'
    $titleTb.FontFamily = $theme.FontUI
    $titleTb.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($titleTb, 0)

    $idBorder = [System.Windows.Controls.Border]::new()
    $idBorder.Background = 'Transparent'
    $idBorder.BorderBrush = New-EntraGoatBrush $accent
    $idBorder.BorderThickness = '1'
    $idBorder.CornerRadius = '12'
    $idBorder.Width = 24; $idBorder.Height = 24
    $idBorder.VerticalAlignment = 'Top'
    $idBorder.Margin = '8,0,0,0'
    $idTb = [System.Windows.Controls.TextBlock]::new()
    $idTb.Text = "$($Challenge.Id)"
    $idTb.Foreground = New-EntraGoatBrush $accent
    $idTb.FontSize = 11
    $idTb.HorizontalAlignment = 'Center'
    $idTb.VerticalAlignment = 'Center'
    $idBorder.Child = $idTb
    [System.Windows.Controls.Grid]::SetColumn($idBorder, 1)

    [void]$headerGrid.Children.Add($titleTb)
    [void]$headerGrid.Children.Add($idBorder)
    [System.Windows.Controls.Grid]::SetRow($headerGrid, 0)

    # Description (truncated)
    $descBorder = [System.Windows.Controls.Border]::new()
    $descBorder.Background = New-EntraGoatBrush $theme.BgDark
    $descBorder.BorderBrush = New-EntraGoatBrush $theme.BorderColor
    $descBorder.BorderThickness = '0,0,0,0'
    $descBorder.Padding = '10'
    $descBorder.CornerRadius = '4'
    $descBorder.Margin = '0,0,0,12'
    $descTb = [System.Windows.Controls.TextBlock]::new()
    $shortDesc = if ($Challenge.Description.Length -gt 220) {
        $Challenge.Description.Substring(0, 217) + '...'
    } else { $Challenge.Description }
    $descTb.Text = $shortDesc
    $descTb.Foreground = New-EntraGoatBrush $theme.TextSecondary
    $descTb.FontSize = 12
    $descTb.TextWrapping = 'Wrap'
    $descTb.FontFamily = $theme.FontUI
    $descBorder.Child = $descTb
    [System.Windows.Controls.Grid]::SetRow($descBorder, 1)

    # Footer: difficulty + completed badges
    $footerPanel = [System.Windows.Controls.DockPanel]::new()
    $footerPanel.LastChildFill = $false

    $diffBorder = [System.Windows.Controls.Border]::new()
    $diffBorder.BorderBrush = Get-EntraGoatDifficultyBrush -Difficulty $Challenge.Difficulty
    $diffBorder.BorderThickness = '1'
    $diffBorder.CornerRadius = '10'
    $diffBorder.Padding = '8,3'
    $diffTb = [System.Windows.Controls.TextBlock]::new()
    $diffTb.Text = $Challenge.Difficulty.ToUpper()
    $diffTb.Foreground = Get-EntraGoatDifficultyBrush -Difficulty $Challenge.Difficulty
    $diffTb.FontSize = 10
    $diffTb.FontWeight = 'SemiBold'
    $diffTb.FontFamily = $theme.FontUI
    $diffBorder.Child = $diffTb
    [System.Windows.Controls.DockPanel]::SetDock($diffBorder, 'Left')
    [void]$footerPanel.Children.Add($diffBorder)

    if ($IsCompleted) {
        $compBorder = [System.Windows.Controls.Border]::new()
        $compBorder.BorderBrush = New-EntraGoatBrush $theme.Success
        $compBorder.BorderThickness = '1'
        $compBorder.CornerRadius = '10'
        $compBorder.Padding = '8,3'
        $compTb = [System.Windows.Controls.TextBlock]::new()
        $compTb.Text = "COMPLETED"
        $compTb.Foreground = New-EntraGoatBrush $theme.Success
        $compTb.FontSize = 10
        $compTb.FontWeight = 'SemiBold'
        $compTb.FontFamily = $theme.FontUI
        $compBorder.Child = $compTb
        [System.Windows.Controls.DockPanel]::SetDock($compBorder, 'Right')
        [void]$footerPanel.Children.Add($compBorder)
    }
    [System.Windows.Controls.Grid]::SetRow($footerPanel, 2)

    [void]$grid.Children.Add($headerGrid)
    [void]$grid.Children.Add($descBorder)
    [void]$grid.Children.Add($footerPanel)
    $border.Child = $grid
    return $border
}

function ConvertTo-EntraGoatElement {
    # Parse a XAML string into a WPF FrameworkElement (non-Window fragment).
    param([Parameter(Mandatory)][string]$Xaml)
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($Xaml))
    try {
        return [Windows.Markup.XamlReader]::Load($reader)
    } finally {
        $reader.Dispose()
    }
}

function global:Navigate-EntraGoatPage {
    param(
        [Parameter(Mandatory)][System.Windows.Window]$Window,
        [Parameter(Mandatory)][ValidateSet('Home','Challenge','Script')][string]$View,
        [hashtable]$Params = @{}
    )
    $nav = $Window.Tag
    $nav.CurrentView = $View
    $pageHost   = $Window.FindName('PageHost')
    $backBtn    = $Window.FindName('BackButton')
    $prevBtn    = $Window.FindName('PrevButton')
    $nextBtn    = $Window.FindName('NextButton')
    $breadcrumb = $Window.FindName('BreadcrumbText')

    switch ($View) {
        'Home' {
            $nav.CurrentChallengeId = $null
            $nav.CurrentScriptType  = $null
            $backBtn.Visibility = 'Collapsed'
            $prevBtn.Visibility = 'Collapsed'
            $nextBtn.Visibility = 'Collapsed'
            $breadcrumb.Text = 'Home'
            $pageHost.Content = Build-EntraGoatHomePage -Window $Window
        }
        'Challenge' {
            $id = $Params.ChallengeId
            $nav.CurrentChallengeId = $id
            $nav.CurrentScriptType  = $null
            $challenge = $nav.Challenges | Where-Object { $_.Id -eq $id } | Select-Object -First 1
            $backBtn.Visibility = 'Visible'
            $backBtn.Content = [char]0x2190 + ' Back to Home'
            $prevBtn.Visibility = 'Visible'
            $nextBtn.Visibility = 'Visible'
            $total = ($nav.Challenges | Measure-Object).Count
            $prevBtn.IsEnabled = ($id -gt 1)
            $nextBtn.IsEnabled = ($id -lt $total)
            $breadcrumb.Text = "Home > Challenge #$id`: $($challenge.Title)"
            $pageHost.Content = Build-EntraGoatChallengePage -Window $Window -Challenge $challenge
        }
        'Script' {
            $nav.CurrentScriptType = $Params.ScriptType
            $backBtn.Visibility = 'Visible'
            $backBtn.Content = [char]0x2190 + ' Back to Challenge'
            $prevBtn.Visibility = 'Collapsed'
            $nextBtn.Visibility = 'Collapsed'
            $id = $nav.CurrentChallengeId
            $challenge = $nav.Challenges | Where-Object { $_.Id -eq $id } | Select-Object -First 1
            $breadcrumb.Text = "Home > Challenge #$id > $($Params.ScriptType) Script"
            $pageHost.Content = Build-EntraGoatScriptPage -Window $Window -Title "$($Params.ScriptType) - Challenge $id" -ScriptPath $Params.ScriptPath -ScriptType $Params.ScriptType
        }
    }
}

function global:Build-EntraGoatHomePage {
    param([Parameter(Mandatory)][System.Windows.Window]$Window)
    $xaml = Read-EntraGoatXaml -RelativePath 'Views/HomePage.xaml'
    $page = ConvertTo-EntraGoatElement -Xaml $xaml
    $theme = Get-EntraGoatTheme
    $nav = $Window.Tag
    $challenges = $nav.Challenges

    # Logo
    $logoImage = $page.FindName('LogoImage')
    $logoPath = Join-Path (Get-EntraGoatRootPath) '..\frontend\public\assets\logoEntra.png'
    $logoPath = [System.IO.Path]::GetFullPath($logoPath)
    if (Test-Path -LiteralPath $logoPath) {
        $bi = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bi.BeginInit()
        $bi.UriSource = [Uri]$logoPath
        $bi.CacheOption = 'OnLoad'
        $bi.EndInit()
        $logoImage.Source = $bi
    } else {
        $logoImage.Visibility = 'Collapsed'
    }

    # Stats
    $statsPanel = $page.FindName('StatsPanel')
    $state = Get-EntraGoatState
    $completedCount = ($state.Completed | Measure-Object).Count
    $total = $challenges.Count
    $percent = if ($total -gt 0) { [math]::Round(($completedCount / $total) * 100) } else { 0 }
    [void]$statsPanel.Children.Add((New-EntraGoatStatCard -Label 'COMPLETED'        -Value "$completedCount" -ValueColor $theme.Primary))
    [void]$statsPanel.Children.Add((New-EntraGoatStatCard -Label 'TOTAL CHALLENGES' -Value "$total"          -ValueColor $theme.Primary))
    [void]$statsPanel.Children.Add((New-EntraGoatStatCard -Label 'PROGRESS'         -Value "$percent%"       -ValueColor $theme.Primary))

    # Cards
    $cardsItems = $page.FindName('CardsItems')
    foreach ($c in $challenges) {
        $isCompleted = $state.Completed -contains $c.Id
        $card = New-EntraGoatChallengeCard -Challenge $c -IsCompleted $isCompleted
        $card.Tag = @{ Id = $c.Id; Win = $Window }
        $card.Add_PreviewMouseLeftButtonUp({
            $t = $this.Tag
            Navigate-EntraGoatPage -Window $t.Win -View 'Challenge' -Params @{ ChallengeId = $t.Id }
        })
        [void]$cardsItems.Items.Add($card)
    }

    return $page
}

function global:Build-EntraGoatChallengePage {
    param(
        [Parameter(Mandatory)][System.Windows.Window]$Window,
        [Parameter(Mandatory)]$Challenge
    )
    $xaml = Read-EntraGoatXaml -RelativePath 'Views/ChallengePage.xaml'
    $page = ConvertTo-EntraGoatElement -Xaml $xaml
    $theme = Get-EntraGoatTheme

    $badgesPanel = $page.FindName('BadgesPanel')
    $titleText   = $page.FindName('TitleText')
    $descText    = $page.FindName('DescriptionText')
    $credsPanel  = $page.FindName('CredentialsPanel')
    $flagArea    = $page.FindName('FlagArea')
    $hintsPanel  = $page.FindName('HintsPanel')
    $setupBtn    = $page.FindName('SetupButton')
    $cleanupBtn  = $page.FindName('CleanupButton')
    $solutionBtn = $page.FindName('SolutionButton')

    $state = Get-EntraGoatState
    $isCompleted = $state.Completed -contains $Challenge.Id

    # Badges
    [void]$badgesPanel.Children.Add((New-EntraGoatBadge -Text "Challenge #$($Challenge.Id)" -ColorHex $theme.Primary -Filled $false))
    $diffColor = switch ($Challenge.Difficulty) {
        'Beginner'     { $theme.Beginner }
        'Intermediate' { $theme.Intermediate }
        'Advanced'     { $theme.Advanced }
        default        { $theme.TextSecondary }
    }
    [void]$badgesPanel.Children.Add((New-EntraGoatBadge -Text $Challenge.Difficulty.ToUpper() -ColorHex $diffColor -Filled $false))
    if ($isCompleted) {
        [void]$badgesPanel.Children.Add((New-EntraGoatBadge -Text 'COMPLETED' -ColorHex $theme.Success -Filled $true))
    }

    # Title + icon + description
    $titleText.Text = $Challenge.Title
    $challengeIcon = $page.FindName('ChallengeIcon')
    $iconIdx = ($Challenge.Id - 1) % $script:ShuffledIcons.Count
    $iconFile = $script:ShuffledIcons[$iconIdx]
    if ($iconFile) {
        $iconPath = Join-Path (Split-Path (Get-EntraGoatRootPath)) "icons\$iconFile"
        if (Test-Path $iconPath) {
            $challengeIcon.Source = [System.Windows.Media.Imaging.BitmapImage]::new([uri]$iconPath)
        }
    }
    $descText.Text  = $Challenge.Description

    # Credentials
    $labelMap = @{
        Username             = 'Username'
        Password             = 'Password'
        Certificate          = 'Certificate'
        ClientId             = 'Client Id'
        ClientSecret         = 'Client Secret'
        ServicePrincipalName = 'Service Principal'
        AppId                = 'App Id'
        AppName              = 'App Name'
    }
    foreach ($k in $Challenge.StartingCredentials.Keys) {
        $label = if ($labelMap.ContainsKey($k)) { $labelMap[$k] } else { $k }
        [void]$credsPanel.Children.Add((New-EntraGoatCredentialRow -Label $label -Value "$($Challenge.StartingCredentials[$k])"))
    }

    # Flag area
    if ($isCompleted) {
        $flagArea.Content = New-EntraGoatCompletedArea -Challenge $Challenge
    } else {
        $flagArea.Content = New-EntraGoatFlagSubmitPanel -Challenge $Challenge -Window $Window -FlagArea $flagArea -BadgesPanel $badgesPanel
    }

    # Hints
    for ($i = 0; $i -lt $Challenge.Hints.Count; $i++) {
        [void]$hintsPanel.Children.Add((New-EntraGoatHintExpander -Index ($i + 1) -Text $Challenge.Hints[$i]))
    }

    # Terminal hint text (shown after launching a script)
    $terminalHint = $page.FindName('TerminalHintText')

    # Setup button — runs the script in the same terminal (no new window)
    $setupBtn.Tag = @{
        Id = $Challenge.Id; Type = 'Setup'; Hint = $terminalHint
    }
    $setupBtn.Add_Click({
        $t = $this.Tag
        try {
            $p = Resolve-EntraGoatScript -Id $t.Id -Type $t.Type
        } catch {
            [System.Windows.MessageBox]::Show("$_", 'EntraGoat - Error', 'OK', 'Error') | Out-Null
            return
        }
        $msg = "Run the Setup script for Challenge $($t.Id)?`n`nThis will modify your Entra ID tenant."
        $res = [System.Windows.MessageBox]::Show($msg, 'EntraGoat - Confirm', 'YesNo', 'Warning')
        if ($res -ne 'Yes') { return }
        Start-Process pwsh -ArgumentList "-File", "`"$p`"" -NoNewWindow
        $t.Hint.Visibility = 'Visible'
    })

    # Cleanup button — runs the cleanup script in the same terminal (no new window)
    $cleanupBtn.Tag = @{
        Id = $Challenge.Id; Type = 'Cleanup'; Hint = $terminalHint
    }
    $cleanupBtn.Add_Click({
        $t = $this.Tag
        try {
            $p = Resolve-EntraGoatScript -Id $t.Id -Type $t.Type
        } catch {
            [System.Windows.MessageBox]::Show("$_", 'EntraGoat - Error', 'OK', 'Error') | Out-Null
            return
        }
        $msg = "Run the Cleanup script for Challenge $($t.Id)?`n`nThis will remove scenario resources from your Entra ID tenant."
        $res = [System.Windows.MessageBox]::Show($msg, 'EntraGoat - Confirm', 'YesNo', 'Warning')
        if ($res -ne 'Yes') { return }
        Start-Process pwsh -ArgumentList "-File", "`"$p`"" -NoNewWindow
        $t.Hint.Visibility = 'Visible'
    })

    # Solution button — navigates to read-only script viewer
    $solutionBtn.Tag = @{ Win = $Window; Id = $Challenge.Id; Type = 'Solution' }
    $solutionBtn.Add_Click({
        $t = $this.Tag
        try {
            $p = Resolve-EntraGoatScript -Id $t.Id -Type $t.Type
            Navigate-EntraGoatPage -Window $t.Win -View 'Script' -Params @{ ScriptType = $t.Type; ScriptPath = $p }
        } catch { [System.Windows.MessageBox]::Show("$_", 'EntraGoat - Error', 'OK', 'Error') | Out-Null }
    })

    return $page
}

function global:Build-EntraGoatScriptPage {
    param(
        [Parameter(Mandatory)][System.Windows.Window]$Window,
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$ScriptPath,
        [string]$ScriptType = ''
    )
    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        [System.Windows.MessageBox]::Show("Script not found: $ScriptPath", 'EntraGoat - Error', 'OK', 'Error') | Out-Null
        return $null
    }
    $content = Get-Content -LiteralPath $ScriptPath -Raw
    $xaml = Read-EntraGoatXaml -RelativePath 'Views/ScriptPage.xaml'
    $page = ConvertTo-EntraGoatElement -Xaml $xaml

    $page.FindName('HeaderText').Text = $Title
    $page.FindName('PathText').Text   = $ScriptPath
    $page.FindName('ScriptBox').Text  = $content

    # Store context for button handlers
    $ctx = @{ Content = $content; ScriptPath = $ScriptPath; Win = $Window }

    $copyBtn = $page.FindName('CopyButton')
    $copyBtn.Tag = $ctx
    $copyBtn.Add_Click({
        $c = $this.Tag
        try {
            [System.Windows.Clipboard]::SetText($c.Content)
            [System.Windows.MessageBox]::Show('Script copied to clipboard.', 'EntraGoat') | Out-Null
        } catch {
            [System.Windows.MessageBox]::Show("Copy failed: $_", 'EntraGoat - Error', 'OK', 'Error') | Out-Null
        }
    })

    $saveBtn = $page.FindName('SaveButton')
    $saveBtn.Tag = $ctx
    $saveBtn.Add_Click({
        $c = $this.Tag
        $dlg = New-Object Microsoft.Win32.SaveFileDialog
        $dlg.Filter = 'PowerShell script (*.ps1)|*.ps1|All files (*.*)|*.*'
        $dlg.FileName = [System.IO.Path]::GetFileName($c.ScriptPath)
        if ($dlg.ShowDialog($c.Win)) {
            try {
                Set-Content -LiteralPath $dlg.FileName -Value $c.Content -Encoding UTF8
                [System.Windows.MessageBox]::Show("Saved to: $($dlg.FileName)", 'EntraGoat') | Out-Null
            } catch {
                [System.Windows.MessageBox]::Show("Save failed: $_", 'EntraGoat - Error', 'OK', 'Error') | Out-Null
            }
        }
    })

    $runBtn = $page.FindName('RunButton')
    if ($ScriptType -eq 'Solution') {
        $runBtn.Visibility = 'Collapsed'
    } else {
        $runBtn.Tag = $ctx
        $runBtn.Add_Click({
            $c = $this.Tag
            $msg = "About to execute:`n`n  $($c.ScriptPath)`n`nThis will run in the current PowerShell session and may modify your Entra ID tenant. Continue?"
            $res = [System.Windows.MessageBox]::Show($msg, 'EntraGoat - Confirm Execution', 'YesNo', 'Warning')
            if ($res -ne 'Yes') { return }
            $c.Win.Close()
            try {
                Invoke-EntraGoatScript -Path $c.ScriptPath
            } catch {
                Write-Host "EntraGoat: script error: $_" -ForegroundColor Red
            }
        })
    }

    return $page
}

function global:Show-EntraGoatMainWindow {
    param(
        [Parameter(Mandatory)]$Challenges
    )
    $xaml = Read-EntraGoatXaml -RelativePath 'Views/MainWindow.xaml'
    $win = ConvertTo-EntraGoatWindow -Xaml $xaml

    # Navigation state stored on the window
    $win.Tag = @{
        Challenges         = $Challenges
        CurrentView        = 'Home'
        CurrentChallengeId = $null
        CurrentScriptType  = $null
    }

    # Wire persistent nav buttons (once) — handlers read state at click-time
    $backBtn = $win.FindName('BackButton')
    $backBtn.Tag = $win
    $backBtn.Add_Click({
        $w = $this.Tag
        $nav = $w.Tag
        switch ($nav.CurrentView) {
            'Challenge' { Navigate-EntraGoatPage -Window $w -View 'Home' }
            'Script'    { Navigate-EntraGoatPage -Window $w -View 'Challenge' -Params @{ ChallengeId = $nav.CurrentChallengeId } }
        }
    })

    $prevBtn = $win.FindName('PrevButton')
    $prevBtn.Tag = $win
    $prevBtn.Add_Click({
        $w = $this.Tag
        $nav = $w.Tag
        $newId = $nav.CurrentChallengeId - 1
        if ($newId -ge 1) {
            Navigate-EntraGoatPage -Window $w -View 'Challenge' -Params @{ ChallengeId = $newId }
        }
    })

    $nextBtn = $win.FindName('NextButton')
    $nextBtn.Tag = $win
    $nextBtn.Add_Click({
        $w = $this.Tag
        $nav = $w.Tag
        $total = ($nav.Challenges | Measure-Object).Count
        $newId = $nav.CurrentChallengeId + 1
        if ($newId -le $total) {
            Navigate-EntraGoatPage -Window $w -View 'Challenge' -Params @{ ChallengeId = $newId }
        }
    })

    # Initial page
    Navigate-EntraGoatPage -Window $win -View 'Home'

    [void]$win.ShowDialog()
}

function New-EntraGoatBadge {
    param([string]$Text, [string]$ColorHex, [bool]$Filled)
    $border = [System.Windows.Controls.Border]::new()
    $brush  = New-EntraGoatBrush $ColorHex
    $border.BorderBrush = $brush
    $border.BorderThickness = '1'
    $border.CornerRadius = '12'
    $border.Padding = '10,3'
    $border.Margin = '0,0,8,0'
    if ($Filled) { $border.Background = $brush }
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text = $Text
    $tb.Foreground = if ($Filled) { New-EntraGoatBrush '#0A0A0A' } else { $brush }
    $tb.FontSize = 11
    $tb.FontWeight = 'SemiBold'
    $tb.FontFamily = (Get-EntraGoatTheme).FontUI
    $border.Child = $tb
    return $border
}

function New-EntraGoatCredentialRow {
    param([string]$Label, [string]$Value)
    $theme = Get-EntraGoatTheme
    $stack = [System.Windows.Controls.StackPanel]::new()
    $stack.Margin = '0,0,0,8'
    $labelTb = [System.Windows.Controls.TextBlock]::new()
    $labelTb.Text = "${Label}:"
    $labelTb.Foreground = New-EntraGoatBrush $theme.TextSecondary
    $labelTb.FontSize = 11
    $labelTb.FontFamily = $theme.FontMono
    $valueBorder = [System.Windows.Controls.Border]::new()
    $valueBorder.Background = New-EntraGoatBrush $theme.BgDarkest
    $valueBorder.BorderBrush = New-EntraGoatBrush $theme.BorderColor
    $valueBorder.BorderThickness = '1'
    $valueBorder.CornerRadius = '4'
    $valueBorder.Padding = '8,4'
    $valueBorder.Margin = '0,3,0,0'
    $valueTb = [System.Windows.Controls.TextBox]::new()
    $valueTb.Text = $Value
    $valueTb.IsReadOnly = $true
    $valueTb.Background = 'Transparent'
    $valueTb.BorderThickness = '0'
    $valueTb.Foreground = New-EntraGoatBrush $theme.Primary
    $valueTb.FontSize = 12
    $valueTb.FontFamily = $theme.FontMono
    $valueBorder.Child = $valueTb
    [void]$stack.Children.Add($labelTb)
    [void]$stack.Children.Add($valueBorder)
    return $stack
}

function New-EntraGoatHintExpander {
    param([int]$Index, [string]$Text)
    $theme = Get-EntraGoatTheme
    $exp = [System.Windows.Controls.Expander]::new()
    $exp.Header = "Hint $Index"
    $exp.Foreground = New-EntraGoatBrush $theme.Primary
    $exp.Background = New-EntraGoatBrush $theme.BgMedium
    $exp.BorderBrush = New-EntraGoatBrush $theme.BorderColor
    $exp.BorderThickness = '1'
    $exp.Padding = '10'
    $exp.Margin = '0,0,0,6'
    $exp.FontFamily = $theme.FontUI
    $exp.FontWeight = 'Bold'
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text = $Text
    $tb.TextWrapping = 'Wrap'
    $tb.Foreground = New-EntraGoatBrush $theme.TextPrimary
    $tb.FontSize = 12
    $tb.FontWeight = 'Bold'
    $tb.FontFamily = $theme.FontUI
    $tb.Margin = '4,6,4,4'
    $exp.Content = $tb
    return $exp
}

function New-EntraGoatFlagSubmitPanel {
    param(
        [Parameter(Mandatory)]$Challenge,
        [Parameter(Mandatory)]$Window,
        [Parameter(Mandatory)]$FlagArea,
        [Parameter(Mandatory)]$BadgesPanel
    )
    $theme = Get-EntraGoatTheme
    $stack = [System.Windows.Controls.StackPanel]::new()

    $header = [System.Windows.Controls.TextBlock]::new()
    $header.Text = 'Submit Flag'
    $header.Foreground = New-EntraGoatBrush $theme.TextPrimary
    $header.FontWeight = 'Bold'
    $header.FontFamily = $theme.FontUI
    $header.FontSize = 14
    $header.Margin = '0,0,0,8'
    [void]$stack.Children.Add($header)

    $row = [System.Windows.Controls.Grid]::new()
    $cd1 = [System.Windows.Controls.ColumnDefinition]::new(); $cd1.Width = '*'
    $cd2 = [System.Windows.Controls.ColumnDefinition]::new(); $cd2.Width = 'Auto'
    [void]$row.ColumnDefinitions.Add($cd1)
    [void]$row.ColumnDefinitions.Add($cd2)

    $inputBox = [System.Windows.Controls.TextBox]::new()
    $inputBox.Background = New-EntraGoatBrush $theme.BgDark
    $inputBox.Foreground = New-EntraGoatBrush $theme.TextPrimary
    $inputBox.BorderBrush = New-EntraGoatBrush $theme.BorderColor
    $inputBox.BorderThickness = '1'
    $inputBox.Padding = '10,8'
    $inputBox.FontFamily = $theme.FontMono
    $inputBox.FontSize = 13
    [System.Windows.Controls.Grid]::SetColumn($inputBox, 0)

    $msg = [System.Windows.Controls.TextBlock]::new()
    $msg.FontFamily = $theme.FontUI
    $msg.FontSize = 12
    $msg.Margin = '0,8,0,0'
    $msg.TextWrapping = 'Wrap'

    $btn = [System.Windows.Controls.Button]::new()
    $btn.Content = 'Submit Flag'
    $btn.Background = New-EntraGoatBrush $theme.Primary
    $btn.Foreground = New-EntraGoatBrush '#0A0A0A'
    $btn.BorderThickness = '0'
    $btn.Padding = '16,8'
    $btn.Margin = '8,0,0,0'
    $btn.FontWeight = 'Bold'
    $btn.Cursor = 'Hand'
    [System.Windows.Controls.Grid]::SetColumn($btn, 1)

    # Store references on the button's Tag so the handler can access them without closures.
    $btn.Tag = @{
        InputBox    = $inputBox
        Msg         = $msg
        Challenge   = $Challenge
        Window      = $Window
        FlagArea    = $FlagArea
        BadgesPanel = $BadgesPanel
    }
    $btn.Add_Click({
        $t = $this.Tag
        $entered = $t.InputBox.Text.Trim()
        if ([string]::IsNullOrEmpty($entered)) { return }
        if ($entered -ceq $t.Challenge.Flag) {
            Set-EntraGoatChallengeCompleted -Id $t.Challenge.Id | Out-Null
            $t.Msg.Text = 'Correct flag! Challenge completed.'
            $t.Msg.Foreground = New-EntraGoatBrush (Get-EntraGoatTheme).Success
            # Swap flag area to completed view
            $t.FlagArea.Content = New-EntraGoatCompletedArea -Challenge $t.Challenge
            # Update badges
            $thm = Get-EntraGoatTheme
            $t.BadgesPanel.Children.Clear()
            [void]$t.BadgesPanel.Children.Add((New-EntraGoatBadge -Text "Challenge #$($t.Challenge.Id)" -ColorHex $thm.Primary -Filled $false))
            $dc = switch ($t.Challenge.Difficulty) { 'Beginner' { $thm.Beginner } 'Intermediate' { $thm.Intermediate } 'Advanced' { $thm.Advanced } default { $thm.TextSecondary } }
            [void]$t.BadgesPanel.Children.Add((New-EntraGoatBadge -Text $t.Challenge.Difficulty.ToUpper() -ColorHex $dc -Filled $false))
            [void]$t.BadgesPanel.Children.Add((New-EntraGoatBadge -Text 'COMPLETED' -ColorHex $thm.Success -Filled $true))
        } else {
            $t.Msg.Text = '[ERROR] Incorrect flag. Try again!'
            $t.Msg.Foreground = New-EntraGoatBrush (Get-EntraGoatTheme).Danger
        }
    })

    # Also wire Enter key on the input box (store same Tag)
    $inputBox.Tag = $btn
    $inputBox.Add_KeyDown({
        param($s, $e)
        if ($e.Key -eq 'Return') {
            $s.Tag.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
        }
    })

    [void]$row.Children.Add($inputBox)
    [void]$row.Children.Add($btn)
    [void]$stack.Children.Add($row)
    [void]$stack.Children.Add($msg)
    return $stack
}

function New-EntraGoatCompletedArea {
    param([Parameter(Mandatory)]$Challenge)
    $theme = Get-EntraGoatTheme
    $border = [System.Windows.Controls.Border]::new()
    $border.BorderBrush = New-EntraGoatBrush $theme.Success
    $border.BorderThickness = '1'
    $border.CornerRadius = '6'
    $border.Background = '#0F1F12'
    $border.Padding = '14'
    $stack = [System.Windows.Controls.StackPanel]::new()
    $h = [System.Windows.Controls.TextBlock]::new()
    $h.Text = 'Challenge Completed!'
    $h.Foreground = New-EntraGoatBrush $theme.Success
    $h.FontWeight = 'Bold'
    $h.FontSize = 16
    $h.FontFamily = $theme.FontUI
    [void]$stack.Children.Add($h)
    $f = [System.Windows.Controls.TextBlock]::new()
    $f.Text = "Flag: $($Challenge.Flag)"
    $f.Foreground = New-EntraGoatBrush $theme.TextPrimary
    $f.FontFamily = $theme.FontMono
    $f.FontSize = 12
    $f.Margin = '0,6,0,0'
    $f.TextWrapping = 'Wrap'
    [void]$stack.Children.Add($f)
    $border.Child = $stack
    return $border
}
