#*************** BAZY DANYCH PRZESTRZENNYCH - automatyzacja przetwarzania ***************

#Data utworzenia skryptu: 05.12.2021 21:27:34 


$aktualnaData = Get-Date 
${TIMESTAMP}  = "{0:MM-dd-yyyy}" -f ($aktualnaData) 

$sciezka = "C:\Users\48692\Desktop\cwiczenie6"
$hasloPoczta = "twoje_haslo"

if( Test-Path $sciezka )
{
    Remove-Item -Path $sciezka -Recurse -Force
}
else
{
    New-Item -Path $sciezka -ItemType Directory

}
New-Item -Path "$sciezka\PROCESSED" -ItemType Directory
Move-Item -Path "C:\Users\48692\Downloads\Customers_old.csv" -Destination "$sciezka" -PassThru
Copy-Item -Path "C:\Users\48692\Desktop\zapytanie.txt" -Destination "$sciezka"

$sciezkaDoSkryptu = "C:\Users\48692\Desktop\SEMESTR_5\BAZY DANYCH PRZESTRZENNYCH\ĆWICZENIA\LAB_7\cwiczenie6.ps1"
$dataUtworzeniaSkryptu = Get-ItemProperty $sciezkaDoSkryptu | Format-Wide -Property CreationTime
"*************** BAZY DANYCH PRZESTRZENNYCH - automatyzacja przetwarzania ***************`n`nData utworzenia skryptu: " > "$sciezka\PROCESSED\cwiczenie6_${TIMESTAMP}.log"
$dataUtworzeniaSkryptu >> "$sciezka\PROCESSED\cwiczenie6_${TIMESTAMP}.log"


function zwrocDate
{
    param()

    $data = Get-Date
    $data = "{0:yyyy-MM-dd HH:mm:ss}" -f ($data) 
    $data
}

function zapiszDoPlikuLog
{
    param($komunikat)

    $pobierzDate = zwrocDate
    $pobierzDate + " - $komunikat - SUKCES!" >> "$sciezka\PROCESSED\cwiczenie6_${TIMESTAMP}.log"
}

#A)--------------------------------------------- POBRANIE PLIKU --------------------------------------------------

try
{
    $adresUrl = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
    $plik = "$sciezka\Customers_Nov2021.zip"

    $webclient = New-Object System.Net.WebClient
    $webclient.DownloadFile($adresUrl, $plik)

    zapiszDoPlikuLog("Pobranie pliku")
}
catch
{
    Write-Warning "Pobranie pliku nie powiodło się."
}



#B)--------------------------------------------- ROZPAKOWANIE PLIKU ----------------------------------------------

try
{
    $WinRAR = "C:\Program Files\WinRAR\WinRAR.exe"
    $haslo = "agh"
    Set-Location $sciezka
    Start-Process "$WinRAR" -ArgumentList "x -y `"$plik`" -p$haslo"

    #$7zip = "C:\Program Files (x86)\7-Zip\7z.exe"
    #Start-Process "$7zip" -ArgumentList "x -o`"$sciezka`" -y `"$plik`" -p$haslo"

    zapiszDoPlikuLog("Rozpakowanie pliku")
}
catch
{
    Write-Warning "Rozpakowanie pliku nie powiodło się."
}

#C)--------------------------------------------- POPRAWNOŚĆ PLIKU ------------------------------------------------

try
{
    #$nrIndeksu = Read-Host "Podaj numer indeksu: "
    $nrIndeksu = "404407"

    sleep 3
    $zawartoscPliku_1 = Get-Content "$sciezka\Customers_Nov2021.csv"
    $zawartoscPliku_2 = Get-Content "$sciezka\Customers_old.csv"

    $plikBezPustychLini = for($i = 0; $i -lt $zawartoscPliku_1.Count; $i++)
    {
        if($zawartoscPliku_1[$i] -ne "")
        {
            $zawartoscPliku_1[$i]  
        }
    } 

    $plikBezPustychLini[0] > "$sciezka\Customers_Nov2021.bad_${TIMESTAMP}"

    for($i = 1; $i -lt $plikBezPustychLini.Count; $i++)
    {

        for($j = 0; $j -lt $zawartoscPliku_2.Count; $j++)
        {
            if($plikBezPustychLini[$i] -eq $zawartoscPliku_2[$j])
            {
                $plikBezPustychLini[$i] >> "$sciezka\Customers_Nov2021.bad_${TIMESTAMP}"
                $plikBezPustychLini[$i] = $null
            }
        }
    } 

    $plikBezPustychLini > "$sciezka\Customers_Nov2021.csv" 
   # $poprawnyPlik = Get-Content "$sciezka\Customers_Nov2021.csv" 

    $poprawnyPlik = Import-Csv "$sciezka\Customers_Nov2021.csv" -Delimiter ","


    zapiszDoPlikuLog("Poprawność pliku")
}
catch
{
    Write-Warning "Sprawdzenie poprawności pliku nie powiodło się."
}


#D)------------------------------------------ TWORZENIE TABELI W POSTGRESQL --------------------------------------------
 
try
{
    #Install-Module PostgreSQLCmdlets
    Set-Location 'C:\Program Files\PostgreSQL\13\bin\'

    $User = "postgres"
    $Password = "$hasloPoczta"
    $env:PGPASSWORD = $Password
    $Database = "postgres"
    $NewDatabase = "cwiczenie6_customers"
    $newTable = "CUSTOMERS_$nrIndeksu"
    $Serwer  ="PostgreSQL 13"
    $Port = "5432"

    psql -U postgres -d $NewDatabase -w -c "DROP TABLE IF EXISTS $newTable"
    psql -U postgres -d $Database -w -c "DROP DATABASE IF EXISTS $NewDatabase"

    psql -U postgres -d $Database -w -c "CREATE DATABASE $NewDatabase"
    psql  -U postgres -d $NewDatabase -w -c "CREATE TABLE IF NOT EXISTS $newTable (first_name VARCHAR(50), last_name VARCHAR(50) PRIMARY KEY, email VARCHAR(50), lat float NOT NULL, long float NOT NULL)"

    zapiszDoPlikuLog("Tworzenie tabeli w PostgreSQL")
}
catch
{
    Write-Warning "Utworzenie tabeli nie powiodło się."
}

#-------------------------------------------- WCZYTANIE DANYCH Z PLIKU DO BAZY -----------------------------------------

try
{

    for($i=0; $i -lt $poprawnyPlik.Count; $i++)
    {
        $imie = "'" + $poprawnyPlik[$i].first_name + "'"
        $nazwisko = "'" + $poprawnyPlik[$i].last_name + "'"
        $email = "'" + $poprawnyPlik[$i].email + "'"
        $lat = $poprawnyPlik[$i].lat
        $long = $poprawnyPlik[$i].long

        psql -U postgres -d $NewDatabase -w -c "INSERT INTO $newTable (first_name, last_name, email, lat, long) VALUES($imie, $nazwisko, $email, $lat, $long)"
    }

    <#$poprawnyPlik2 = $poprawnyPlik -replace ",", "','"

    for($i=1; $i -lt $poprawnyPlik.Count; $i++)
    {
        $poprawnyPlik2[$i] = "'" + $poprawnyPlik2[$i] + "'"
        $wczytaj = $poprawnyPlik2[$i]

        psql -U postgres -d $NewDatabase -w -c "INSERT INTO $newTable (first_name, last_name, email, lat, long) VALUES($wczytaj)"
    }#>
    
    psql -U postgres -d $NewDatabase -w -c "SELECT * FROM $newTable"

    zapiszDoPlikuLog("Wczytanie danych z pliku do bazy")
}
catch
{
    Write-Warning "Wczytanie danych z pliku do bazy nie powiodło się."
}

#------------------------------------------------ PRZENIESIENIE PLIKU ---------------------------------------------------

try
{
    Set-Location $sciezka
    ${TIMESTAMP2} = ${TIMESTAMP} + "_"
    Move-Item -Path "$sciezka\Customers_Nov2021.csv" -Destination "$sciezka\PROCESSED" -PassThru -ErrorAction Stop
    Rename-Item -Path "$sciezka\PROCESSED\Customers_Nov2021.csv" "${TIMESTAMP2}Customers_Nov2021.csv"

    zapiszDoPlikuLog("Przeniesienie pliku")
}
catch
{
    Write-Warning "Przeniesienie pliku nie powiodło się."
}

#------------------------------------------------- WYSŁANIE MAILA --------------------------------------------------------

try
{
    $zawartoscPoprawnegoPliku = Get-Content "$sciezka\PROCESSED\${TIMESTAMP2}Customers_Nov2021.csv"
    $zawartoscPlikuZBledami = Get-Content "$sciezka\Customers_Nov2021.bad_${TIMESTAMP}"

    $lWierszy = ($zawartoscPliku_1[1..$zawartoscPliku_1.Count]).Count
    $lPoprawnychWierszy = ($zawartoscPoprawnegoPliku[1..$zawartoscPoprawnegoPliku.Count]).Count
    $lDuplikatow = ($zawartoscPlikuZBledami[1..$zawartoscPlikuZBledami.Count]).Count
    $iDanych = $poprawnyPlik.Count

    $liczbaWierszy = "Liczba wierszy w pliku pobranym z internetu: $lWierszy`n"
    $liczbaPoprawnychWierszy = "Liczba poprawnych wierszy (po czyszczeniu): $lPoprawnychWierszy`n"
    $liczbaDuplikatow = "Liczba duplikatów w pliku wejściowym: $lDuplikatow`n"
    $iloscDanych = "Ilość danych załadowanych do tabeli $newTable : $iDanych`n"

    $nadawca = “pelkastudent@gmail.com”
    $odbiorca = “aleksandra.pelka191@gmail.com”
    $temat = "CUSTOMERS LOAD - ${TIMESTAMP}"
    $tresc = $liczbaWierszy + $liczbaPoprawnychWierszy + $liczbaDuplikatow + $iloscDanych

    $Message = new-object Net.Mail.MailMessage 
    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", 587) 
    $smtp.Credentials = New-Object System.Net.NetworkCredential("$nadawca", "$hasloPoczta"); 
    $smtp.EnableSsl = $true 
    $smtp.Timeout = 400000  
    $Message.From = "$nadawca" 
    $Message.To.Add("$odbiorca") 
    $Message.Subject = "$temat"
    $Message.Body = "$tresc"
    $smtp.Send($Message)

    zapiszDoPlikuLog("Wysłanie pierwszego maila")
}
catch
{
    Write-Warning "Wysłanie maila nie powiodło się."
}

#------------------------------------------------------- ZAPYTANIE ----------------------------------------------------

try
{
    $nowaTabela = "BEST_$newTable"
    psql -U postgres -d $NewDatabase -w -c "DROP TABLE IF EXISTS $nowaTabela"

    psql -U postgres -d $NewDatabase -w -c "CREATE EXTENSION postgis"
    psql -U postgres -d $NewDatabase -w -f "$sciezka\zapytanie.txt"
   
    zapiszDoPlikuLog("Wykonanie zapytania")
}
catch
{
    Write-Warning "Wykonanie zapytania nie powiodło się."
}

#------------------------------------------------------- EKSPORT ------------------------------------------------------

try
{

    $zapiszPlik = psql -U postgres -d $NewDatabase -w -c "SELECT * FROM $nowaTabela" 
    $tablica = @()

    for ($i=2; $i -lt $zapiszPlik.Count-2; $i++)
    {
        $dane = New-Object -TypeName PSObject
        $dane | Add-Member -Name 'first_name' -MemberType Noteproperty -Value $zapiszPlik[$i].Split( "|")[0].replace(" ", "")
        $dane | Add-Member -Name 'last_name' -MemberType Noteproperty -Value $zapiszPlik[$i].Split( "|")[1].replace(" ", "")
        $dane | Add-Member -Name 'odleglosc' -MemberType Noteproperty -Value $zapiszPlik[$i].Split( "|")[2].replace(" ", "")
        $tablica += $dane
    }

    $tablica | Export-Csv -Path "$sciezka\$nowaTabela.csv" -NoTypeInformation

    zapiszDoPlikuLog("Eksport do pliku .csv")
}
catch
{
    Write-Warning "Eksport do pliku nie powiódł się."
}

#------------------------------------------------------ KOMPRESJA -----------------------------------------------------

try
{
    Compress-Archive -Path "$sciezka\$nowaTabela.csv" -DestinationPath "$sciezka\$nowaTabela.zip"

    zapiszDoPlikuLog("Kompresja do .zip")
}
catch
{
    Write-Warning "Kompresja do .zip nie powiodła się."
}

#--------------------------------------------------- WYSŁANIE MAILA 2 -------------------------------------------------

try
{
    Get-ItemProperty "$sciezka\$nowaTabela.csv" | Format-Wide -Property CreationTime > "$sciezka\dataUtworzenia.txt"
    $dataUtworzenia = Get-Content "$sciezka\dataUtworzenia.txt"
    Remove-Item -Path "$sciezka\dataUtworzenia.txt"
    $dataUtworzenia = "Data utworzenia pliku: $dataUtworzenia`n"

    $liczbaWierszyEksport = ($zapiszPlik[2..(($zapiszPlik.Count)-3)]).Count
    $liczbaWierszyEksport = "Liczba wierszy w pliku: $liczbaWierszyEksport`n"

    $tresc = $dataUtworzenia + $liczbaWierszyEksport

    $Message.To.Add("$odbiorca") 
    $Message.Attachments.Add("$sciezka\$nowaTabela.zip") 
    $Message.Subject = "$temat"
    $Message.Body = "$tresc"
    $smtp.Send($Message)

    zapiszDoPlikuLog("Wysłanie maila z załącznikiem")
}
catch
{
    Write-Warning "Wysłanie maila z załącznikiem nie powiodło się."
}