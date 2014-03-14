#
# Digitrak Autopilot System
#
#

Locks        = "/autopilot/digitrak/locks";
Settings     = "/autopilot/digitrak/settings";
Annunciators = "/autopilot/digitrak/annunciators";
Internal     = "/autopilot/digitrak/internal";
#Systems      = "/systems/";

annunciator = "";
annunciator_state = "";
flash_interval = 0.0;
flash_count = 0.0;
flash_timer = -1.0;

# Flasher function from digitrak autopilot distributed with FlightGear
# goes here

flasher = func {
  flash_timer = -1.0;
  annunciator = arg[0];
  flash_interval = arg[1];
  flash_count = arg[2] + 1;
  annunciator_state = arg[3];

  flash_timer = 0.0;

  flash_annunciator();
}

flash_annunciator = func {
  ##print(annunciator);
  ##print(flash_interval);
  ##print(flash_count);

  ##
  # If flash_timer is set to -1 then flashing is aborted
  if (flash_timer < -0.5)
  {
    ##print ("flash abort ", annunciator);
    setprop(Annunciators, annunciator, "off");
    return;
  }

  if (flash_timer < flash_count)
  {
    #flash_timer = flash_timer + 1.0;
    if (getprop(Annunciators, annunciator) == "on")
    {
      setprop(Annunciators, annunciator, "off");
      settimer(flash_annunciator, flash_interval / 2.0);
    }
    else
    #elsif (getprop(Annunciators, annunciator) == "off")
    {
      flash_timer = flash_timer + 1.0;
      setprop(Annunciators, annunciator, "on");
      settimer(flash_annunciator, flash_interval);
    }
  }
  else
  {
    flash_timer = -1.0;
    setprop(Annunciators, annunciator, annunciator_state);
  }
}


  #
  # Initialize the autopilot.
  #
  #
  
ap_init = func {
  print("ap init");

  # debug
  # monitor electrical system
  #elec = getprop("/systems/electrical/volts[0]");
  #print("Volts: " ~ elec);
  #print (elec);
  
  #elec = getprop("/systems/electrical/outputs/autopilot");
  #print("Autopilot Power: " ~ elec);
  #print (elec);
  
 
  # Caution: For the electrical system outputs to be avialable
  # on initialization, the aircraft configuration file must
  # load the electrical system configuration file before
  # the autopilot configuration file (this file) is loaded.
  # Otherwise, the electrical system will not exist and
  # the electrical values will be nil and this will fail. Also,
  # this script must delay initialization briefly to allow time
  # for the electrical system to be established.

  # test for electrical system presence

  if( ! getprop("/systems/electrical/volts[0]") ) {
    print("Digitrak (Warning): No electrical system loaded.");
  }

  #
  # Ensure properties are properly initialized
  #

  # /remark
  # The following properties are used by this module:
  #
  # /autopilot/digitrak/internal/power-good (on|off)
  # /autopilot/digitrak/locks/gps-track (on|off)
  # /autopilot/digitrak/locks/gps-flight (on|off)	
  # /autopilot/digitrak/internal/status
  # /autopilot/digitrak/annunciators/hdg

	setprop(Internal, "power-good", "off");	
	setprop(Locks, "gps-track", "off");
	setprop(Locks, "gps-flight", "off");
	setprop(Locks, "hdg-hold", "off");
	setprop(Internal, "status", "disengaged");
	setprop(Annunciators, "hdg", "off");
	# assume gps
	setprop(Internal, "gps-valid", "on");

	# future use
	setprop(Settings, "activity-adj", 0);	

	setprop(Settings, 'intercept-angle', 45);
	
	setprop(Internal, 'xtk-turn-to', 'none');
	
	setprop(Internal, "gps-valid-plan", "off");
	
	# props to monitor stages of gps flight
	# used for modes of the aunnciator
	# when capturing and intercepting a course
	setprop(Internal, "course-captured", "off"); # captured
	setprop(Internal, "course-intercept", "off"); # intercepting
	setprop(Internal, "course-intercepted", "off"); # intercepted
	
	
  #
  # if power applied
  
  #
  # The autopilot (not the servos) unit requires:
  # +12v - +14v DC
  # 0.3 Amp
  # 180mA if buttons illuminated
  
  # Maybe this conditional should set a "power-good" internal value?
  # Yes, I think this is necessary, given the buttons should not be
  # active if there is no power.
  
  #
  # Set Power Good Signal
  #
  
  # Note: this appears without [0] in the a/c config, but in
  # props viewer has [0]
  # I suppose for this to be realistic, I need to test the
  # mains voltage to see if it is sufficent and
  # test the current of a/p output to see if that is enough
  # before saying power is good.
  ap_pwr = getprop("/systems/electrical/outputs/autopilot[0]");
  if( ap_pwr >= 0.3) {
    print("Digitrak: Power Good");
    setprop(Internal, "power-good", "on");
  } else {
    print("Digitrak (Warning): Insufficient power.");
    setprop(Internal, "power-good", "off");
  }
  
 
  if( getprop(Internal, "power-good") == "on" ) {
	print("has power");
	
  	# set init status
  	setprop(Internal, "status", "init");
  
  	#
  	# Initialization delay
  	#

  	# flash heading indicator for ten seconds
  	flasher("hdg", 1.0, 10, "on");
 
 # The problem is that flasher immediately returns, I need
 # --- to flash and then at the end, set status. This runs
 # a slightly longer than ten second delay to ensure
 # maintains init status until done flashing. Then
 # disengaged status is set.
 # or possibly before returning, the flasher could call
 # the engaged function, same as pressing the button.
 
 	
    settimer(delay, 15);
	 
  	# Initialization complete
 	
  } else {
  	print("Digitrak: No power.");
  	# and do what ... ?
  }
    elec = getprop("/systems/electrical/outputs/bus-avionics[0]");
	print("elec:");
    print(elec);
}

delay = func { setprop(Internal, "status", "disengaged"); }

#
# Buttons
#
#

# left button std turn

std_trn_lt = func {
 print("Standard Turn Left");

  # temporary
  #setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track_magnetic-deg") - 90 );
intercept_course();
}

# left button std turn

std_trn_rt = func {
 print("Standard Turn Right");
  # temporary
  setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track_magnetic-deg") + 90 );
}

# on/engage button
 
on_button = func {
  print("on_button");
 	
  if( getprop(Internal, "power-good") == "on" ) {

   	   #
 	   # Engage Autopilot
 	   #
	 
	  if( getprop(Internal, "gps-valid") == "on" ) {
	  print("gps valid");
	
	   
	
	if( getprop(Internal, "gps-valid-plan", "on") ) {
	  setprop(Locks, "gps-flight", "on");
	  setprop(Locks, "gps-track", "off");
	  #intercept_course();
	} else {
	
	#
 	   # Capture and hold GPS track
 	   #
  
 	   # The Digitrak, when engaged, if a valid GPS signal is present, captures and holds the current heading track automatically. 

 	   # This is modeled by setting the gps tracking bug
 	   # to the current ground track heading
 	   setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track_magnetic-deg"));

      setprop(Locks, "gps-flight", "off");
	  setprop(Locks, "gps-track", "on");
	} 
	   

	  } else {
	    print("gps invalid");
	
	    #
	    # Heading Hold Mode
	    #
	    #
	
	    # The digitrak contains its own DG slaved
	    # to the compass. When there is no gps signal, the
	    # digitrak tries to maintain the original track
	    # using the DG. The track becomes a heading to
	    # hold.

	    # I do _not_ want to use the DG instrument. That would
	    # mean the heading bug could move the heading around
	    # on the digitrak. There is _no_ connection to any
	    # other instrument than the GPS.
	
	    compass_hdg = getprop("/instrumentation/magnetic-compass/indicated-heading-deg");

	    setprop("/instrumentation/gps/tracking-bug", compass_hdg);
	
	    # probably need a function to set all locks off then set the desired lock
	    setprop(Locks, "gps-flight", "off");
	    setprop(Locks, "gps-track", "off");
	    setprop(Locks, "hdg-hold", "on");
	
	  }
		
 	 #
 	 # Change status to engaged
 	 #
 	 setprop(Internal, "status", "engaged");
   
  
 	 # ensure display is on
 	 setprop(Annunciators, "hdg", "on");
	 
	 print("Digitrak: Autopilot Engaged.");
		
	 } else {
	 }
	
 }

# off/disengage button

of_button = func {
  #print("off_button");
  
  if( getprop(Internal, "power-good") == "on" ) {
    # disengage/turn off ap
  
    setprop(Internal, "status", "disengaged");
    # ensure display is on
    setprop(Annunciators, "hdg", "on");
    # ensure locks are off
	
    setprop(Locks, "gps-track", "off");
    setprop(Locks, "gps-flight", "off");
	setprop(Locks, "hdg-hold", "off");
	
	print("Digitrak: Autopilot Disengaged.");
  }
 }
 


no_gps = func {

	# Simulate invalid gps signal or gps turned off/disconnected
	
	setprop(Locks, "gps-track", "off");
    setprop(Locks, "gps-flight", "off");
    setprop(Locks, "gps-valid", "off");
	
	setprop(Locks, "hdg-hold", "on");	
 }
 

#
# Intercept Course
# (Polling code after Andy Ross)
#

# Note: I may have got the wrong properties for course.
# There are course figures under wp/wp1 the active waypoint
# which is where I need to take my values. But I'm not sure
# because the desired course is there but the figures do
# not match the leg course. I'm not sure what these
# figures represent. I would think the leg course figures
# are the figures for the course line from wp0 to wp1, but
# perhaps they are figures for the "infinite" line as if
# there were no origin to the active waypoint.


intercept_course = func {
print("intercept course");

  # want to create a left/right flag in internals
  # /autopilot/digitrak/internal/xtk-turn-to (right|left)

  #
  # Set XTK turn flag.
  #
  # Note: This could use deviation.
  # I do not have to set a prop, but it might come in handy.
  if(
    getprop('/instrumentation/gps/wp/leg-course-error-nm') > 0 ) {
      setprop(Internal, 'xtk-turn-to', 'left')
    } elsif(
    getprop('/instrumentation/gps/wp/leg-course-error-nm') < 0 ) {
    setprop(Internal, 'xtk-turn-to', 'right')
  }

  #
  # Calculate intercept
  #
  #

  # actually a heading, sort of
  intercept_angle = getprop(Settings, 'intercept-angle');
  print("intercept angle: " ~ intercept_angle);
  
  # long way around, but want to use the props for this
  # so values can be watched or used at will
  # XTK determins subtract or add, could use course deviation

  # Note: if the gps has not been setup, this gives an
  # error because nil is used in a numeric expression
  # needs checking
  if( getprop(Internal, 'xtk-turn-to') == "left" ) {
	intercept_heading = getprop("/instrumentation/gps/wp/leg-mag-course-deg[0]") + intercept_angle;
  } else {
    intercept_heading = getprop("/instrumentation/gps/wp/leg-mag-course-deg[0]") - intercept_angle;
  }
  
  print("intercept heading: " ~ intercept_heading);

  #
  # Turn onto intercept track.
  # Notice how this is all automaticaly wind compensated
  # becuase GPS can follow a _track_.

  print("GPS Bug: " ~ intercept_heading);
  setprop("/instrumentation/gps/tracking-bug", intercept_heading );

  # flash DG heading while intercepting
  # hack, this really needs to flash indefinitely, until course captured
  flasher("hdg", 1.0, 100, "on");
  setprop(Internal, "course-intercept", "on" );
  
  # start capture
  capture_course();

}

capture_course = func {
print("capturing course");

  # could use either or both ?
  # /instrumentation/gps/wp/leg-course-error-nm
  # /instrumentation/gps/wp/leg-course-deviation-deg

  # start monitoring course deviation
  # as we fly the intercept
  
  check_course();
  
}

# want to write
# maybe lowercase 'and' works in nasal?
#if( ($crsdev < 2) AND ($crsdev > -2) ) {
#	print "in deadband";
#}



check_course = func {
print("monitoring course");

if( getprop(Internal, "power-good") == "on" and
getprop(Internal, "status") == "engaged"
 ) {
  
  # IMPORTANT, a deadband of 2nm is too wide, narrow to .5nm
      course_dev = getprop("/instrumentation/gps/wp/leg-course-deviation-deg");
	# two degree deadband
	# if very close to on course, set course as track on bug
      if( course_dev < 0.5 and course_dev > -0.5 ) {
        setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/wp/leg-mag-course-deg"));

        # signal course-intercept off
		# signal course-captured on
        setprop(Internal, "course-intercept", "off" );
        setprop(Internal, "course-captured", "on");
        print("Course Captured");
        return;
      }
	  
      settimer(check_course, 0.2);
} 

}

check_valid_gps_course = func {

#### FUTURE USE ####

# is there a valid gps course?

in_service = getprop("/instrumentation/gps/servicable");

# this is a little tricky, because I think someone can
# enter an id without the rest of the data appearing?
wp0id = getprop("/instrumentation/gps/wp/wp/ID");
wp1id = getprop("/instrumentation/gps/wp/wp[1]/ID");

# maybe look at this?
#getprop("/instrumentation/gps/wp/leg-course-deviation-deg");

if( (wp0id and wp1id) and in_service ) {
	setprop(Internal, "gps-valid", "on");
	} else {
		setprop(Internal, "gps-valid", "off");
	}
}
  

 #
 # Execute
 #
 #
 
 #ap_init();
 
 # Note: Delay initialization long enough for FlightGear to load and establish
 # electrical system.
 settimer(ap_init, 0);
 
