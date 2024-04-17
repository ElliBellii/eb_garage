# EB: Garage System


**Supports the ESX framework**

A garage system built within the context menu from overextended for a clean design fitting all servers. I recommend watching the showcase for more information.

**Showcase**

[Garage System](https://www.youtube.com/watch?v=AfOK4YuUuQM&ab_channel=ElliBelli%21)

**Installation**

All you have to do is import the "ebowned_vehicles" file into your database and start the script. (Make sure to install all requirements)

**Key Features**

* Optimized: 0.00ms idle and 0.02ms when used
* Secure: All server events are protected from modders
* Easy configuration: Almost everything can be changed in the config file

**Example of insert**

```lua
MySQL.Async.insert('INSERT INTO ebowned_vehicles (owner, label, vehicle, vehtype, vehicleprops, numberplate, area, leased, impounded, parked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {xPlayer.getIdentifier(), 'Adder', 'adder', 'car', json.encode({plate = 'EB 12345', engineHealth = 1000.0, bodyHealth = 1000.0, fuelLevel = 100}), 'EB 12345', 'Los Santos', 0, 0, 1})
```

**Requirements**

* [ox_lib](https://github.com/overextended/ox_lib/releases/)
* [ox_target](https://github.com/overextended/ox_target/releases/)

**Note:** If you find any errors or have some ideas for the script, please let me know.
