#東京:05
#中山:06 

function GetData($uri){
$response = Invoke-WebRequest $uri
$racedata = $response.parsedHtml.getelementsbyClassname("racedata")| select -First 1
if($racedata -eq $null){
    return
}
$otherdata = $response.parsedHtml.getelementsbyClassname("race_otherdata")| select -First 1
$raceDate = $otherdata.getElementsByTagName("P") | Select -First 1
$raceDate = $raceDate.innerHtml
$raceDate = $raceDate.Substring(0,$raceDate.Length -4)


$dt = $racedata.getElementsByTagName("DT") | Select -First 1
$title = [System.Text.Encoding]::GetEncoding("EUC-JP").GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes( $response.parsedHtml.title) )

$raceRank
if($title.contains("500万下")){
    $raceRank = "500"
} elseif($title.contains("1000万下")){
    $raceRank = "1000"
} elseif($title.contains("1600万下")){
    $raceRank = "1600"
} elseif($title.contains("(L)") -or $title.contains("(OP)")){
    $raceRank = "OP"
} elseif($title.contains("G3")){
    $raceRank = "G3"
} elseif($title.contains("G2")){
    $raceRank = "G2"
} elseif($title.contains("G1")){
    $raceRank = "G1"
}

$raceCondition = $racedata.getElementsByTagName("P") | Select -First 1
$raceConditionTxt =[System.Text.Encoding]::GetEncoding("EUC-JP").GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($raceCondition.innerHtml) )
$raceCourseType = $raceConditionTxt.Substring(0,1)
$raceCourseDistance = $raceConditionTxt.Substring(1,4)
$raceCourseTurn = $raceConditionTxt.Substring($raceConditionTxt.Length -2,1)
$raceInfo = $racedata.getElementsByTagName("P") | Select -Last 1
$raceInfoTxt = [System.Text.Encoding]::GetEncoding("EUC-JP").GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($raceInfo.innerHtml) )
$raceInfoTxtList = $raceInfoTxt -split '&nbsp;/&nbsp;'
$weather = $raceInfoTxtList[0] -split ':' | Select-Object -Last 1
$groundCondition = $raceInfoTxtList[1] -split ':' | Select-Object -Last 1
$raceTable = $response.parsedHtml.getElementsByTagName("table")| select -First 1
$dataList = @()
$properties =@("raceDate","raceRank","raceCourseType","raceCourseDistance","raceCourseTurn","weather","groundCondition","rank","frame","num","name","sexAge","heavy","jockey","time","difference","population","odds","l3f","corner","trainer","weight")
$objs = foreach($row in ($raceTable.rows| select -skip 1))
{
    $row.Cells| foreach -Begin {
        $obj = [ordered]@{}
        $obj +=@{$properties[0] = $raceDate}
        $obj +=@{$properties[1] = $raceRank}
        $obj +=@{$properties[2] = $raceCourseType}
        $obj +=@{$properties[3] = $raceCourseDistance}
        $obj +=@{$properties[4] = $raceCourseTurn}
        $obj +=@{$properties[5] = $weather}
        $obj +=@{$properties[6] = $groundCondition}
        $index = 7
    } -Process {
        if($_.innerText -eq $null -Or $_.innerText -eq ""){
            $obj += @{$properties[$index] = ""}
        }
        else{
            $obj += @{$properties[$index] = [System.Text.Encoding]::GetEncoding("EUC-JP").GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($_.innerText) )}
        }
        $index++
    } -End {
        [pscustomobject]$obj
    }
}


$objs.GetEnumerator() | Select  @{N="raceDate"; E={$_.raceDate}}, @{N="raceRank"; E={$_.raceRank}},@{N="raceCourseType"; E={$_.raceCourseType}}, @{N="raceCourseDistance"; E={$_.raceCourseDistance}}, @{N="raceCourseTurn"; E={$_.raceCourseTurn}}, @{N="weather"; E={$_.weather}}`
, @{N="groundCondition"; E={$_.groundCondition}}, @{N="rank"; E={$_.rank}}, @{N="frame"; E={$_.frame}}, @{N="num"; E={$_.num}}, @{N="name"; E={$_.name}},@{N="sexAge"; E={$_.sexAge}}, @{N="heavy"; E={$_.heavy}}`
, @{N="jockey"; E={$_.jockey}}, @{N="time"; E={$_.time}}, @{N="difference"; E={$_.difference}}, @{N="population"; E={$_.population}}, @{N="odds"; E={$_.odds}}, @{N="l3f"; E={$_.l3f}}`
, @{N="corner"; E={$_.corner}}, @{N="trainer"; E={$_.trainer}}, @{N="weight"; E={$_.weight}}   |Export-Csv C:\Users\hiroki\Documents\horseraceAnalyze\scraping\output.csv -Encoding Default -NoTypeInformation -Append

}

$year = 2018

for ($i=0; $i -lt 10; $i++){
  for ($j=0; $j -lt 6; $j++){
    for ($k=0; $k -lt 12; $k++){
      for ($l=0; $l -lt 12; $l++){
        $basho = "{0:D2}" -f $i  
        $kai  = "{0:D2}" -f $j  
        $nichi  = "{0:D2}" -f $k  
        $raceNum  = "{0:D2}" -f $l 
        $uri = "https://race.netkeiba.com/?pid=race&id=c" + $year  + $basho + $kai + $nichi + $raceNum + "&mode=result"
        GetData($uri)
        }
    }
  }
}
