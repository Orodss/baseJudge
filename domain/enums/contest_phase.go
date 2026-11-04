package enums

type ContestPhase string

type ContestPhaseID int

const (
	ContestPhaseUnknownID  ContestPhaseID = 0
	ContestPhaseUpcomingID ContestPhaseID = 1
	ContestPhaseRunningID  ContestPhaseID = 2
	ContestPhaseEndedID    ContestPhaseID = 3
)

const (
	ContestPhaseUnknown  ContestPhase = "unknown"
	ContestPhaseUpcoming ContestPhase = "upcoming"
	ContestPhaseRunning  ContestPhase = "running"
	ContestPhaseEnded    ContestPhase = "ended"
)

func (v ContestPhase) IsValid() bool {
	switch v {
	case ContestPhaseUpcoming, ContestPhaseRunning, ContestPhaseEnded:
		return true
	default:
		return false
	}
}

// ID returns a stable numeric ID, or 0 for unknown values.
func (v ContestPhase) ID() ContestPhaseID {
	switch v {
	case ContestPhaseUpcoming:
		return ContestPhaseUpcomingID
	case ContestPhaseRunning:
		return ContestPhaseRunningID
	case ContestPhaseEnded:
		return ContestPhaseEndedID
	default:
		return ContestPhaseUnknownID
	}
}

// ContestPhaseFromID returns Unknown for unrecognized IDs.
func ContestPhaseFromID(id ContestPhaseID) ContestPhase {
	switch id {
	case ContestPhaseUpcomingID:
		return ContestPhaseUpcoming
	case ContestPhaseRunningID:
		return ContestPhaseRunning
	case ContestPhaseEndedID:
		return ContestPhaseEnded
	default:
		return ContestPhaseUnknown
	}
}
