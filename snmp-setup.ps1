# --- SNMP SERVİSİNİ YÜKLE (Kurulu değilse)
if (-not (Get-WindowsFeature -Name SNMP-Service).Installed) {
    Write-Host "🛠 SNMP özelliği yükleniyor..."
    Install-WindowsFeature -Name SNMP-Service -IncludeManagementTools
} else {
    Write-Host "✅ SNMP servisi zaten yüklü."
}

# --- SNMP SERVİSİNİ OTOMATİK BAŞLAT VE BAŞLAT
Set-Service -Name SNMP -StartupType Automatic
Start-Service -Name SNMP -ErrorAction SilentlyContinue

# --- RO COMMUNITY STRING EKLE
Write-Host "🔐 RO community ekleniyor: wcdZt7KyFyuEHpwt"
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name "wcdZt7KyFyuEHpwt" -PropertyType DWord -Value 4 -Force

# --- SYSLOCATION VE SYSCONTACT EKLE
Write-Host "📍 syslocation ve syscontact ekleniyor"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters" -Name "SysLocation" -Value "AZ,Baku"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters" -Name "SysContact" -Value "emil.musayev@azintelecom.az"

# --- SNMP SERVİSİNİ GÜNCELLEMEK İÇİN YENİDEN BAŞLAT
Write-Host "🔄 SNMP servisi yeniden başlatılıyor..."
Stop-Service -Name SNMP -Force
Start-Sleep -Seconds 2
Start-Service -Name SNMP

# --- FIREWALL'DA 161/UDP AÇ
if (-not (Get-NetFirewallRule | Where-Object {$_.DisplayName -eq "Allow SNMP UDP 161"})) {
    Write-Host "🧱 Güvenlik duvarı kuralı ekleniyor (UDP 161)..."
    New-NetFirewallRule -DisplayName "Allow SNMP UDP 161" -Direction Inbound -Protocol UDP -LocalPort 161 -Action Allow
} else {
    Write-Host "✅ Firewall kuralı zaten mevcut."
}

# --- SERVİS DURUMUNU GÖSTER
Write-Host "`n📋 SNMP Servis Durumu:"
Get-Service SNMP

# --- 161/UDP PORTU AÇIK MI?
Write-Host "`n🔍 UDP 161 Port Kontrolü (netstat):"
$netstatResult = netstat -an | Select-String ":161"
if ($netstatResult) {
    Write-Host "✅ UDP 161 dinleniyor:"
    $netstatResult | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "❌ UDP 161 dinlenmiyor!"
}
