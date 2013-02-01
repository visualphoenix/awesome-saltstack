<?php
// Connecting, selecting database
$dbconn = pg_connect("host=localhost dbname=vagrant user=vagrant password=")
    or die('LEPP STACK ISSUE: (nginx/php) Could not connect: ' . pg_last_error());

$query = 'CREATE TABLE IF NOT EXISTS "authors" (
  id   serial PRIMARY KEY,
  name text   NOT NULL
)';
$result = pg_query($query) or die('Query failed: ' . pg_last_error());

// Performing SQL query
$query = 'SELECT * FROM authors';
$result = pg_query($query) or die('Query failed: ' . pg_last_error());

// Printing results in HTML
echo "<!DOCTYPE html>\n<html>\n<body>\n";
echo "<h1>Hello from the LEPP stack!</h1>\n";
echo "<table>\n";
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
    echo "\t<tr>\n";
    foreach ($line as $col_value) {
        echo "\t\t<td>$col_value</td>\n";
    }
    echo "\t</tr>\n";
}
echo "</table>\n";
echo "</body>\n</html>";

// Free resultset
pg_free_result($result);

// Closing connection
pg_close($dbconn);
?>
