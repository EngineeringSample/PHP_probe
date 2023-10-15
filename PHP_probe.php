<!DOCTYPE html>
<html>
<head>
    <title>PHP Probe Example</title>
    <meta http-equiv="refresh" content="5">
</head>
<body>
<h1>PHP Probe Example</h1>

<!-- PHP Data Display Section -->
<div id="php-data">
    <?php
    // Get CPU information
    $cpuInfo = shell_exec('cat /proc/cpuinfo | grep "model name"');
    echo "<h2>CPU Information:</h2>";
    echo $cpuInfo;
    echo "<br>";

    // Get memory information
    $memoryInfo = shell_exec('free -m');
    echo "<h2>Memory Information:</h2>";
    echo nl2br($memoryInfo);
    echo "<br>";

    // Get disk information
    $diskInfo = shell_exec('df -h');
    echo "<h2>Disk Information:</h2>";
    echo nl2br($diskInfo);
    echo "<br>";

    // Get network traffic information
    $trafficInfo = shell_exec('cat /proc/net/dev | grep "eth0"');
    $trafficData = explode(" ", preg_replace('/\s+/', ' ', trim($trafficInfo));

    $downloadTraffic = round($trafficData[1] / 1024, 2);
    $uploadTraffic = round($trafficData[9] / 1024, 2);
    $totalTraffic = $downloadTraffic + $uploadTraffic;

    echo "<h2>Real-time Traffic Information:</h2>";
    echo "<p id='download-traffic'>Download Traffic: $downloadTraffic KB</p>";
    echo "<p id='upload-traffic'>Upload Traffic: $uploadTraffic KB</p>";
    echo "<p id='total-traffic'>Total Traffic: $totalTraffic KB</p>";

    // Get IP addresses
    $ipv4 = shell_exec('hostname -I | cut -d" " -f1');
    $ipv6 = shell_exec('hostname -I | cut -d" " -f2');
    echo "<h2>IP Addresses:</h2>";
    echo "IPv4 Address: " . $ipv4 . "<br>";
    echo "IPv6 Address: " . $ipv6 . "<br>";

    // Get geolocation information for public IPv4 address (requires external API)
    $externalIPv4 = file_get_contents("http://ip-api.com/json/" . $ipv4);
    $externalIPv4Info = json_decode($externalIPv4, true);
    echo "<h2>Geolocation Information for Public IPv4 Address:</h2>";
    echo "IP Address: " . $externalIPv4Info['query'] . "<br>";
    echo "Location: " . $externalIPv4Info['city'] . ", " . $externalIPv4Info['regionName'] . ", " . $externalIPv4Info['country'] . "<br>";

    // Get geolocation information for public IPv6 address (requires external API)
    $externalIPv6 = file_get_contents("http://ip-api.com/json/" . $ipv6);
    $externalIPv6Info = json_decode($externalIPv6, true);
    echo "<h2>Geolocation Information for Public IPv6 Address:</h2>";
    echo "IP Address: " . $externalIPv6Info['query'] . "<br>";
    echo "Location: " . $externalIPv6Info['city'] . ", " . $externalIPv6Info['regionName'] . ", " . $externalIPv6Info['country'] . "<br>";

    // Get PHP version information
    $phpVersion = phpversion();
    echo "<h2>PHP Version Information:</h2>";
    echo "PHP Version: " . $phpVersion . "<br>";

    // DNS address check
    $dnsCheck = shell_exec('nslookup google.com');
    echo "<h2>DNS Address Check:</h2>";
    echo nl2br($dnsCheck);

    // Hostname check
    $hostnameCheck = shell_exec('hostname');
    echo "<h2>Hostname Check:</h2>";
    echo "Hostname: " . $hostnameCheck . "<br>";

    // Common port checks
    $portChecks = array(80, 443, 22, 25, 8080);
    echo "<h2>Common Port Checks:</h2>";
    foreach ($portChecks as $port) {
        $portCheckResult = shell_exec("nc -z -v -w 1 $ipv4 $port 2>&1");
        echo "Port $port: ";
        if (strpos($portCheckResult, "succeeded") !== false) {
            echo "Open<br>";
        } else {
            echo "Closed<br>";
        }
    }
    ?>
</div>
<!-- PHP Data Display Section End -->

<!-- JavaScript Real-time Update Section -->
<script type="text/javascript">
    // Periodically request data from the PHP script on the server
    function fetchData() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'update.php', true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                // Replace old data with new data
                document.getElementById('php-data').innerHTML = xhr.responseText;
            }
        };
        xhr.send();
    }

    fetchData(); // Initial data retrieval
    setInterval(fetchData, 5000); // Request new data every 5 seconds
</script>
<!-- JavaScript Real-time Update Section End -->

</body>
</html>
