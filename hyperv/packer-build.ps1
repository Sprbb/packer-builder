param ([String] $FILE, [String] $HYPERVISOR, [String] $GITHUB_URL, [String] $ISO_URL)

if (!(Test-Path work)) {
  Write-Host "Cloning $GITHUB_URL"
  git clone $GITHUB_URL work
}

cd work

git checkout -- *.json
git pull
Remove-Item *.box
Remove-Item -recurse output*
$isoflag=""

# Allow me (user of that GitHub repo) to SSH into the machine.
$keyPath = "~\.ssh\authorized_keys"
if (!(Test-Path ~\.ssh)) {
  New-Item -Type Directory ~\.ssh > $null
}
$githubKeysUrl = $GITHUB_URL -replace "\/[^\/]+$", ".keys"
$githubSshKey = $(curl.exe $githubKeysUrl)
$githubSshKey | Out-File $keyPath -Append -Encoding Ascii

if ( "$ISO_URL" -eq "" ) {
  Write-Host "Use default ISO."
} else {
  Write-Host "Use local ISO."
  if (!(Test-Path local.iso)) {
    curl.exe -Lo local.iso $ISO_URL
  }
  $isoflag="--var iso_url=./local.iso"
}
$only="--only=$HYPERVISOR-iso"

Write-Host "Running packer build $only --var headless=true ${FILE}.json"

# Use a CMD.exe script to have real pipes that do not buffer long-running packer builds
@"
packer build $only $isoflag --var headless=true $FILE.json | ""C:\Program Files\Git\usr\bin\tee.exe"" -a packer-build.log
ping 127.0.0.1 -n 6 > nul
taskkill /F /IM tail.exe
"@ | Out-File -Encoding Ascii packer-build.bat

Start-Process cmd.exe -ArgumentList "/C", "packer-build.bat"
