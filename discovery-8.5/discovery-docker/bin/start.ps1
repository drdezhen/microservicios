# Java options and system properties to pass to the JVM when starting the service container
# Separate double-quoted options with a comma. For example:
# $jvmoptions = "-Xrs", "-Xms128m", "-Xmx128m", "-Dmy.system.property=/a folder with a space in it/"
$jvmoptions = "-Xrs", "-Xms128m", "-Xmx128m"

$java_home = (get-item env:"java_home").Value
$java_run = $java_home + "\bin\java.exe"
$currentPath = Get-Location
$scriptPath = $PSScriptRoot

cd $scriptPath\..
$rootFolder = Get-Location

$classpath = ".;config;bin"
$libFolder = ";lib\*"
$className = "com.sdl.delivery.service.ServiceContainer"
$serverPort = "--server.port=8082"

#set max size of request header to 64Kb
$maxHttpHeaderSize="--server.tomcat.max-http-header-size=65536"

$classpath = $classpath + $libFolder

foreach ($folder in Get-ChildItem -path $rootFolder -recurse | ?{ $_.PSIsContainer } | Resolve-Path -relative | Where { $_ -match 'services*' })
{
    $classpath = $folder + ";" + $folder + "\*;" + $classpath
}

$arguments = @()
foreach($arg in $args) {
    if ($arg -imatch "--server.port=""?[0-9]+") {
        $serverPort=$Matches[0]
    } elseif ($arg -imatch "-D.+") {
        $jvmoptions+=$arg
    } else {
		$arguments+=$arg
	}
}
$arguments+=$serverPort
$arguments+=$maxHttpHeaderSize

Try
{
    & $java_run $jvmoptions -cp $classpath $className $arguments
}
Finally
{
    cd $currentPath
}