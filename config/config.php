<?php
// CREDITS TO https://github.com/Glennmen/PMSF


// @ IMPORTANT | Not finished YET! DO NOT USE
// todo-for-self: get rid of the php config and create 1 conf file (pref json) for back/front

namespace Config;

require '../api/utils/Medoo.php';
use Medoo\Medoo;

//
// Settings below are to restrict the data being returned, no matter if the switch on the frontend is turned on or off.
//

$noPokestops = false;                                               // set to true if you want to turn off Pokestops from being returned from raw_data;                                                                   
$noPokemon = false;                                                 // set to true if you want to turn off Pokemon from being returned from raw_data;
$noGyms = false;                                                    // set to true if you want to turn off Gyms from being returned from raw_data;


// This is the interval in SECONDS for the complete list of pokemon on screen to be pulled from the server when map is NOT moved (or 'panned' in official terms)
// low values will cause drain of resources and performance as a standard map (zoomed) often has more than 1000 pokemons, its not neseccary to query the entire db table every 5 seconds PER USER.

$sessionTTL = 60;                                                   

// settings below are db related. do not touch if you are using defaults or do not know what you are doing.
// database_type : pgsql   (other options mysql/mariadb/pgsql/sybase/oracle/mssql/sqlite)

$db = new Medoo([
    'database_type' => 'pgsql',                                     
    'database_name' => 'monocle',
    'server' => '127.0.0.1',
    'username' => 'monocle',
    'password' => 'monocle',
    'charset' => 'utf8',

    // [optional]
    //'port' => 5432,
    //'socket' => /path/to/socket/,
]);
