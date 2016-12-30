<a href="https://github.com/naanselmo/uc-ghost/blob/uc/LICENSE">
    <img src="https://upload.wikimedia.org/wikipedia/commons/9/93/GPLv3_Logo.svg" alt="GPLv3 License" title="GPLv3 License" align="right" height="125" />
</a>

UC-GHost
=======

uc-ghost is a hosting bot for the Warcraft III multiplayer game. The main purpose of this bot is to automate game hosting and provide additional features, enabling server-like hosting for Warcraft III rather than relying on players serving as hosts.

uc-ghost is forked from [ent-ghost by Jack Lu](https://github.com/uakfdotb/ent-ghost), which was in turn forked from [the original GHost++ project by Trevor Hogan](https://code.google.com/archive/p/ghostplusplus/source).


Installation
------

The follow libraries are required, and are probably available in your preferred package manager:
* [Boost 1.55](http://www.boost.org/users/history/version_1_55_0.html)
* [GeoIP Legacy C library](https://github.com/maxmind/geoip-api-c)
* [GNU Multiple Precision Arithmetic library](https://gmplib.org/)
* [zlib](http://www.zlib.net/)
* [bzip2 library](http://www.bzip.org/)
* [MySQL Client library](https://dev.mysql.com/downloads/connector/c/)

A MySQL server is also required and expected to already be setup. This installation guide does not cover how to setup a MySQL server.

On Debian they may be installed, along with basic dependencies for compilation and git, using the following command:
```
sudo apt-get install build-essential git libboost1.55-all-dev libgeoip-dev libgmp-dev zlib1g-dev libbz2-dev libmysqlclient-dev
```
After all the requirements are installed, you may procede with the compilation.

1. Download the repository and enter it
   ```
git clone https://github.com/naanselmo/uc-ghost.git
cd uc-ghost
```

2. Compile BNCSUtil and install it
   ```
cd bncsutil/src/bncsutil
make
make install
cd ../../..
```

3. Compile StormLib and install it
   ```
cd StormLib/stormlib
make
make install
cd ../..
```

4. Compile UC-Ghost and move the binary
   ```
cd ghost
make
mv ghost++ ..
```

5. Create a user in your MySQL server with full rights to a database that uc-ghost will be using. The tables should be created using the provided [install.sql](install.sql) file. This user's credentials will be used during step 8.

6. Download MaxMind's Legacy GeoIP databases in binary format from [here](https://dev.maxmind.com/geoip/legacy/geolite/), renaming the extracted file to geoip.dat (or configuring "bot_geoipfile" in step 8 to match the file name and location).

7. Create the default directories (other names may be used provided they're specified during step 8)
   ```
mkdir mapcfgs maps replays savegames
```

8. Copy default.cfg to ghost.cfg and make your changes. Please note that ghost.cfg is loaded after default.cfg, meaning it will override any settings that are redefined. You may skip this step and modify default.cfg directly, and any undefined values will use the defaults specified in the source code.

   It is especially important to properly configure the database and bnet settings, located near the end of the file. Without these parameters properly configured the bot will not run properly, if at all.

9. Use one of the following methods to keep the bancache and gametrack tables up to date:
  * (Recommended) Add the MySQL triggers in [triggers.sql](triggers.sql) to your database.
  * (Not recommended) Create a script based around the [cron_functions.php](cron_functions.php) file and execute it frequently through cron.

10. (Optional) Modify the extra configuration files: gameloaded.txt, gameover.txt, motd.txt, phrase.txt

Your installation should now be ready for use.

Additional Reading
-------

This readme isn't a comprehensive guide, and [the original GHost++ readme](ghost_readme.txt) remains extremely useful. No adaptations have been made to this file, apart from removing the compilation section.

The [official GHost++ forum](https://www.ghostpp.com/forum/) is also extremely useful.

License
-------

uc-ghost is mostly licensed under GPLv3. The files modified by this project are all covered by GPLv3. Certain files were not modified by this project but are included in this repository as dependencies, and may or may not be licensed under GPLv3.

Any license or copyright notice contained within a file has priority over the GPLv3 license, should they differ.
