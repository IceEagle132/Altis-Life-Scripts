This was made for **V5.0**

Inside your **MasterHandler.hpp** add: **#include "jail_time.hpp"**

Inside your **Functions.hpp** Inside **class Cop** add: 
class showArrestDialog {};
class arrestDialog_Arrest {};


In your Database make sure to run:
```
ALTER TABLE players ADD `jail_time` int(11) NOT NULL DEFAULT '0';
```