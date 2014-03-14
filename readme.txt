Digitrak Autopilot

Version 0.1.1
Date Sunday, October 02, 2005
Author Steve Knoblock

License

This model of the Digitrak autopilot is released under the GPL.

Copyright (C)2002  Steve Knoblock

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


Look for this package at

http://www.city-gallery.com/vpilot/flightgear/

File List

digitrak-debug.xml          Defines the autopilot graphical interface.
digitrak-autopilot.xml      Defines the autopilot control system.
digitrak.rgb                The face graphic.
digitrak.rgb-ap-256x256.rgb The original face graphic.
digitrak.nas                NASAL script.
(please note, to save space the GPL license has been elided)

The graphic is from a catalog offering the Digitrak and is not copyright free. Do not redistribute or copy this for any use other than research or personal use. The face was reduced from the original face graphic.

Installation

Place the digitrak-debug.xml file in the Instruments folder.

Aircraft/Instruments/digitrak-debug.xml

Place the digitrak-autopilot.xml file in the Systems folder for the aircraft you are using the autopilot in (this depends on your a/c config file and whether it is aliased or not). If there is no Systems folder, create one.

Aircraft/[YOUR AIRCRAFT]/Systems/digitrak-autopilot.xml

Place the digitrak.nas file in the base folder for the given aircraft. Example:

Aircraft/[YOUR AIRCRAFT]/digitrak.nas

The digitrak-debug.xml file include goes in the aircraft panel configuration file. You should choose your own X and Y location on the panel.

  <instrument include="../../Instruments/digitrak-debug.xml">
   <name>Digitrak</name>
   <x>280</x>
   <y>80</y>
   <w>256</w>
   <h>256</h>
  </instrument>


The next step is to edit the aircraft configuration file to specify the Digitrak as the autopilot for the given aircraft. Modify the SYSTEMS section to point to the autopilot file (digitrak-autopilot.xml).

CAUTION: The electrical system must load before the Digitrak in order to ensure it operates. Be sure the AUTOPILOT system is placed _after_ the ELECTRICAL system. Otherwise, the autopilot will not have any power.
 
  <systems>
    <electrical>
      <path>Aircraft/c172/c172-electrical.xml</path>
    </electrical>
    <autopilot>
      <path>Aircraft/[YOUR AIRCRAFT]/Systems/digitrak-autopilot.xml</path>
    </autopilot>
  </systems>

The NASAL script file must be included by modifying the aircraft configuration file (the same file as the SYSTEMS section). Add the following code:

 <nasal>
  <digitrak>
   <file>Aircraft/[YOUR AIRCRAFT]/digitrak.nas</file>
  </digitrak>
 </nasal> 

Digitrak GUI

To operate some modes of the Digitrak, you will need to install a dialog window to the Autopilot menu. Copy the digitrak-settings.xml file to the gui/dialogs folder. This adds a Digitrak Settings choice to the Autopilot menu. Perhaps it could become standard FlightGear practice for each autopilot to add an entry to the Autopilot menu. This would help reduce confusion and enable special characteristics of each autopilot to be expressed instead of trying to fit them into a generic Autopilot dialog.

Quick Start
  
Here is the essential information on how to use the autopilot.

The Digitrak face contains three buttons. What these buttons do, depends on what mode the Digitrak is in. The following table shows their function:

Button			Mode		Action
Left Arrow		GPS Track	Moves the track direction left one degree.
Right Arrow		GPS Track	Moves the track direction right one degree.
On/Off			N/A			Left hand side ON, right hand side OFF.

Note: On/Off is also Engage/Disengage.

Pressing CTRL-C in FlightGear displays the clickable hot spots on the face.

* Power Up. The Digitrak displays three flashing dashes for about ten seconds while it initializes. Hold the aircraft still during this period (if you want to use realistic procedure).

* Stand By. Once the Digitrak completes initialization, it will display OFF if a valid GPS signal is present. The autopilot is not engaged at this point.

 * Once in the air, the autopilot can be engaged by pressing the ON/ENGAGE button. It will capture the GPS track and hold it.
  
 * Disengage. Press the OFF/DISENGAGE button to disengage the autopilot.
 
  
Manual

The Digitrak can be a bit puzzling if you are familiar with traditional autopilot systems. It has several modes, but no mode buttons for the pilot to select a mode. What mode the Digitrak employs is determined by the presence of a valid GPS signal and the kind of information it receives. Of course, being a single axis autopilot controlling the roll axis, there is less need for the pilot to specify a mode in the traditional sense (selecting holds on the various axes and selecting nav sources).

Most of the operation of the Digitrak is automatic. The pilot interface employs three buttons and one three digit display. 

While the Digitrak powers up and initializes, it displays three flashing dashes. The aircraft must be held still during this period. The autopilot is not engaged at this point. It will display OFF if a valid GPS signal is present.

There is no easy way to model the connection between the Digitrak and the GPS or the state of the complex communication that takes place between an advanced GPS unit and a digital autopilot. My solution was to create a dialog box on the main toolbar Autopilot menu to help the pilot communicate intentions and modify data representing the GPS connection.

Flying a GPS "Flight Plan"
(actually this can only fly from waypoint0 to waypoint1 as defined in the GPS dialog)

To engage GPS Flight Plan Mode, you must

CAUTION: You MUST specify Wp0 and Wp1 in the GPS dialog before activating Intercept Course or the script will throw an error.

* Set up a valid origin and active waypoint in the GPS Settings dialog on the Equipment menu from the toolbar (FlightGear 0.9.8). Close the dialog.

* Open the Digitrak dialog and click the Intercept Course button. Close the dialog.

The aircraft will intercept the course and hold it. Like most GPS the course is circle around the world, so you must disengage the autopilot when you reach the active waypoint.

To fail the GPS signal

* Open the Digitrak dialog and set GPS valid to off. This should engage the fallback Heading Hold Mode.


GPS Track Mode

When a GPS unit is supplying a valid GPS ground track and ground speed to the Digitrak, the autopilot will capture and follow the track. The pilot does not have to do anything but press the On/Engage button. This happens automatically. For example, if the aircraft is flying a track (NOT THE HEADING) of 270, the autopilot will hold this when engaged.

The track can be adjusted by pressing the LEFT or RIGHT buttons by one degree. Remember, you are adjusting the track and not the heading.


GPS Flight Plan Mode

If you set your airport as Waypoint 0 (the origin) and the destination airport as Waypoint 1, the Digitrak is capable of automatically intercepting and capturing the course (the line between waypoint zero and the active waypoint, which is Waypoint 1, the one the aircraft is flying to).

Please note that FlightGear, as far as I know, lacks the ability to supply a flight plan to the Digitrak, so the autopilot flies to the current active waypoint. If you can manage to supply the WP0 and WP1 properties with the waypoints in your flight plan, then the Digitrak should fly it.

To begin intercept of the course line, you must go to the toolbar, click Autopilot, click Digitrak Settings, click Intercept Course.

The display will show the flashing intercept direction until the course is captured. Once captured the display will show "-0-" on the Digitrak window to indicate it is holding the GPS course.

Note: You must install the Digitrak Settings dialog into the FlightGear graphical user interface (GUI) to use this mode.


Heading Hold Mode

If there is no valid GPS signal, whether because the unit is turned off or because it stops functioning, the Digitrak switches to its internal DG automatically aligned by its magnetometer. It will hold the current heading at the time the GPS signal fails or when powered up.


It is important to understand the Digitrak holds the TRACK not the HEADING. This makes it different from most autopilot systems that are capable of holding a heading. The direction displayed on the Digitrak when in GPS Track Hold mode is the TRACK, not the HEADING. If there is sufficient wind, you will see a difference between the Digitrak display and the Heading Indicator.

The Digitrak is capable of intercepting, capturing and flying a course line. The course line is specified by waypoints given to the GPS system. FlightGear provides a very good internal GPS system, but it is very basic. It does not support a flight plan (as far as I know, please note that the _built in_ autopilot can follow a series of waypoints, but that does not apply to the GPS or to the Digitrak). There is no graphical GPS interface.

I suppose the GPS supplied with FlightGear could be seen as a model of the internals of a GPS unit, not as any specific unit, such as the Garmin with all its bells and whistles. It would be possible to incorporate data from the GPS into a "shell" GPS instrument for display on a panel with the moving map and flight planner, etc. I will leave that to others for now.


Basic GPS Navigation

TRACK The track is the line the aircraft traces as it actually moves over the ground expressed as a compass direction. The track is not necessarily the same as the HEADING. The aircraft may point to a different heading than the track it is flying due to the effects of wind. It is entirely possible to by flying a 270 track with an aircraft heading of 260.

HEADING The heading is the direction the aircraft is pointing expressed as a compass direction.

COURSE The course is a line from the origin waypoint (when one exists) to the active waypoint, which is the waypoint the aircraft is intended to fly towards. The origin waypoint is referred to as Waypoint Zero and the next waypoint as the Active Waypoint (or in FlightGear GPS, Waypoint 1). It is important to note the COURSE never changes during a flight until the active waypoint is reached and replaced by a new active waypoint (as in following a route or flight plan).

About the Digitrak

This autopilot is classified "Experimental" (a shame, but at least it is one item that ultralight owners can make pilots with certified aircraft jealous) although TruTrak claims much better performance for their digital GPS autopilots than attained by a much more expensive sensor-based (turn coordinator driven) system like the S-Tec 50.

The Digitrak fits in a standard 2.25" instrument cut out, making it an excellent choice for adding an autopilot to small aircraft. Its light weight design is appreciated by those flying aircraft under weight restrictions.

TruTrak claims the Digitrak line of digital autopilots "love turbulence." Nearly all autopilots employ the turn coordinator as an indirect source of the aircraft's roll orientation. Due to idiosyncracies of the turn coordinator, these systems do not perform well in turbulence and must be disengaged when in turbulent conditions. The manufacturer claims the DigiTrak is capable of "outstanding performance" over competing systems in turbulence.

A convenience feature available on the Digitrak is True Control Wheel Steering. True control wheel steering means that upon release, the system synchronizes to the direction of flight over the ground, not to bank angle or turn rate. Multi-Servo autopilots synchronize to vertical speed. These are the only autopilot systems available with this feature.

DigiTrak auotopilots have been successfully used in aircraft such as: RV-7, Falco, Velocity, Europa.

You can find out more (including manuals you can download) about the Digitrak at the TruTrak website.

TruTrak

http://www.trutrakflightsystems.com/


Contributing

I welcome any suggestions for improving the code or the behavior of the autopilot. If I am wrong about anything, please send your corrections to me or to the FlightGear developer community through the mailing list.

Notes:

This is all very unfinished. On the todo list are changing some of the internal values to settings/ props; eventually most of the buttons will need NASAL scripting, but the point here is to just get the thing working in GPS nav mode, not the flight plan mode but the heading hold mode.


Todo List

 * Copyright free faceplate graphic or permission to redistribute existing graphic. I hope to create a 3D face using GMAX once I learn how to import an object into FGFS.
 
 * Model behavior of Digitrak when at low speed. Goes into Heading mode.

 * Clean up some of the values used in the calculations and sent to the display, which exceed 360 or are negative degrees, etc.

 * Real flashing DG heading instead of just flashing for 100 seconds.

 
Change Log

0.1.1
 * Hot spots on the face now correspond to correct actions.
 * Correct GPS flight plan mode display, heading until capture and -0- once captured and flying the course.
 
0.1.0

 * Implements the framework for flying a GPS flight plan.
 * Implemented GPS Track and GPS Nav modes.
 * Many code changes.

0.0.4

* /autopilot/internal/status to
/autopilot/digitrak/internal/status
in
digitrak-debug.xml

* making changes required to NASAL script ON/ENGAGE button and lay groundwork for scripting of other features and behaviors. Added digitrak.nas and modified system and panel configurations to accommodate. Consider this version ALPHA quality code.


0.0.3

* changed property displayed in a/p heading from
 /instrumentation/gps/indicated-track-true-deg
 to
 /instrumentation/gps/tracking-bug
(this may need to be scripted for correct behavior, it should display gps indicated track, say if once set, it drifts, not the tracking bug, but it probably should display the tracking bug when setting or turning to the heading?). One problem with this is now the heading display is not agreeing with magnetic heading on DG. Changed to

/instrumentation/gps/magnetic-bug-error-deg

* reduced size of LEDs and centered in gauge face heading window.

 
 
