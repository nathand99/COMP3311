<?php

// If you want to use the COMP3311 DB Access Library, include the following two lines
//
define("LIB_DIR","/import/adams/1/cs3311/public_html/19s1/assignments/a2");
require_once(LIB_DIR."/db.php");

// Your DB connection parameters, e.g., database name
//
define("DB_CONNECTION","dbname=a2");

//
// Include your other common PHP code below
// E.g., common constants, functions, etc.
//

//z1 = actor 1 name, z2 = actor 2 name
//a3 = actor 1 ID, a4 = actor2 ID
function find($z1, $z2, $a3, $a4, $i, $db, $string) {
    $q2 = "select acting.movie_id, movie.year, movie.title from acting join movie on acting.movie_id = movie.id where acting.actor_id = %d order by movie.title ASC";
    $r3 = dbQuery($db, mkSQL($q2, $a3));
    $q3 = "select acting.actor_id from acting where acting.movie_id = %d";
    //get each movie that actor 1 appears in
    //for each movie, look through all actors in that movie and if actor 2 is in, then found
    while ($t3 = dbNext($r3)) {
        $r4 = dbQuery($db, mkSQL($q3, $t3[0]));
        while ($t4 = dbNext($r4)) {    
            if ($t4[0] == $a4) {
                echo "$i. ";
                print($string);
                echo"$z1; ";
                echo "$z1 was in $t3[2]"; 
                if (!empty($t3[1])) {
                    echo" ($t3[1])";
                }
                echo" with $z2\n";
                $i++;
            }
        }
    }
    return $i;
}



?>
