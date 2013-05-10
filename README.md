notify_nagios.rb
================
I needed to find a way to let our Nagios know about any status change on any keepalived instances we run.

Requirements:
-------------
- nagios server with passive check support and a service definition, using check_dummy plugin
- at least one keepalived daemon running, pointing notify_master, notify_backup and notify_fault to the location where the notify_nagios.rb script is at.
- ruby 1.8.7, of course
- place keepalived.sh in /usr/local/bin (or the local of your preference). Create a cron job to run every minute or so.
- install nsca server on your nagios server and the nsca client on the hosts running keepalived.

How it works:
-------------
The idea is pretty straightforward. You must have a service definition on your nagios server set to passive mode. For example, look at the service definition below:

Nagios
------
    # The host itself...
    define host {
		use			gen-host
		host_name		lbre-lb2
		alias			LBRE LOAD BALANCER 2
		address			lbre-lb2.stanford.edu
		contacts		dummyuser
		contact_groups		null
        passive_checks_enabled  1
	}

	define service {
		**service_description	keepalived**
		host_name		lbre-lb2
		**check_command		check_dummy!3!"No data from Passive Check"**
	    flap_detection_options	n
	    active_checks_enabled	0
	    max_check_attempts	1
		check_freshness		1
		**freshness_threshold     3600**
	    contacts		user
		contact_groups		null
	    passive_checks_enabled  1
		stalking_options	n
		flap_detection_options  n
	}

The options in bold are the ones we need to look at.
* service_description	keepalived : this is what tell nagios which service will receive the status information when running the script.
* check_command		check_dummy!3!"No data from Passive Check" : this nagios plugin simply returns the status specified by its arguments. In this example, I tell nagios to report "UNKNOWN" status with the message "No data from Passive Check"
* freshness_threshold 3600: this is something important. Basically, it means that nagios will run an active check if it doesn't receive any activity (notification) from any machine running keepalived for one hour.

keepalived:
-----------

