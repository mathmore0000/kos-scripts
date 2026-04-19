// --- Variables ---
set _target_apoapsis to 75000. // in meters
set _target_periapsis to 75000. // in meters

// --- Launch ---
LOCK THROTTLE TO 1.
LOCK STEERING TO UP.

PRINT "Liftoff!".
STAGE.

// --- Start gravity turn ---
WAIT UNTIL ALTITUDE > 1000.

UNTIL SHIP:APOAPSIS > _target_apoapsis {

  check_staging().

  // gravity turn
  LOCAL frac IS MIN(ALTITUDE / 45000, 1).
  LOCAL pitch IS 90 - (frac * 80).
  LOCK STEERING TO HEADING(90, pitch).

  // --- throttle control ---
  IF SHIP:APOAPSIS > 70000 {
    LOCK THROTTLE TO 0.3.
  } ELSE {
    LOCK THROTTLE TO 1.
  }

  WAIT 0.1.
}

// --- Cut engine at target apoapsis ---
LOCK THROTTLE TO 0.
PRINT "Coasting to apoapsis".

// --- Wait until near apoapsis ---
WAIT UNTIL ETA:APOAPSIS < 45.

// --- Circularize ---
LOCK STEERING TO PROGRADE.
LOCK THROTTLE TO 1.

UNTIL PERIAPSIS > _target_periapsis OR APOAPSIS > _target_apoapsis + 5000 {
  check_staging().
  WAIT 0.1.
}

if PERIAPSIS < _target_periapsis {
  WAIT UNTIL ETA:PERIAPSIS < 30.
  LOCK STEERING TO PROGRADE.
  PRINT "Fine-tuning orbit".
  LOCK THROTTLE TO 0.3.
  WAIT UNTIL PERIAPSIS > _target_periapsis.
}

LOCK THROTTLE TO 0.
PRINT "Orbit achieved!".

FUNCTION check_staging {
  IF STAGE:SOLIDFUEL < 0.1 AND STAGE:LIQUIDFUEL < 0.1 {
    PRINT "Staging".
    STAGE.
    WAIT 1.
  }
}